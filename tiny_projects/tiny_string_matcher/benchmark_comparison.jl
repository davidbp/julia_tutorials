
using BenchmarkTools, InlineStrings, JSON, Random

n_list = 50_000_000
n_blocklist = 100_000
list = [randstring(10) for i in 1:n_list];
blocklist = list[1:n_blocklist];

#### 1) Simple solution ####


function check_list_in_blocklist(list, blocklist)
    blocklist_set = Set{String}(blocklist)
    result = Array{String}([])
    @inbounds for l in list
        if l in blocklist_set
            push!(result,l)
        end
    end
    return result
end

@btime check_list_in_blocklist(list, blocklist)


#### 2) InlineString solution ####

function check_list_in_blocklist_inlinestring(list, blocklist)
    blocklist_set = Set{InlineString15}(blocklist)
    result = Array{InlineString15}([])
    @inbounds for l in list
        if l in blocklist_set
            push!(result,l)
        end
    end
    return result
end

list_inline = InlineString15.(list)
blocklist_inline = InlineString15.(blocklist);
@btime check_list_in_blocklist_inlinestring(list_inline, blocklist_inline)


#### 3)InlineString with custom hash solution ####
struct ASCII_ID
    x::InlineString15
end
 
Base.:(==)(x::ASCII_ID, y::ASCII_ID) = x.x == y.x
aword(x::ASCII_ID) = (bswap(reinterpret(UInt128, x.x)) % UInt)
Base.hash(x::ASCII_ID, h::UInt64) = hash(aword(x),h)
 
function check_list_in_blocklist(list, blocklist)
    blocklist_set = Set{ASCII_ID}(blocklist)
    result = Array{ASCII_ID}([])
    @inbounds for l in list
        if l in blocklist_set
            push!(result,l)
        end
    end
    return result
end
 
list_ascii_id = ASCII_ID.(list)
blocklist_ascii_id = ASCII_ID.(blocklist);
@btime check_list_in_blocklist(list_ascii_id, blocklist_ascii_id)


function check_list_in_blocklist_fast(list, blocklist)
    n_list, n_blocklist = length(list), length(blocklist)
    hashtable = zeros(UInt8, 1<<19)
    indtable = zeros(Int, 1<<19)
    mask = (UInt64(1)<<19)-1
    for i in 1:n_blocklist
        h = hash(unsafe_load(reinterpret(Ptr{UInt64}, pointer(blocklist[i]))))
        loc = (h & mask)+1
        val = ((h >> 19) & 0x7F)+1
        while hashtable[loc] != 0
            loc += 1
            loc == (1<<19) && (loc = 1)
        end
        hashtable[loc] = val
        indtable[loc] = i
    end
    preres, preres2 = Int[], Int[]
    for i in 1:n_list
        h = hash(unsafe_load(reinterpret(Ptr{UInt64}, pointer(list[i]))))
        loc = (h & mask)+1
        val = ((h >> 19) & 0x7F)+1
        while hashtable[loc] != 0
            if hashtable[loc] == val
                push!(preres, i)
                push!(preres2, indtable[loc])
            end
            loc += 1
            loc == (1<<19) && (loc = 1)
        end
    end
    return [ list[preres[i]] for i in 1:length(preres) if list[preres[i]]==blocklist[preres2[i]]]
end

@btime check_list_in_blocklist_fast(list, blocklist)

