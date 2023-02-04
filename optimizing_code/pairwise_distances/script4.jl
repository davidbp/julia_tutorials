using Base.Threads
using BenchmarkTools

@inline function norm_sqr(x::AbstractVector{T},y::AbstractVector{T}) where {T}
    dist = zero(T)
    @simd for i in eachindex(x,y)
        @inbounds dist += (x[i] - y[i])^2
    end
    return dist
end

function get_cluster_assignments(
    X::Matrix{T}, 
    centers::Matrix{T}, 
    distance::F) where {F<:Function,T,I<:Integer}


    assignments = zeros(size(X,1))

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
        cluster_assignments[n] = I(cluster_assignment)
    end
    return nothing
end

function main()

    n_features = 128
    n_examples = 1000_000
    n_clusters = 256
    
    X = rand(Float32, n_features, n_examples)
    centers = rand(Float32, n_features, n_clusters)
    assignments = zeros(Int32, n_examples)
    
    println("\nExecution with $(nthreads()) threads\n")
        
    display(@benchmark transform!($X, $centers, $assignments0))
end

main()
