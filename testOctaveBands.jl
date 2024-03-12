using Test, Unitful

include("OctaBands.jl")
using .OctaBands

bs1 = OctaBands.BandSpec([125,250,500,1000.],[1.0,2,3,4]) 
@test bs1.values == [1.0,2.0,3.0,4.0]

bs2 = OctaBands.BandSpec([250,500,1000],[2.0,3.0,4.0])
@test all(isapprox.((bs1+bs2).values, [5.0,6.0,7.0],rtol=0.1))

obs = OctaBands.OctSpec([63,125,250,500,1000,2000,4000,8000], [40,40,40,40,40,40,40,40])
