using HDF5
using BenchmarkTools
using Distances
using Clustering
using ProgressMeter
using DataFrames
using Plots
using NPZ
using JET

function encode_shared(dist, vector::Array{T}, shared_prototypes::Array{T}) where T
    n_clusters = length(shared_prototypes)
    n_features = size(vector)[1]
    closest_prototypes = Array{Int8}(undef, n_features, 1);
    
    @inbounds for (j,x) in enumerate(vector)
        best_coordinate = 1
        min_distance::T = typemax(T)
        for k in 1:n_clusters
           current_dist = dist(shared_prototypes[k], x)
           if current_dist < min_distance
               best_coordinate = k
               min_distance = current_dist
           end
           #println(k, ' ', j, ' ', best_coordinate, ' ',min_distance )
        end            
        closest_prototypes[j] = best_coordinate
    end
    return closest_prototypes
end

function ivf_indexer(X, PQcodes, n_cells, clustering_function)
    n_features, n_examples = size(X)

    result = clustering_function(X, n_cells)
    centroids = result.centers
    cell_ids = result.assignments
    
    cells = Vector{Matrix{Int8}}(undef, n_cells)
    pq_ids = Vector{Vector{Int32}}(undef, n_cells)
    @inbounds @fastmath for i in 1:n_cells
        pq_idx = findall(x -> x == i,cell_ids) 
        cells[i] = PQcodes[:,pq_idx]
        pq_ids[i] =  pq_idx 
    end
    return centroids, cells, pq_ids
end

function Euclidean0(x, query)
    @assert length(x) == length(query)
    res = zero(eltype(x))
    @inbounds   for j in eachindex(x)
        aux = (query[j] - x[j])
        res += aux * aux
    end
    return sqrt(res)
end

function adc_dist_shared( x_code,  adc_table::Matrix)
    res = zero(eltype(adc_table))
    @inbounds @simd for j in eachindex(x_code)
        res+= adc_table[x_code[j], j]
    end
    return res
end


function linear_scann_shared(query, PQcodes, adc_table_shared, P_shared)
    n_features, n_examples = size(PQcodes)
    distances = Array{eltype(query)}(undef, n_examples)
    
    @inbounds @fastmath for j in 1:n_examples
        distances[j] = adc_dist_shared( view(PQcodes,:,j) ,  adc_table_shared)    
    end
    return distances
end

function compute_ADC_shared(query, prototypes, dist)
    """
    Computes the distance between each query[k] and prototype[k]
    
    Arguments:
    
    - y (Array{T}): vector of n_features components.
    - prototypes (Array{T}): vector of n_cluster components.
    - dist (function): distance to be used to compare prototypes and query.
    
    """
    #@assert ndims(prototypes) ==1
    
    n_features = length(query)
    n_clusters = length(prototypes)
    ADC_table = Array{Float32}(undef, n_clusters, n_features)
    
    for j in 1:n_features       # 128
        for p in 1:n_clusters   # 32
            ADC_table[p,j] = dist(query[j], prototypes[p] )
        end
    end
    @assert ndims(ADC_table)==2
    return  ADC_table
end

function abs_dist(y::Array{T}, X::Array{T}, j) where T
    # Here I use a bigger Int type than 8 due to avoid
    # res beeing overflowed
    res = Int16(0)
    @inbounds @fastmath  for k in eachindex(y)
        res += abs(X[k, j] - y[k])
    end
    return res
end


function euclidean_mat2(y, X, j) where T
    # Here I use a bigger Int type than 8 due to avoid
    # res beeing overflowed
    res = zero(eltype(y))
    @inbounds @fastmath  for k in eachindex(y)
        partial = X[k, j] - y[k]
        res += partial * partial
    end
    return res
end

function select_cells(n_cells, nprobe, centroids, query, dist)
    distances = Array{Float32}(undef, n_cells)
    for i in 1:n_cells
        distances[i] = dist(query, centroids[:,i]) 
    end
    closest_prototypes = partialsortperm(distances, 1:nprobe)
    best_distances = distances[closest_prototypes]

    return best_distances, closest_prototypes
end


function get_top_distances(query, X, prototypes, cells, indexes, fine_quant_funct, P, top_k, extra_factor, refinement, j)

    real_index = prototypes[j]
    pq_codes = cells[real_index]
    original_ids = indexes[real_index]
    pq_distances = fine_quant_funct(query, pq_codes, P)
    n_to_sort = minimum([top_k*extra_factor, length(pq_distances)])
    top_k_pq = partialsortperm(pq_distances, 1:n_to_sort) 

    #Exact search if refinement is chosen
    if refinement == true
        best_ids = Vector{Int32}(undef, n_to_sort)
        for i in 1:n_to_sort
            id = top_k_pq[i]
            best_ids[i] = original_ids[id]
        end
        pq_distances = linear_scann_exact(query, X[:,best_ids]); #X_tr_vecs in memory, SOLVE THIS ->memmap, HDF5
        top_k_pq = partialsortperm(pq_distances, 1:top_k)
        original_ids = best_ids
    end

    #retrieve original ids and distances of closest vectors
    ids = Vector{Int32}(undef, top_k)
    distances = Vector{Float32}(undef, top_k)
    for i in 1:top_k
        id = top_k_pq[i]
        ids[i] = original_ids[id]
        distances[i] = pq_distances[id]
    end
    return distances, ids
end


