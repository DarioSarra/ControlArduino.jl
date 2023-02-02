#=A frequency structure contains info on the first and second stimulation frequencies and durations. 
Each type of information is stored in separate vectors of the same lenght. The lenght of this vectors has to be equal 
and it's value is stores in the subfield Stimulations. The number of stimulations allows to loop across multiple stimulation types in one run=#

mutable struct FreqStruct
    Frequency1::Vector{Union{Int64,Missing}}
    Volumes1::Vector{Union{Int64,Missing}}
    Frequency2::Vector{Union{Int64,Missing}}
    Volumes2::Vector{Union{Int64,Missing}}
    Stimulations::Int64
end

#A frequency structure can be initiated as empty
FreqStruct(missing) = FreqStruct([missing],[missing],[missing],[missing],0)
FreqStruct() = FreqStruct(missing)

#A frequency structure with only one type of stimulation can be initiated directly with single values for each parameter
FreqStruct(Frequency1::Int64, Volumes1::Int64,Frequency2::Int64,Volumes2::Int64) = FreqStruct([Frequency1],[Volumes1],[Frequency2],[Volumes2],1)

#A frequency structure can be initiated by a tuple of 4 Integer, which fall backs on the single value initiation system
FreqStruct(t::NTuple{4,Int64}) = FreqStruct(t..., 1)

#A frequency structure can be initiated by a tuple of 4 vectors, provided the vectors are the same length
function FreqStruct(t::NTuple{4,Vector{Int64}})
    equal_length(t) || error("feeded unequal length arrays")
    FreqStruct(t..., length(t[1]))
end

#= A frequency structure can be initiated by a vector of tuple of 4 integer. This is the method used by the GUI. 
Each stim column in the GUI defines a protocol. The 4 values are collected in a Tuple, and all columns are collected in a vector=#
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