using Clustering
using BenchmarkTools
using Distances

function euclidean_mat(y, X, j) where T
    res = zero(eltype(y))
    @inbounds @fastmath @simd for k in eachindex(y)
        partial = X[k, j] - y[k]
        res += partial * partial
    end
    return res
end

function get_cluster_assignments(
    X::Matrix{T}, 
    centers::Matrix{T}, 
    distance::SemiMetric=SqEuclidean(),       # in: function to calculate distance with
    ) where {F<:Function,T}


    cluster_assignments = zeros(Int, size(X,2))

    Threads.@threads for n in axes(X,2)
        min_dist = typemax(T)
        cluster_assignment = 0
        for k in axes(centers, 2)
            dist = distance(@view(X[:,n]),@view(centers[:,k]))
            if dist < min_dist
                min_dist = dist
                cluster_assignment = k
            end
        end
        cluster_assignments[n] = cluster_assignment
    end
    return nothing
end

function transform(X, R::KmeansResult)
    #cluster_assignments = findmin(pairwise(X, R.centers), dims=2)
    cluster_assignments = [x[2] for x in findmin(pairwise(SqEuclidean(), X, R.centers), dims=2)[2]]

    return cluster_assignments
end

n_features = 128
n_examples = 1_000_000
n_clusters = 20

X = rand(Float32, n_features, n_examples)
R = kmeans(X, n_clusters ; maxiter=3)

display(@benchmark transform(X, R))
display(@benchmark get_cluster_assignments(X, R.centers))

