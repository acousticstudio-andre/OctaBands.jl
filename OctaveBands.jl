

module OctaveBands

    using OrderedCollections
    using Unitful

    @derived_dimension UFreq inv(Unitful.𝐓)


    
    # FreqBands = OrderedDict{UFreq, Number}

    function FreqBands(fc::Vector{T} where T <: UFreq, v::Vector{T} where T <: Number)
        OrderedDict([k=>v for (k,v) in zip(fc,v)])
    end

    # assume Hz if unit not given
    function FreqBands(fc::Vector{T} where T <: Real , v::Vector{T} where T <: Number)
        OrderedDict([k*u"Hz"=>v for (k,v) in zip(fc,v)])
    end

    # Frequency weighting
    octFreq = [8, 16, 31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]u"Hz"
	octWeightData = Dict(
		:Z => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]u"dB", 
		:A => [-77.8, -56.7, -39.4, -26.2, -16.1, -8.6, -3.2, 0.0, 1.2, 1.0, -1.1, -6.6]u"dB", 
		:C => [-17.7, -8.5, -3.0, -0.8, -0.2, 0.0, 0.0, 0.0, -0.2, -0.8, -3.0, -8.5]u"dB")


    # third octave

    thirdOctFreq = [12.5, 16, 20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250,
    315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000,
    5000, 6300, 8000, 10000, 12500, 16000, 20000]u"Hz"

	thirdOctWeightData = Dict(
		:Z => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]u"dB", 
		:A => [-85.4, -77.8, -70.4, -63.4, -56.7, -50.5, -44.7, -39.4, -34.6, -30.2, -26.2, -22.5, -19.1, -16.1, -13.4, -10.9, -8.6, -6.6, -4.8, -3.2, -1.9, -0.8, 0.0, 0.6, 1.0, 1.2, 1.3, 1.2, 1.0, 0.5, -0.1, -1.1, -2.5, -4.3, -6.6, -9.3]u"dB", 
		:C => Any[-21.3, -17.7, -14.3, -11.2, -8.5, -6.2, -4.4, -3.0, -2.0, -1.3, -0.8, -0.5, -0.3, -0.2, -0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.1, -0.2, -0.3, -0.5, -0.8, -1.3, -2.0, -3.0, -4.4, -6.2, -8.5, -11.2]u"dB")


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

    function OctSpec(fc::Vector{T} where T, v::Vector{T} where T <: Number)
        bs = FreqBands(fc, v) 
        bandMatch!(bs.keys, octFreq)
        bs
    end

    function Unitful.uconvert(Utarget::Any, bs::OrderedDict{T,S} where {T, S <: Number})
        OrderedDict([k=>Unitful.uconvert(Utarget,v) for (k,v) in (bs)])
    end

    import Base.+
    function +(x::OrderedDict{T,S} where {T, S <: Number}, y::OrderedDict{T,S} where {T, S <: Number})
        k = intersect(x.keys,y.keys)
        OrderedDict([kk=>x[kk]+y[kk] for kk in k])
    end

    function specWeight(x::OrderedDict{T,S} where {T, S <: Number}; weighting=:A)
        # how does this select between OB or TOB? 
        # There should be an abstract type with the functionality
        # and this is then instantiated to TOB or OB
        k = intersect(x.keys, )
        OrderedDict(intersect(x.keys,))
    end
end