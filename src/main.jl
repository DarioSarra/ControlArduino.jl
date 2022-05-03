using Revise, Distributed
nprocs() != 3 && addprocs(1,exeflags="--project")
workers()
@everywhere using Pkg   # required
@everywhere Pkg.activate(".")
@everywhere using LibSerialPort
# @everywhere using ControlArduino
const ArduinosController = falses(8)
##
@everywhere include("FunsForWorker.jl")
##
list_ports()
Ard  = 4
Arduino_dict[Ard]
stimvolumes = 20
unstimvolumes = 5
stimulations = 6
stimfreq1 = [12,0,4,12,0,4]
stimdur1 = repeat([5],6)
stimfreq2 = [0,4,12,4,12,0]
stimdur2 = repeat([5],6)
filename = "C:\\Users\\precl\\OneDrive\\Documents\\ArduinoData\\test.csv"
running(Ard)
##
running!(Ard,true)
task = @spawnat :any run_opto(Ard,
    stimvolumes, unstimvolumes, stimulations,
    stimfreq1,stimdur1,
    stimfreq2,stimdur2,
    filename)
##
running!(Ard,false)
##
fetch(task)
task = @spawnat 2 send_m(stdout,stimfreq1)
fetch(task)
workers()
Distributed.interrupt(7)
##
open("C:\\Users\\precl\\OneDrive\\Documents\\ArduinoData\\test.csv","a") do io
    print(io,"test")
end
stimvolumes%(stimdur1+stimdur2) == 0
typeof(stimdur1)
repeat([stimdur1],6)

#=
<12><0><4><12><0><4>
<5><5><5><5><5><5>
<0><4><12><4><12><0>
<5><5><5><5><5><5>
=#
%6
