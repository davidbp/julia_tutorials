using Base.Threads
using BenchmarkTools
using Distances

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

function main()

    n_features = 128
    n_examples = 1000_000
    n_clusters = 256
    
    X = rand(Float32, n_features, n_examples)
    centers = rand(Float32, n_features, n_clusters)    
    println("\nExecution with $(nthreads()) threads\n")
        
    display(@benchmark get_cluster_assignments($X, $centers))
end

main()
