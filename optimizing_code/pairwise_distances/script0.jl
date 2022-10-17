using Clustering
using BenchmarkTools

function euclidean_mat(y, X, j) where T
    res = zero(eltype(y))
    @inbounds @fastmath @simd for k in eachindex(y)
        partial = X[k, j] - y[k]
        res += partial * partial
    end
    return res
end

function transform(X, R::KmeansResult)
    n_features, n_examples = size(X)
    cluster_assignments = Array{Int32, 1}(undef, n_examples)
    for n in 1:n_examples
        min_dist = typemax(eltype(X))
        cluster_assignment = Int32(0)
        for (j,c) in enumerate(eachcol(R.centers))
            dist = euclidean_mat(c, X, n)
            if dist < min_dist
                min_dist = dist
                cluster_assignment = j
            end
        end
        cluster_assignments[n] = cluster_assignment
    end
    return cluster_assignments
end


n_features = 128
n_examples = 1_000_000
n_clusters = 256

X = rand(Float32, n_features, n_examples)
R = kmeans(X, n_clusters ; maxiter=3, display=:iter)
@btime transform(X,R)
