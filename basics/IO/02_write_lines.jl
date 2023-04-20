file_name = "text_per_row.md"

new_lines = ["we can add more lines", "with the **write** command"]

open(file_name,"a") do f
    for line in new_lines
        println("added line: '$line'  to $file_name")
	write(f, line *"\n")
    end
end


