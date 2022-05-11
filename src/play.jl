using Revise, Interact, Blink, CSSUtil, LibSerialPort
using  Distributed

nprocs() != 3 && addprocs(2,exeflags="--project")
workers()
@everywhere using Pkg   # required
@everywhere Pkg.activate(".")
@everywhere using LibSerialPort
@everywhere import Dates.today, Dates.Date
@everywhere include("StimulationStructure.jl")
@everywhere include("FunsForWorker.jl")
include("StimProtocols.jl")
include("ExpWidgets.jl")
##
f = FreqStruct(s1)
s = SessionStruct()
es = ExpStruct(f,s,60,30)
w_ex = widget(es); w = Window(); body!(w,fetch(w_ex))
##
ex = w_ex[]
running!(ex.Session.Arduino,true)
task = @spawnat :any run_opto(ex)
fetch(task)
running!(ex.Session.Arduino,false)

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
