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
Arduino_dict
Ard  = 5
stimvolumes = 5
unstimvolumes = 5
filename = "C:\\Users\\precl\\OneDrive\\Documents\\ArduinoData\\test.csv"
running(Ard)
running!(Ard,true)
task = @spawnat :any run_opto(Ard,stimvolumes, unstimvolumes, filename)
running!(Ard,false)
fetch(task)
##
open("C:\\Users\\precl\\OneDrive\\Documents\\ArduinoData\\test.csv","a") do io
    print(io,"test")
end
