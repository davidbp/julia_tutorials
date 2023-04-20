file_name = "text_per_row.md"

new_lines = ["we can destroy the lines that were in the file", "and add new lines"]

open(file_name,"w") do f
    for line in new_lines
        println("added line: '$line'  to $file_name")
	write(f, line *"\n")
    end
end
