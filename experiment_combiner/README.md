
# ExperimentCombiner

The objective of combiner is to generate combinations of a tagged input file.

This could be potentially useful if:

- You have a program `main.jl` that uses an input file `input.inp` in order to define the logic of your program.

- The input file has several parameters that you can set. You would like to execute, for each parameter configuration, the program.
- Given  `input.inp`  and `main.jl` you generate `result.out` 

A possible solution could be to simply have a single julia script that generates all possible combinations and runs the code in `main.jl`. Nevertheless, in cluster environments it is common to want to package experiments and send them independently. This is the approach `ExperimentCombiner.jl` follows.



#### Example

Let us assume the following problem:

- we have a `main.jl` where the function `main` depends on 2 hyper-parameters:  `n_stride` and `n_loop`. 
- We want to make an experiment exploring all combinations comprising the following hyper-parameters:
  -  `n_loop = [100,200,300,400]` 
  -  `n_stride=[2,4,6]`

- For each combination of `n_loop` and `n_stride`  we want to execute `main.jl` and generate a file containing the results in  `result.out`.

  

##### `input.inp`

```
n_loop = 100
n_stride = 2
irrelevant_variable = 27
```

##### `main.jl`

```
input_information = read_input("input.inp")

function main(input_information)
	aux = 0
	for i in 1:input_information.n_stride:input_information.n_loops
		aux+=i
	end
	return aux
end

struct InputInformation
	n_loops::Int
	n_stride::Int
end

input_information = InputInformation(100,2)
aux = main(input_information)

print("res=",aux)
```

##### `result.out`

```
res=2500
```





### Using regular expressions

```
n_loop   = 2
n_stride = 2
irrelevant_variable = 27
```



```
f_IN      = open("file_input.inp","r");
file_as_string = read(f_IN, String);
close(f_IN)

hyperparam_dict = Dict(:n_loop => [100,200,300], :n_stride => [2,3])
all_combinations = [x for x in Iterators.product(values(hyperparam_dict)...)]

hyperparams = keys(hyperparam_dict)

configurations = []
for  combination in all_combinations
    new_exp = deepcopy(file_as_string)
    for (param,value) in zip(hyperparams, combination)  
	      println(Regex("$param.*=.*") )
			  replace(new_exp, Regex("$param.*=.*") => "param = $value")
		end
		push!(configurations, new_exp)
end
```



Notice that `r"$param"` is not  `r"n_loop"` . In order to interpolate a variable inside a string in a  regular expression you need to call `Regex` . Therefore `Regex("$param")`   is `r"n_loop"`. 



```
r"$param\s*=\s*\d*"
r"$param\s*=\s*\d*"

```





### Tagging `input.inp`

Once the user specifies a set of possible values ()

```
mutable struct HyperparamGrid 
	name::Symbol
	exp::Expr
end
```



```
macro hyperparam()
    return :( println("Hello, world!") )
end
```



##### `input.inp`

Given the following annotations

```
# inside file_input.inp
@hyperparam n_loop = 100:100:500
@hyperparam n_stride = [2,3,4] 
irrelevant_variable = 27
```











```
# inside file_input.inp
hyperparams = []
@hyperparam n_loop = 100:100:500
@hyperparam n_stride = [2,3,4] 
irrelevant_variable = 27

```









```
# inside file_input.inp
hyperparams = []

n_loop = 100:100:500
n_stride = [2,3,4] 
irrelevant_variable = 27

```



```
julia> aux = Meta.parse(" add_hyperparameter(hyperparams, exp)")

```





```
s = " add_hyperparameter(hyperparams, a = 1:10)"
hyperparams = []

function add_hyperparameter(hyperparams, exp:Expr)
	push!(hyperparams, 1:10 )
end

```









```
f_IN      = open("file_input.inp","r");
file_as_string = read(f_IN, String);
close(f_IN)
array_of_strings = split(file_as_string,"\n")

for i in 1:size(array_of_strings,1)
    eval(Meta.parse(array_of_strings[i]))        
end;
    
```





