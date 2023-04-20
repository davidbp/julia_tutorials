

OUTPUT_FILE = "text_per_row.md"

text = """
this is a text sample
we will iterate over lines
and count that there are 3 lines"""

lines = [x for x in split(text, "\n") if length(x)>0]

rm(OUTPUT_FILE,force=true)

open(OUTPUT_FILE, "w") do io
    for line in lines
        write(io, line*"\n")
    end 
end
