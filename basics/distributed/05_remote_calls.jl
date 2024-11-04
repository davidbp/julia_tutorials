
using Distributed


println("nprocs = $(nprocs())")
procs = addprocs([("dbuchaca@192.168.100.124",6)], dir="/home/dbuchaca", exename="/home/dbuchaca/julia-1.10.3/bin/julia")

@everywhere function imaginary_compute(x)
           sleep(x)
           return x, myid(), gethostname(), getpid()
end


println("Added processess = $(procs)")
println("nprocs = $(nprocs())")
println("hosthame = $(gethostname())")

values = [5,6,7,8,9,10]
futures = []

@time begin 
	for value in values
		future = remotecall(imaginary_compute, 5, value)
		push!(futures, future)
	end
	
	for (value,future) in zip(values,futures)
		res, id, hostname, pid = fetch(future)
		println("result for $(value) is $(res), executed in $(id), pid = $(pid), hostname = $(hostname)")
	end
end

