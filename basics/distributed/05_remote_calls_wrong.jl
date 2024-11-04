using Distributed 

@everywhere function imaginary_compute(x)
           sleep(x)
           return x
end
       

println("nprocs = $(nprocs())")
procs = addprocs([("dbuchaca@192.168.100.124",6)], dir="/home/dbuchaca", exename="/home/dbuchaca/julia-1.10.3/bin/julia")
println("Added processess = $(procs)")
println("nprocs = $(nprocs())")


values = [5,6,7,8]
futures = []

@time begin 
	for value in values
		future = remotecall(imaginary_compute, :any, value)
		push!(future, futures)
	end
	
	for (value,future) in zip(values,futures)
		res = fetch(future)
		println("result for $(value) is $(res)")
	end
end
