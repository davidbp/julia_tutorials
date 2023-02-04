using BenchmarkTools
using LoopVectorization
using Random

n_clusters = 32
n_examples = 1_000_000
n_features = 128

# Look up table with real numbers
T = rand(MersenneTwister(0), n_clusters, n_features);                                
# Big matrix with indicies
PQ = rand(MersenneTwister(0), 1:n_clusters, n_features, n_examples)      
# Big matrix with indicies
PQ_trans =  Matrix(PQ');                                            

function lsh(PQ, T)
    
    n_features, n_examples = size(PQ)
    d = zeros(eltype(T), n_examples)
    
    @inbounds @fastmath for n in 1:n_examples
        res = zero(eltype(T))
        for j in 1:n_features
            res += T[PQ[j,n],j]    
        end
        d[n] = res
    end
    return d
end


function lsh_transposed(PQ_trans, T)
    
    n_examples, n_features = size(PQ_trans)
    d = zeros(eltype(T), n_examples)
    @inbounds @fastmath for j in 1:n_features
        for n in 1:n_examples
            d[n] += T[ PQ_trans[n,j], j ]    
        end
    end
    return d
end

res_lsh_transposed = lsh_transposed(PQ_trans, T);
res_lsh = lsh(PQ, T);
@assert isapprox(res_lsh_transposed, res_lsh)

# test with Int8
PQ_int = UInt8.(PQ)
res_lsh_int = lsh(PQ_int, T);

display(@benchmark lsh_transposed($PQ_trans, $T))
display(@benchmark lsh($PQ, $T))
display(@benchmark lsh($PQ_int, $T))


@show res_lsh[1:10]
@show res_lsh_int[1:10]
