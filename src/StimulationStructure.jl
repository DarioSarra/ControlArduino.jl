struct StimStruct
    Frequency::Union{Int64,Missing}
    VolumesOn::Union{Int64,Missing}
    VolumesOff::Union{Int64,Missing}
end

StimStruct(Frequency::Int64, VolumesOn::Int64, VolumesOff::Int64)
StimStruct(missing) = StimStruct(missing,missing,missing)

struct ExpStruct
    LaserNum::Union{Int64,Missing}
    MouseID::Union{AbstractString,Missing}
    Day::Union{AbstractString,Missing}
    DailySession::Union{AbstractString,Missing}
    DailyFile::Union{Char,Missing}
    Weight::Union{Int64,Missing}
    Directory::Union{AbstractString,Missing}
    FileName::Union{AbstractString,Missing}
    StimulatedVolumes::Union{Int64,Missing}
    UnstimulatedVolumes::Union{Int64,Missing}
    Stimulation::Array{StimStruct}
end

const default_dir = joinpath(@__DIR__, "..", "raw_data") ##filepath default and goes up one

function ExpStruct(mouse::String,
    DailySession::String,
    weight::Int64,
    LaserNum::Int64,
    Prwd1::Int64,
    Psw1::Int64,
    Prwd2::Int64,
    Psw2::Int64,
    Delta::Int64,
    barr::Bool,
    stim::Bool,
    p_trk::Bool;
    dir = default_dir)

    d = replace(string(Dates.today()), "-"=>"")
    session =  mouse*"_"*d
    i = 97
    filename = joinpath(dir,session*Char(i)*".txt")
    while ispath(filename)
        i = i+1
        filename = joinpath(dir,session*Char(i)*".txt")
    end
    ExpStruct(mouse,
    d,
    DailySession,
    Char(i),
    weight,
    LaserNum,
    Prwd1,
    Psw1,
    Prwd2,
    Psw2,
    Delta,
    barr,
    stim,
    p_trk,
    filename)
end

function ExpStruct(missing)
    ExpStruct(
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing)
end
