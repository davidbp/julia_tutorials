# Simple code to read line by line some text

file_name = "text_per_row.md"

for (k,line) in enumerate(eachline(file_name))
    println("line $k is: ", line)
end
