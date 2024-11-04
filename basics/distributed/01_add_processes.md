# Distributed computing with Julia

## Adding processes in the local machine

If you open Julia with `julia` you can see that there is a single process

```
using Distributed
nprocs()
```

You see a single process

```
1
```

You can add more processes with `addprocs`. Those processes can be either running locally in the machine that 
is executing Julia or in a remote machine. If you simply use `addprocs()` 

```
addprocs()
```

You will get as many processes as Cores-2 you have in your system.
In this case this is running on an M1 pro with 10 cores and you get

```
8-element Vector{Int64}:
 2
 3
 4
 5
 6
 7
 8
 9
```

## Adding processes in a remote machine

First you need to create an ssh key using

```
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 
```

Then send the public key to a remote machine

```
 ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 22 dbuchaca@192.168.1.147
 ```
 
 After adding the public key you should be able to simply run ` dbuchaca@192.168.1.147`
 
 """
using Distributed
procs = addprocs(["dbuchaca@192.168.1.162", 4], dir="/home/dbuchaca", exename="/home/dbuchaca/julia/bin/julia")
println("Added processess = $(procs)")
println("nprocs = $(nprocs())")  
 """
 
The following code will instanciate a remote process in a remote machine via ssh. You can run  `02_add_1_process_remote.jl`

```
using Distributed

println("nprocs = $(nprocs())")
procs = addprocs(["dbuchaca@192.168.100.124"], dir="/home/dbuchaca", exename="/home/dbuchaca/julia-1.10.3/bin/julia")
println("Added processess = $(procs)")
println("nprocs = $(nprocs())")
```

and see

```
nprocs = 1
Added processess = [2]
nprocs = 2
```


This shows that there is 1 julia process before calling `addprocs(...)`
and there are 2 Julia processes afterwards.


One can add more than a single process in a remote machine using a tuple `(user@ip, k)` to add `k` processes. You can run  `03_add_6_process_remote.jl`

```
using Distributed
println("nprocs = $(nprocs())")
procs = addprocs([("dbuchaca@192.168.1.162",4)], dir="/home/dbuchaca", exename="/home/dbuchaca/julia/bin/julia")
println("Added processess = $(procs)")
println("nprocs = $(nprocs())")
```

This will print

```
nprocs = 1
Added processess = [2, 3, 4, 5, 6, 7]
nprocs = 7
```


## Executing a function in a process

Consider you want to execute the function `imaginary_compute` in parallel in many julia processes.

In  `05_remote_calls.jl` you will find an example that spawns


```
using Distributed 

@everywhere function imaginary_compute(x)
           sleep(x)
           return x, myid
end

println("Added processess = $(procs)")
println("nprocs = $(nprocs())")


values = [5,6,7,8,9,10]
futures = []

@time begin 
	for value in values
		future = remotecall(imaginary_compute, 5, value)
		push!(futures, future)
	end
	
	for (value,future) in zip(values,futures)
		res, id = fetch(future)
		println("result for $(value) is $(res) executed in $(id)")
	end
end
```

Executing the script

```
julia 05_remote_calls.jl 
```

We can see that 6 processes with ids `[2, 3, 4, 5, 6, 7]` will be added. 
Each process will execute but the overall time to execute the 6 function calls will be around 10 seconds.
Serially it would have taken 45 seconds. 

```
nprocs = 1
Added processess = [2, 3, 4, 5, 6, 7]
nprocs = 7
hosthame = bcd07434d6b9
result for 5 is 5, executed in 5, pid = 4385, hostname = macmini02
result for 6 is 6, executed in 5, pid = 4385, hostname = macmini02
result for 7 is 7, executed in 5, pid = 4385, hostname = macmini02
result for 8 is 8, executed in 5, pid = 4385, hostname = macmini02
result for 9 is 9, executed in 5, pid = 4385, hostname = macmini02
result for 10 is 10, executed in 5, pid = 4385, hostname = macmini02
 10.135346 seconds (186.39 k allocations: 12.943 MiB, 1.84% compilation time)
```
