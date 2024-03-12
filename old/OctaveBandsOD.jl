module OctaBands

    using OrderedCollections
    using Unitful

    @derived_dimension UFreq inv(Unitful.𝐓)

	abstract type AbstractBandSpec end



	struct BandSpec <: AbstractBandSpec 
        spec::OrderedDict{UFreq, Number}
	end
    
	struct OctBandSpec <: AbstractBandSpec 
        spec::OrderedDict{UFreq, Number}
	end

	struct ThirdOctBandSpec <: AbstractBandSpec 
        spec::OrderedDict{UFreq, Number}
	end
    # FreqBands = OrderedDict{UFreq, Number}

    # generic constructor for Band Spectra
    function (::Type{T})(fc::Vector{T1}, v::Vector{T2} ) where {T<:AbstractBandSpec, T1<:UFreq, T2<:Number} 
        (::T)(OrderedDict([ff => vv for (ff, vv) in zip(fc, v)]))
    end
end
