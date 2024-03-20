using DataFrames
using PrettyTables
using Unitful
using Unitful: W, m, Pa, dB, Decibel, @logunit

@logunit dBSIL "dBSIL" Decibel 1e-12W/m^2

struct ThirdOct end

struct Oct end

abstract type AbstractBandType end 

struct BandFrame{T} <: AbstractBandType 
    data::AbstractDataFrame 
end

function Base.show(io::IO, bf::AbstractBandType) 
    table = pretty_table(io, (Array(bf.data )),
                         header=names(ustrip.(bf.data)))
    print 
end

function BandFrame(df::DataFrame)
    BandFrame{:arb}(df)
end

function OctaveBandFrame(data::Array, startFreq)
    nbands = size(data)[end]
    bands = string.(startFreq .* 2 .^ (0:nbands-1)) .* "Hz"
    df = DataFrame([b=>vals for (b, vals) in zip(bands, eachcol(data))])
    BandFrame{:oct}(df)
end

function add(bf1::T, bf2::T) where {T <: AbstractBandType}
    bftype = typeof(bf1).parameters
    BandFrame{T}(bf1.data .+ bf2.data)
end

