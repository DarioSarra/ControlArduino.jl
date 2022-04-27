const default_dir = joinpath("C:\\Users","precl","OneDrive","Documents","OptoRawData")

struct SessionStruct
    Arduino::Union{Int64,Missing}
    MouseID::Union{AbstractString,Missing}
    Weight::Union{Float64,Missing}
    Day::Union{AbstractString,Missing}
    DailySession::Union{Char,Missing}
    SessionName::Union{AbstractString,Missing}
    Directory::Union{AbstractString,Missing}
    FileName::Union{AbstractString,Missing}
end

function SessionStruct(MouseID::String, Weight::Float64; Arduino = 1, Directory = default_dir)

    d = replace(string(Dates.today()), "-"=>"")
    session =  MouseID*"_"*d
    i = 97
    filename = joinpath(Directory,session*Char(i)*".csv")
    while ispath(filename)
        i = i+1
        filename = joinpath(Directory,session*Char(i)*".csv")
    end

    SessionStruct(Arduino, MouseID, Weight, d, Char(i), session, Directory, filename)
end

SessionStruct(missing) = SessionStruct(missing,missing,missing,missing,missing,missing,missing,missing,)

struct FreqStruct
    Frequency::Union{Int64,Missing}
    VolumesOn::Union{Int64,Missing}
    VolumesOff::Union{Int64,Missing}
end

# FreqStruct(Frequency::Int64, VolumesOn::Int64, VolumesOff::Int64)
FreqStruct(missing) = FreqStruct(missing,missing,missing)

struct ExpStruct
    Session::Union{SessionStruct,Missing}
    StimulatedVolumes::Union{Int64,Missing}
    UnstimulatedVolumes::Union{Int64,Missing}
    Stimulation::Array{FreqStruct}
end

function ExpStruct(missing)
    ExpStruct(missing, missing, missing, missing)
end
