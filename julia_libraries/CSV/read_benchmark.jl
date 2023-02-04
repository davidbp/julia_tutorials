using DataFrames
using CSV

X = rand(128, 1000_000)



# read from disk
df = CSV.read("cell_01.dat", DataFrame, [options go here])

CSV.write("cell_01.dat", df)


