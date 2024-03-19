using DataFrames

function alignIntersect(a::AbstractDataFrame,b::AbstractDataFrame)
    cols = intersect(names(a), names(b))
    aa = a[:,cols]
    bb = b[:,cols]
    return(aa, bb)
end

function dfExtendMissing(df, cols)
    dfc = copy(df)
    for c in cols
        if c in names(df)
            c
        else
            dfc[!,c] .= missing
        end
    end
    dfc[!,cols]
end

function alignUnion(a::AbstractDataFrame,b::AbstractDataFrame)
    cols = union(names(a), names(b))
    aa = dfExtendMissing(a, cols)
    bb = dfExtendMissing(b, cols)
    return(aa, bb)
end

