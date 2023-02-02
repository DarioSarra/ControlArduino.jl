mutable struct ExpStruct
    Frequencies::FreqStruct
    Session::SessionStruct
    StimulatedVolumes::Union{Int64,Missing}
    UnstimulatedVolumes::Union{Int64,Missing}
end

function ExpStruct(missing)
    ExpStruct(FreqStruct(),SessionStruct(),missing,missing)
end

ExpStruct()= ExpStruct(missing)

function equal_length(t::NTuple{4,Vector{Int64}})
    l = length(t[1])
    all([length(x) == l for x in t])
end
