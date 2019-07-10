## How to get the input arguments of a Julia script from the command line

In Julia you can pass arguments to a script. All arguments (separated by an empty space) will be kept inside variable `ARGS` which will be available once Julia starts running. `ARGS` is a list of strings containing all arguments passed to a script.



##### Example 01_test_ARGS.jl

This example shows how we can pass arguments to a julia script

```julia
println("Number of arguments: ", length(ARGS), " arguments.")
println("Argument List: ", ARGS)
println("typeof(ARGS): ", typeof(ARGS))
```

In order to pass arguments we have to add them after the name of the program with empty spaces between arguments.

```
julia 01_test_ARGS.jl dog cat 23
```

```
Number of arguments: 3 arguments.
Argument List: ["cat", "dog", 23]
println("typeof(ARGS): ", typeof(ARGS))
```

Notice that ARGS is an `Array{String, 1}` therefore, if we want to use the `"23"` as a number we need to `parse` the string.

```
a = "23"
println("typeof(a): ", typeof(a))
println("typeof(parse(Int,a)): ", typeof(parse(Int,a)))
```

```
typeof(a): String
typeof(parse(Int,a)): Int64
```





## Use keyword arguments of a Julia script inside julia



We could use `ARGS` and define the whole needed logic to treat input strings as we wish. This would be tedious and quite a lot of work depending on the complexity of the command-line interface. Luckily we can use the package `ArgParse.jl` which will help us doing command-line interfaces.



##### Example 02_test_argparse.jl

Let us consider we want to make a program that takes as input argumetn the radius and the height of a cylinder and returns the volume of the cylinder. We would like to do the following

```bash
julia 02_test_argparse.jl -r 1 -H 1
```

```
Cylinder volume is 3.141592653589793
```

To do so let us add the following code inside `02_test_argparse.jl`

```julia
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--radius", "-r"
            help = "Set radius for the cylinder"
            arg_type = Float64
        "--height", "-H"
            help = "Set height for the cylinder"
            arg_type = Float64
    end

    return parse_args(s)
end

function cylinder_volume(radius, height)
    return pi * (radius^2) * height
end

function main()
    parsed_args = parse_commandline()
    vol = cylinder_volume(parsed_args["radius"], parsed_args["height"])
    println("Cylinder volume is ", vol)
end

main()
```




