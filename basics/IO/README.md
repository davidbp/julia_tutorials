
# IO

This readme will show a variety of situations and code related reading and writting to disk. 
To prepare the examples in this folder run


### 00) Prepare the data for the examles in this `README`

Run the following command to prepare the data for the examples in this `README.md`.
```
julia 00_prepare_data.jl
```

### 01) Read lines of a file with method **`eachline`**

- **`eachline(file_name)`** creates a `IOStream`, which does not load all lines to memory but reads one line at a time (it creates an iterable that reads one line each time it is called).

One can read rows of a  file with the method **`eachline`** as follows:

```
file_name = "text_per_row.md"

for (k,line) in enumerate(eachline(file_name))
    println("line $k is: ", line)
end
```

To test this you can run `julia 01_read_lines.jl` which should print:

```
line 1 is: this is a text sample
line 2 is: we will iterate over lines
line 3 is: and count that there are 3 lines
```



### 02) Append lines to a file with **`write`** method

One can write to a file with **`write(io::IOStream, text)`**.

The following snippet shows how two lines are appended to the file. Note that they are appended because the file is openned with "a".

```
file_name = "text_per_row.md"

new_lines = ["we can add more lines", "with the **write** command"]

open(file_name,"a") do f
    for line in new_lines
        println("added line: '$line'  to $file_name")
	write(f, line *"\n")
    end
end
```

One can run 
```
julia 02_write_lines.jl
cat text_per_row.md 
```
and see
```
this is a text sample
we will iterate over lines
and count that there are 3 lines
we can add more lines
with the **write** command
```

### 03) Overwrite a file with **`write`** method

One can overwrite to a file with **`write(file_name, values)`**.

The following snippet shows how two lines are appended to the file. Note that they are appended because the file is openned with "a".

```
file_name = "text_per_row.md"

new_lines = ["we can destroy the lines that were in the file", "and add new lines"]

open(file_name,"w") do f
    for line in new_lines
        println("added line: '$line'  to $file_name")
	write(f, line *"\n")
    end
end
```

One can run 
```
julia 03_overwrite_lines.jl
cat text_per_row.md 
```
and see
```
we can destroy the lines that were in the file
and add new lines
```


### 04) Serializing data with  **`serialize`** method

One can use **`serialize(filename::AbstractString, value)`** to serialize `value` to `filename`.
