const default_dir = joinpath("C:\\Users","precl","OneDrive","Documents","OptoRawData")
mutable struct SessionStruct
    MouseID::Union{String,Missing}
    Weight::Union{Real,Missing}
    Day::Union{String,Missing}
    Directory::Union{String,Missing}
    FileName::Union{String,Missing}
    Arduino::Union{String,Missing}
end

# SessionStruct(MouseID::String,Weight::Real,Today::String, filename::String, Arduino::String) =  SessionStruct(MouseID,Weight,Today, filename, Arduino)

function createfilename(MouseID::String,Today::String, Directory::String)
    isdir(Directory) || error("Directory not found")
    session = MouseID*"_"*Today
    i = 97
    filename = joinpath(Directory,session*Char(i)*".csv")
    while ispath(filename)
        i = i+1
        filename = joinpath(Directory,session*Char(i)*".csv")
    end
    return filename
end

function SessionStruct(MouseID::String, Weight::Real,Today::Date,Directory::String,Arduino::String)
    filename = createfilename(MouseID, replace(string(Today), "-"=>""), Directory)
    SessionStruct(MouseID,Weight,string(Today), Directory, filename, Arduino)
end
SessionStruct(MouseID::String,Weight::Real,Arduino::String) = SessionStruct(MouseID, Weight,today(),isdir(default_dir) ? default_dir : @__DIR__,Arduino)
SessionStruct(missing) = SessionStruct(missing,missing,missing,missing,missing, missing)
SessionStruct() = SessionStruct(missing)

mutable struct FreqStruct
    Frequency1::Vector{Union{Int64,Missing}}
    Volumes1::Vector{Union{Int64,Missing}}
    Frequency2::Vector{Union{Int64,Missing}}
    Volumes2::Vector{Union{Int64,Missing}}
    Stimulations::Int64
end

FreqStruct(missing) = FreqStruct([missing],[missing],[missing],[missing],0)
FreqStruct() = FreqStruct(missing)
FreqStruct(Frequency1::Int64, Volumes1::Int64,Frequency2::Int64,Volumes2::Int64) = FreqStruct([Frequency1],[Volumes1],[Frequency2],[Volumes2],1)
FreqStruct(t::NTuple{4,Int64}) = FreqStruct(t..., 1)
function FreqStruct(t::NTuple{4,Vector{Int64}})
    equal_length(t) || error("feeded unequal length arrays")
    FreqStruct(t..., length(t[1]))
end
function FreqStruct(t::Vector{NTuple{4,Int64}})
    Frequency1,Frequency2,Volumes1,Volumes2 = [Int64[] for _ = 1:4]
    for x in t
        push!(Frequency1,x[1])
        push!(Volumes1,x[2])
        push!(Frequency2,x[3])
        push!(Volumes2,x[4])
    end
    FreqStruct(Frequency1,Volumes1,Frequency2,Volumes2,length(t))
end


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
