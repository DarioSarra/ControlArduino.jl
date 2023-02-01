using Revise, Interact, Blink, CSSUtil, LibSerialPort
using  Distributed

# to control maintain an oper communication Arduino without freezing the current terminal we need additional processes
nprocs() != 3 && addprocs(2,exeflags="--project")
workers()
#= every process has an independet library upload. We can use @everywhere to load libraries in all processes
the first step is always to activate the PKG library on the new processes, or we can't upload anything else=#
@everywhere using Pkg   
@everywhere Pkg.activate(".")
# The following libraries and functions need to work on the other processes, in parallel with the main one
@everywhere using LibSerialPort
@everywhere import Dates.today, Dates.Date
@everywhere include("ArduinoCommunication.jl")
@everywhere include("StimulationStructure.jl")
# the following functions and values define the GUI and are only loaded in the main process 
include("Premade_Stim_Protocols.jl")
include("GUI_elements.jl")
##
#= A gui is build combining multiple structures. These structures distinguished by the type of info about 
the experiment that they define.=# 
# The Frequencies structure defines 
f = FreqStruct(s1)
#The session structure has info about the day, subject name and it combinesthem to define the output file location
s = SessionStruct()
es = ExpStruct(f,s,60,30)
w_ex = widget(es); w = Window(); body!(w,fetch(w_ex))
##
ex = w_ex[]
Ard = ex.Session.Arduino
stimvolumes = ex.StimulatedVolumes
unstimvolumes = ex.UnstimulatedVolumes
stimulations = ex.Frequencies.Stimulations
stimfreq1 = rm_missing(ex.Frequencies.Frequency1)
stimdur1 = rm_missing(ex.Frequencies.Volumes1)
stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
stimdur2= rm_missing(ex.Frequencies.Volumes2)
filename = ex.Session.FileName
##
running!(Ard,true)
task = @spawnat :any run_opto(Ard,
    stimvolumes, unstimvolumes, stimulations,
    stimfreq1,stimdur1,
    stimfreq2,stimdur2,
    filename)
running!(Ard,false)
fetch(task)
maximum(skipmissing(stimfreq1))
##
ex = w_ex[]
running!(ex.Session.Arduino,true)
task = @spawnat :any run_opto(ex)
fetch(task)
running!(ex.Session.Arduino,false)
##
Ard  = "COM4"
Arduino_dict[Ard]
stimvolumes = 20
unstimvolumes = 5
stimulations = 6
stimfreq1 = [12,0,4,12,0,4]
stimdur1 = repeat([5],6)
stimfreq2 = [0,4,12,4,12,0]
stimdur2 = repeat([5],6)
filename = "C:\\Users\\precl\\OneDrive\\Documents\\ArduinoData\\test.csv"

##
running!(Ard,true)
task = @spawnat :any run_opto(Ard,
    stimvolumes, unstimvolumes, stimulations,
    stimfreq1,stimdur1,
    stimfreq2,stimdur2,
    filename)
##
running!(Ard,false)
fetch(task)
