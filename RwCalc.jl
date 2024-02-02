# Calculation of Rw from a spectrum
# From ISO 717-1
using OrderedCollections

# Reference curve 
refCurve = OrderedDict([100 => 33,
            125 => 36,
            160 => 39,
            200 => 42,
            250 => 45,
            315 => 48,
            400 => 51,
            500 => 52,
            630 => 53,
            800 => 54,
            1000 => 55,
            1250 => 56,
            1600 => 56,
            2000 => 56,
            2500 => 56,
            3150 => 56])

CtrAdjThird = OrderedDict([100 => -20,
            125 => -20,
            160 => -18,
            200 => -16,
            250 => -15,
            315 => -14,
            400 => -13,
            500 => -12,
            630 => -11,
            800 => -9,
            1000 => -8,
            1250 => -9])

CtrAdjOct = OrderedDict([125=>-14, 250=> -10, 500=> -7, 1000=>-4, 2000=>-6])

function cDiff(s, ref, adj=0)
    local cumdiff = 0
    for (f, v) in pairs(s)
        diff = ref[f] - v + adj
        if diff > 0
            cumdiff += diff
            #println(diff)
        end
    end
    cumdiff
end

function rwPlusCtr(spec)
    bandVals = [10 ^ ( (CtrAdjOct[f] - spec[f]) / 10) for f in keys(spec)]
    return 10*log10(sum(bandVals))
end

function rw(spec)
    adjVal = maximum([spec[f] - refCurve[f] for f in keys(spec)])
    d = cDiff(spec, refCurve, adjVal)
    #println("Starting at $adjVal with sum diff at $d")
    while(d>2*length(spec))
        adjVal-=1
        d = cDiff(spec, refCurve, adjVal)
        #println("adj=$adjVal :: sum diff=$d")
    end
    refCurve[500]+adjVal
end

    