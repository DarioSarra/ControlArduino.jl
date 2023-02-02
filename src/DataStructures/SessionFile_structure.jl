#= The main purpose of the session structure is to manage the information to identify the animal, the output file 
and the serial port to be used=#

const default_dir = joinpath("C:\\Users","precl","OneDrive","Documents","OptoRawData")
mutable struct SessionStruct
    MouseID::Union{String,Missing}
    Weight::Union{Real,Missing}
    Day::Union{String,Missing}
    Directory::Union{String,Missing}
    FileName::Union{String,Missing}
    Arduino::Union{String,Missing}
end

#= Using the animal name, the day of the session and a pathway to a directory it creates a unique file name. 
The filename includes a final character used to distinguish multiple runs=#
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

#All field can be created with missing values and populated afterwards
SessionStruct(missing) = SessionStruct(missing,missing,missing,missing,missing, missing)
SessionStruct() = SessionStruct(missing)