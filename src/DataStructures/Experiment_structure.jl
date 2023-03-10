mutable struct ExpStruct
    Session::SessionStruct
    Periods::PeriodStruct
    Frequencies::FreqStruct
end

function ExpStruct(missing)
    ExpStruct(SessionStruct(),PeriodStruct(), FreqStruct())
end

ExpStruct()= ExpStruct(missing)