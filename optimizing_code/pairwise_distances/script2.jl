using Base.Threads
using Clustering
using BenchmarkTools
using LoopVectorization


function transform!(X::Matrix{F}, centers::Matrix{F}, cluster_assignments::Vector{I}) where {F,I}
    n_features, n_examples = size(X)
    n_clusters = size(centers, 2)
    if length(cluster_assignments) != n_examples
        error("output size")
    end
    Threads.@threads :static for n in 1:n_examples
        min_dist = typemax(F)
        cluster_assignment = zero(I)
        for k in 1:n_clusters
            dist = zero(F)
            @fastmath for d=1:n_features
                @inbounds dist += (X[d,n]-centers[d,k])^2
            end
            if dist < min_dist
                min_dist = dist
                cluster_assignment = k
            end
        end
        @inbounds cluster_assignments[n] = cluster_assignment
    end
    nothing
end

n_features = 128
n_examples = 1000_000
n_clusters = 256

X = rand(Float32, n_features, n_examples)
centers = rand(Float32, n_features, n_clusters)
assignments = zeros(Int32, n_examples)

println("\nExecution with $(nthreads()) threads")
benchmark = @benchmark transform!(X, centers, assignments)
display(benchmark)