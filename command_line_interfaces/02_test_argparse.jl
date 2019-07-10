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
