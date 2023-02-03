using Revise, Interact, Blink, CSSUtil, LibSerialPort, Distributed
# to control maintain an open communication Arduino without freezing the current terminal we need additional processes
nprocs() != 3 && addprocs(2, exeflags="--project")
workers()
#= every process has an independet library upload. We can use @everywhere to load libraries in all processes
the first step is always to activate the PKG library on the new processes, or we can't upload anything else=#
@everywhere using Pkg
@everywhere Pkg.activate(".")
# The following basic libraries need to work on all processes
@everywhere using LibSerialPort
@everywhere import Dates.today, Dates.Date

# The following files contain functions needed in all processes. Files have to be loaded in order: Structures followed by ArduinoCommunication
@everywhere include(joinpath("DataStructures","SessionFile_structure.jl"))
@everywhere include(joinpath("DataStructures","Frequencies_structure.jl"))
@everywhere include(joinpath("DataStructures","Experiment_structure.jl"))
@everywhere include(joinpath("ArduinoCommunication","SerialPortsManager.jl"))
@everywhere include(joinpath("ArduinoCommunication","MessageEncoding.jl"))
@everywhere include(joinpath("ArduinoCommunication","ArduinoCommunication.jl"))

# the following functions and values define the GUI and are only loaded in the main process 
include(joinpath("GUI", "Premade_Stim_Protocols.jl"))
include(joinpath("GUI", "GUI_utilities.jl"))
include(joinpath("GUI", "SessionWidget.jl"))
include(joinpath("GUI", "FrequencyWidget.jl"))
include(joinpath("GUI", "ExperimentWidget.jl"))
# include(joinpath("GUI", "GUI_elements.jl"))
##
#= A gui is build combining multiple structures. These structures distinguished by the type of info about 
the experiment that they define.=#
# The Frequencies structure defines 
f = FreqStruct(s1)
#The session structure has info about the day, subject name and it combinesthem to define the output file location
s = SessionStruct()
es = ExpStruct(f, s, 60, 30)
w_ex = widget(es);
w = Window();body!(w, fetch(w_ex));
##
ex = w_ex[]
Ard = ex.Session.Arduino
stimvolumes = ex.StimulatedVolumes
unstimvolumes = ex.UnstimulatedVolumes
stimulations = ex.Frequencies.Stimulations
stimfreq1 = rm_missing(ex.Frequencies.Frequency1)
stimdur1 = rm_missing(ex.Frequencies.Volumes1)
stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
stimdur2 = rm_missing(ex.Frequencies.Volumes2)
maskled = rm_missing(ex.Frequencies.MaskLed)
filename = ex.Session.FileName