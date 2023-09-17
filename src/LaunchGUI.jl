using Interact, Blink, CSSUtil, LibSerialPort, Distributed
# to control maintain an open communication Arduino without freezing the current terminal we need additional processes
nprocs() != 2 && addprocs(3, exeflags="--project")
workers()
println(workers())
#= every process has an independet library upload. We can use @everywhere to load libraries in all processes
the first step is always to activate the PKG library on the new processes, or we can't upload anything else=#
@everywhere using Pkg
@everywhere Pkg.activate(".")
# The following basic libraries need to work on all processes
@everywhere using LibSerialPort
@everywhere import Dates.today, Dates.Date

global ports_available = get_port_list()
#create a vector of booleans for each process, used to open and close communications with serial ports. Warnig max is 8
global ArduinosController = falses(length(ports_available))
# #create a dictionary to bind each serial port to an index on the ArduinoController vector
global Arduino_dict = Dict(k => v for (k,v) in zip(get_port_list(),1:length(get_port_list())))
# The following files contain functions needed in all processes. Files have to be loaded in order: DataStructures followed by ArduinoCommunication
@everywhere include("structure_files.jl")
@everywhere include("communication_files.jl")

# the following functions and values define the GUI and are only loaded in the main process
include("GUI_files.jl")
##
#= A gui is build combining multiple structures. These structures distinguished by the type of info about 
the experiment that they define.=#
# The Frequencies structure defines
f = FreqStruct()
#The session structure has info about the day, subject name and it combinesthem to define the output file location
s = SessionStruct()
p = PeriodStruct(2,10,2,3, 2)
es = ExpStruct(s,p,f)
# es = ExpStruct(f, s, 60,600,60,10, 50)
w_ex = widget(es);
w = Window();body!(w, fetch(w_ex));
##

##
ex = w_ex[]
Ard = ex.Session.Arduino
running(Ard)
running!(Ard,false)
stimvolumes = ex.StimulatedVolumes
unstimvolumes = ex.UnstimulatedVolumes
stimulations = ex.Frequencies.Stimulations
prestim = ex.PreStimVolumes
instim = ex.InStimVolumes
poststim = ex.PostStimVolumes
stimfreq1 = rm_missing(ex.Frequencies.Frequency1)
stimdur1 = rm_missing(ex.Frequencies.Volumes1)
stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
stimdur2 = rm_missing(ex.Frequencies.Volumes2)
maskled = rm_missing(ex.Frequencies.MaskLed)
filename = ex.Session.FileName
##
p = PeriodStruct()
w_p = widget(p)
w2 = Window();body!(w2, fetch(w_p));

w_p[]
##
es, a_d, a_c = laser_gui();
es
a_d
a_c
es[]
ex = es[]
Ard = ex.Session.Arduino

stimvolumes = ex.Periods.StimulatedVolumes
unstimvolumes = ex.Periods.UnstimulatedVolumes
prestim = ex.Periods.PreStimVolumes
instim = ex.Periods.InStimVolumes
poststim = ex.Periods.PostStimVolumes
stimulations = ex.Frequencies.Stimulations
stimfreq1 = ex.Frequencies.Frequency1
stimdur1 = rm_missing(ex.Frequencies.Volumes1)
stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
stimdur2 = rm_missing(ex.Frequencies.Volumes2)
maskled = rm_missing(ex.Frequencies.MaskLed)
filename = ex.Session.FileName
running(Ard)