function top_distances(query, X, closest_prototypes, cells, indexes, fine_quant_funct, P, top_k, extra_factor, refinement, nprobe)
    result_distances = Vector{Vector{Float32}}(undef, nprobe)
    result_ids = Vector{Vector{Int32}}(undef, nprobe)
    for i in 1:nprobe
        distances, ids = get_top_distances(query, X, closest_prototypes, cells, indexes, fine_quant_funct, P, top_k, extra_factor, refinement, i)
        result_distances[i] = distances
        result_ids[i] = ids
    end
    return result_distances, result_ids
end


function linear_scann_shared_l1(query, PQcodes_shared, P_shared)

    n_features, n_examples = size(PQcodes_shared)
    distances = Array{Float32}(undef, n_examples)
    query_code = encode_shared(euclidean, query, P_shared)
    
    @inbounds @fastmath for j in 1:n_examples
        distances[j] = abs_dist(query_code, PQcodes_shared, j)    
    end
    return distances
end

function linear_scann_shared_ADC(query, PQcodes_shared, P_shared)
    
    n_features, n_examples = size(PQcodes_shared)
    distances = Array{eltype(query)}(undef, n_examples)
    adc_table_shared = compute_ADC_shared(query, P_shared, euclidean)
    
    @inbounds @fastmath for j in 1:n_examples
        distances[j] = adc_dist_shared(view(PQcodes_shared,:,j) ,  adc_table_shared)    
    end
    return distances
end

function linear_scann_exact(query, X)

    n_features, n_examples = size(X)
    distances = Array{Float32}(undef, n_examples)
    
    @inbounds for j in 1:n_examples
        distances[j] = euclidean_mat2(query, X, j)    
    end
    return distances
end


function priority_queue_sort(distances, ids, top_k)
    top_k_distances = distances[1]
    top_k_vectors = ids[1]
    for k in 2:length(distances)
        for i in 1:length(distances[k])
            if distances[k][i] < top_k_distances[top_k]
                j = top_k
                while distances[k][i] < top_k_distances[j-1]
                    j = j-1
                    if j == 1
                        break
                    end
                end
                top_k_distances_fixed = copy(top_k_distances)
                top_k_vectors_fixed = copy(top_k_vectors)
                for element in j+1:top_k
                    top_k_distances[element] = top_k_distances_fixed[element-1]
                    top_k_vectors[element] = top_k_vectors_fixed[element-1]
                end
                top_k_distances[j] = distances[k][i]
                top_k_vectors[j] = ids[k][i]
            else
                break
            end
        end
    end
    return top_k_distances, top_k_vectors
end

function ivf_search(query, X, centroids, cells, indexes, dist, nprobe, PQcodes, P, fine_quant_funct, top_k, extra_factor, refinement)

    if refinement == false
        @assert extra_factor==1
    end

    #Get nprobe closest centroids 
    n_cells = length(cells)
    best_distances, closest_prototypes = select_cells(n_cells, nprobe, centroids, query, dist)
    
    #Get top_k distances in each selected cell
    result_distances, result_ids = top_distances(query, X, closest_prototypes, cells, indexes, fine_quant_funct, P, top_k, extra_factor, refinement, nprobe)
     
    #Get top_k closest distances
    top_k_distances, top_k_vectors = priority_queue_sort(result_distances, result_ids, top_k)

    return top_k_distances, top_k_vectors
end


println("Reading dataset...")
#path = joinpath(homedir(), "TFM", "ann-benchmarks",  "sift-128-euclidean.hdf5")
path = joinpath(homedir(), "Datasets", "SIFT1M",  "sift-128-euclidean.hdf5")
f = h5open(path, "r")
X_tr_vecs = read(f["train"])
X_te_vecs = read(f["test"]);
true_neighbors = read(f["neighbors"])
true_distances = read(f["distances"])
true_neighbors .= true_neighbors .+ 1;
n_features, n_examples = size(X_tr_vecs)


println("Fitting PQcodes...")
#path_prot = joinpath(homedir(), "TFM", "julia_tutorials","optimizing_code","pqlinearscann","1dkmeans_prototypes","1dkmeans_shared_prototypes_SIFT1M.npy")
path_prot = joinpath(pwd(), "1dkmeans_prototypes", "1dkmeans_shared_prototypes_SIFT1M.npy")

P_shared = vec(Float32.(npzread(path_prot)))

PQcodes_shared = Array{Int8}(undef, n_features, n_examples);
for j in 1:n_examples
    PQcodes_shared[:,j] = encode_shared(euclidean, X_tr_vecs[:,j], P_shared)  
end

println("Creating cells...")
n_cells = 100
clustering_function = kmeans
centroids, cells, indexes  = ivf_indexer(X_tr_vecs, PQcodes_shared, n_cells, clustering_function)
println(@report_opt ivf_indexer(X_tr_vecs, PQcodes_shared, n_cells, clustering_function))

println("Applying IVF search...")
query_id = 1
query = X_te_vecs[:,query_id]
dist = Euclidean0
top_k = 100
nprobe = 10
refinement = true
extra_factor = 10
fine_quant_funct = linear_scann_shared_l1

#@profview ivf_search(query, X_tr_vecs, centroids, cells, indexes, dist, nprobe, PQcodes_shared, P_shared, fine_quant_funct, top_k, extra_factor, refinement)
println(@report_opt ivf_search(query, X_tr_vecs, centroids, cells, indexes, dist, nprobe, PQcodes_shared, P_shared, fine_quant_funct, top_k, extra_factor, refinement))
