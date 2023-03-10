mutable struct PeriodStruct
    PreStimVolumes::Union{Int64,Missing}
    InStimVolumes::Union{Int64,Missing}
    PostStimVolumes::Union{Int64,Missing}
    StimulatedVolumes::Union{Int64,Missing}
    UnstimulatedVolumes::Union{Int64,Missing}
end

function PeriodStruct(missing)
    PeriodStruct(missing,missing,missing,missing,missing)
end

PeriodStruct()= PeriodStruct(missing)