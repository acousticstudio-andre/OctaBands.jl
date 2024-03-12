module OctaBands

    export BandSpec, OctSpec
    using Parameters, StaticArrays 
    using Unitful
    using Unitful: W, m, Pa, dB, Decibel, @logunit

    abstract type AbstractSampledSpec end

    @logunit dBSIL "dBSIL" Decibel 1e-12W/m^2

	struct BandSpec{T, S} <: AbstractSampledSpec
		bands::Vector{Float64}
		values::Vector{T}
        ISOtype::S
	end

    function BandSpec(bands::AbstractVector{T}, values::AbstractVector{S}, ISOType::Symbol, units::Union{Unitful.Units,Unitful.MixedUnits}) where {T <: Real, S <: Number, U <: }
        BandSpec(Array(convert.(Float64,bands)), Array(values), ISOType, units)
    end

    function BandSpec(bands::AbstractVector{S}, values::AbstractVector{T}, ISOType::Symbol) where {T, S<:Real}
        BandSpec(Array(convert.(Float64,bands)), Array(values), ISOType, dBSIL)
    end

    function BandSpec(bands::AbstractVector{S}, values::AbstractVector{T}) where {T, S <: Real }
        BandSpec(bands, values, :none)
    end
    
    # Frequency weighting
    ISObandFreq = Dict(:oct => [8, 16, 31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000],
                       :third => [12.5, 16, 20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250,
    315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000,
    5000, 6300, 8000, 10000, 12500, 16000, 20000])
    
	WeightData = Dict(:oct => Dict(
            :Z => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 
            :A => [-77.8, -56.7, -39.4, -26.2, -16.1, -8.6, -3.2, 0.0, 1.2, 1.0, -1.1, -6.6], 
            :C => [-17.7, -8.5, -3.0, -0.8, -0.2, 0.0, 0.0, 0.0, -0.2, -0.8, -3.0, -8.5]),
        :third => Dict(
            :Z => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 
            :A => [-85.4, -77.8, -70.4, -63.4, -56.7, -50.5, -44.7, -39.4, -34.6, -30.2, -26.2, -22.5, -19.1, -16.1, -13.4, -10.9, -8.6, -6.6, -4.8, -3.2, -1.9, -0.8, 0.0, 0.6, 1.0, 1.2, 1.3, 1.2, 1.0, 0.5, -0.1, -1.1, -2.5, -4.3, -6.6, -9.3], 
            :C => Any[-21.3, -17.7, -14.3, -11.2, -8.5, -6.2, -4.4, -3.0, -2.0, -1.3, -0.8, -0.5, -0.3, -0.2, -0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.1, -0.2, -0.3, -0.5, -0.8, -1.3, -2.0, -3.0, -4.4, -6.2, -8.5, -11.2]))


    function bandMatch!(x, y, rtol=.1)
        for ii in axes(x,1)
            ib = argmin(abs.(y.-x[ii]))
            if abs(y[ib] - x[ii])/x[ii] > rtol
                error("band $(x[ii]) does not match ISO bands")
            else
                x[ii] = y[ib]
            end
        end
    end

    function OctSpec(fc::Vector{S}, v::Vector{T} ; units=dBSIL) where {S <: Real, T <: Number}
        bandMatch!(convert.(Float64,fc), ISObandFreq[:oct])
        bs = BandSpec(fc, v, :oct, units) 
    end

    function matchKeys(x::BandSpec, y::BandSpec)
        k = intersect(x.bands, y.bands)
        ix = [findfirst(x.bands.==kk) for kk in k]
        iy = [findfirst(y.bands.==kk) for kk in k]
        (BandSpec(k, x.values[ix], x.ISOtype, x.units),
        BandSpec(k, y.values[iy], y.ISOtype, y.units))
    end

    import Base.+
    function +(x::BandSpec{T} where {T <: Number}, y::BandSpec{T} where {T <: Number})
        (xx, yy) = matchKeys(x,y)
        vv = xx.values * x.units .+ yy.values * y.units
        BandSpec(xx.bands, Unitful.ustrip.(vv), x.ISOtype, Unitful.unit(vv[1]))
    end

    function specWeight(x::BandSpec{T} where {T  <: Number}; weighting=:A)
        y = BandSpec(ISObandFreq[x.ISOtype], WeightData[x.ISOtype][weighting], x.ISOtype, dB)
        (xx, yy) = matchKeys(x,y)
        xx+yy
    end
end