using BenchmarkTools, InlineStrings, JSON, Random, Parquet, DataFrames

t_init = time()

n_list = 50_000_000
n_blocklist = 100_000
#list = [randstring(10) for i in 1:n_list];
#blocklist = list[1:n_blocklist];

### Solution with custom hash

struct ASCII_ID
    x::InlineString15
 end
  
 Base.:(==)(x::ASCII_ID, y::ASCII_ID) = x.x == y.x
 aword(x::ASCII_ID) = (bswap(reinterpret(UInt128, x.x)) % UInt)
 Base.hash(x::ASCII_ID, h::UInt64) = hash(aword(x),h)
  
 function check_list_in_blocklist3(list, blocklist)
    blocklist_set = Set{ASCII_ID}(blocklist)
    result = Array{ASCII_ID}([])
    for l in list
        if l in blocklist_set
           push!(result,l)
        end
    end
    return result
end
  

list = ASCII_ID.(read_parquet("./df1.parquet")[1])
blocklist = ASCII_ID.(read_parquet("./df2.parquet")[1])

result = check_list_in_blocklist3(list, blocklist)
println("result has to be length $n_blocklist and is lenght  $(length(result))")
#println(@benchmark check_list_in_blocklist3(list_asin_id, blocklist_asin_id))


println("total time taken is $(time()-t_init) seconds")
