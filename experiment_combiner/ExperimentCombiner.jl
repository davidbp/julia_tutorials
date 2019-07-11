module ExperimentCombiner

export create_configuration_inputs, generate_configuration_files

function create_configuration_name(i, combination, hyperparams, n_digits, param_separator, value_separator)
    configuration_name = join(string.(hyperparams) .* "$value_separator" .* string.(combination), "$param_separator") * ".inp"
    configuration_name = string(i, pad=n_digits) *  "$param_separator" * configuration_name
    return configuration_name
end


function generate_configuration_files(file_as_string, hyperparam_dict; 
                                      param_separator = "__", value_separator="=")

    all_combinations = [x for x in Iterators.product(values(hyperparam_dict)...)]
    hyperparams = [x for x in keys(hyperparam_dict)]
    
    configurations = []
    configuration_file_names = []
    n_digits = length(string( length(all_combinations)))

    for (i,combination) in enumerate(all_combinations)
        new_conf = deepcopy(file_as_string)
        combination_file_name = create_configuration_name(i, combination, hyperparams,
                                                          n_digits, param_separator, value_separator)

        for (param,value) in zip(hyperparams, combination)  
            new_conf = replace(new_conf, Regex("$param" * "\\s.*=.*") => "$param = $value ")        end

        push!(configurations, new_conf)
        push!(configuration_file_names, combination_file_name)
    end

    return configurations, configuration_file_names
end


function create_configuration_inputs(file_as_string, hyperparam_dict; folder_path= "", folder_name="configuration_inputs",
                                      param_separator = "__", value_separator="=")

    configurations, configuration_file_names =  generate_configuration_files(file_as_string, hyperparam_dict, 
                                                                             param_separator = "__", value_separator="=")

    configurations_path =  length(folder_path)==0 ? joinpath(pwd(),folder_name)  :  joinpath(folder_path, folder_name)    
    mkdir(configurations_path)

    for (configuration, file_name) in zip(configurations, configuration_file_names)
        configuration_path = joinpath(configurations_path, file_name)
        
        open(configuration_path, "w") do f
            write(f, configuration)
        end
    end

end


end