using BenchmarkTools, InlineStrings, JSON, Random, Parquet, DataFrames

t_init = time()

n_list = 50_000_000
n_blocklist = 100_000
#list = [randstring(10) for i in 1:n_list];
#blocklist = list[1:n_blocklist];

list = DataFrame(read_parquet("./df1.parquet")).list
blocklist = DataFrame(read_parquet("./df2.parquet")).blocklist

function check_list_in_blocklist(list, blocklist)
    blocklist_set = Set(blocklist)
    result = Array([])
    for l in list
        if l in blocklist_set
            push!(result,l)
        end
    end
    return result
end

result = check_list_in_blocklist(list, blocklist)
println("result has to be length $n_blocklist and is lenght $(length(result))")
#println(@benchmark check_list_in_blocklist(list, blocklist) )

println("total time taken is $(time()-t_init) seconds")