we would like to internally get the information creating two types

```
HyperparamGrid(:a, :(1:10),eval(:(1:10)))
HyperparamGrid(:a, :(1:10), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

HyperparamGrid(:n_stride, :([2,3,4]),eval(:([2,3,4])))
HyperparamGrid(:n_stride, :([2, 3, 4]), [2, 3, 4])
```

Then, from the set of possible values

```
a_values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
b_values = [2, 3, 4]
```

we can create all the combinations of values using `Iterators.product`

```
all_combinations = [x for x in Iterators.product(a_values, b_values)]
10×3 Array{Tuple{Int64,Int64},2}:
 (1, 2)   (1, 3)   (1, 4) 
 (2, 2)   (2, 3)   (2, 4) 
 (3, 2)   (3, 3)   (3, 4) 
 (4, 2)   (4, 3)   (4, 4) 
 (5, 2)   (5, 3)   (5, 4) 
 (6, 2)   (6, 3)   (6, 4) 
 (7, 2)   (7, 3)   (7, 4) 
 (8, 2)   (8, 3)   (8, 4) 
 (9, 2)   (9, 3)   (9, 4) 
 (10, 2)  (10, 3)  (10, 4)
```



Notice that if we have an array of arrays containing all possible values, we can do the same:

```,&quot;
a_values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
b_values = [2, 3, 4]
c_values = ["p", "q"]

hyperparam_values = [a_values, b_values, c_values]
all_combinations = [x for x in Iterators.product(hyperparam_values...)]
10×3×2 Array{Tuple{Int64,Int64,String},3}:
[:, :, 1] =
 (1, 2, "p")   (1, 3, "p")   (1, 4, "p") 
 (2, 2, "p")   (2, 3, "p")   (2, 4, "p") 
 (3, 2, "p")   (3, 3, "p")   (3, 4, "p") 
 (4, 2, "p")   (4, 3, "p")   (4, 4, "p") 
 (5, 2, "p")   (5, 3, "p")   (5, 4, "p") 
 (6, 2, "p")   (6, 3, "p")   (6, 4, "p") 
 (7, 2, "p")   (7, 3, "p")   (7, 4, "p") 
 (8, 2, "p")   (8, 3, "p")   (8, 4, "p") 
 (9, 2, "p")   (9, 3, "p")   (9, 4, "p") 
 (10, 2, "p")  (10, 3, "p")  (10, 4, "p")

[:, :, 2] =
 (1, 2, "q")   (1, 3, "q")   (1, 4, "q") 
 (2, 2, "q")   (2, 3, "q")   (2, 4, "q") 
 (3, 2, "q")   (3, 3, "q")   (3, 4, "q") 
 (4, 2, "q")   (4, 3, "q")   (4, 4, "q") 
 (5, 2, "q")   (5, 3, "q")   (5, 4, "q") 
 (6, 2, "q")   (6, 3, "q")   (6, 4, "q") 
 (7, 2, "q")   (7, 3, "q")   (7, 4, "q") 
 (8, 2, "q")   (8, 3, "q")   (8, 4, "q") 
 (9, 2, "q")   (9, 3, "q")   (9, 4, "q") 
 (10, 2, "q")  (10, 3, "q")  (10, 4, "q")
```





































```
s1 ="a = 213 # this is a line"
s2 ="@add_hyperparam 1:10; a = 213 # this is a line"
```





```
julia> s2 ="@combinations 1:10 a = 213 # this is a line"
"@combinations 1:10 a = 213 # this is a line"

julia> expression_from_line = Meta.parse(s2)
:(#= none:1 =# @combinations 1:10 a = 213)

julia> expression_from_line.args
4-element Array{Any,1}:
 Symbol("@combinations")
 :(#= none:1 =#)        
 :(1:10)                
 :(a = 213)             

julia> Meta.parse(s2).args[1]
Symbol("@combinations")

julia> Meta.parse(s2).args[2]
:(#= none:1 =#)

julia> Meta.parse(s2).args[3]
:(1:10)
```

