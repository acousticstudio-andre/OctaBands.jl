using OrderedCollections
include("DictOps.jl")

a = OrderedDict("a"=>1, "b"=>2)
b = Dict("a"=>3, "c"=>4)

alignIntersect(a,b)
alignUnion(a,b)

