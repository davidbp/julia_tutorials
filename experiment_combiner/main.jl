
## Parsing input file BEGINS ######################################


struct ExperimentHyperparams
    n_loop::Int
    n_stride::Int
    irrelevant_variable::Int
end

function parse_input(filename, symbols_to_retrieve)
    file_input              = open(filename,"r");
    file_as_string          = read(file_input, String);

    for s in symbols_to_retrieve
        if occursin(string(s), file_as_string)==false
            println("\n\tThe hyperparam $s is not in $filename")
        end
    end

    file_as_array_of_string = split(file_as_string, "\n")
    hyperparam_values = Dict()

    for line in file_as_array_of_string
        expression_line = Meta.parse(line)
        if isnothing(expression_line) == false
            #println("\n\texpression_line ", expression_line)

            for s in symbols_to_retrieve
                expression_arguments = expression_line.args

                if s in expression_arguments
                    hyperparam_values[s] = expression_arguments[end]
                end
            end
        end
    end  

    println("\n#The hyperparam_values found in  $filename are ", hyperparam_values)
    experiment_hyperparams = ExperimentHyperparams(hyperparam_values[:n_loop],
                                                   hyperparam_values[:n_stride],
                                                   hyperparam_values[:irrelevant_variable])

    return experiment_hyperparams 
end

## Parsing input file ENDS ######################################




function main(params)
    aux = 0
    for i in 1:params.n_stride:params.n_loop
        aux+=i
    end
    return aux
end


# Passing as input the name of the input file to retrieve the information about the experiment
input_filename = ARGS[1]

# Symbols that we want to retrieve from the configuration file
symbols_to_retrieve = [:n_loop, :n_stride, :irrelevant_variable]

# Parsing the input file
experiment_hyperparams = parse_input(input_filename, symbols_to_retrieve)


# Performing the experiment with the configuration `experiment_hyperparams`
aux = main(experiment_hyperparams)
print("\nres=",aux,"\n")
