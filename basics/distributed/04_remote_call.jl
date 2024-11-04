using Distributed

println("nprocs = $(nprocs())")
procs = addprocs([("dbuchaca@192.168.100.124",6)], dir="/home/dbuchaca", exename="/home/dbuchaca/julia-1.10.3/bin/julia")
println("Added processess = $(procs)")
println("nprocs = $(nprocs())")

r = remotecall(rand, 2, 2, 2)

