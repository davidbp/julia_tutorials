using Base.Threads
using BenchmarkTools

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

function norm_sqr(x::AbstractVector{T},y::AbstractVector{T}) where {T}
    dist = zero(T)
    @simd for i in eachindex(x,y)
        @inbounds dist += (x[i] - y[i])^2
    end
    return dist
end

function transform3!(
    by::F,
    X::Matrix{T}, 
    centers::Matrix{T}, 
    cluster_assignments::Vector{I};
) where {F<:Function,T,I<:Integer}
    length(cluster_assignments) != size(X,2) && throw(ArgumentError("output size != number of clusters"))
    Threads.@threads for n in axes(X,2)
        min_dist = typemax(T)
        cluster_assignment = 0
        for k in axes(centers, 2)
            dist = by(@view(X[:,n]),@view(centers[:,k]))
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
    assignments0 = zeros(Int32, n_examples)
    assignments1 = zeros(Int32, n_examples)
    
    println("\nExecution with $(nthreads()) threads\n")
    
    transform!(X, centers, assignments0)
    transform3!(norm_sqr, X, centers, assignments1)
    println(assignments0 == assignments1)
    
    @btime transform3!($norm_sqr,$X, $centers, $assignments1)
    @btime transform!($X, $centers, $assignments0)

end

main()