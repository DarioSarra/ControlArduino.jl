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
p = LibSerialPort.open(Arduino_dict[3],115200)
bytesavailable(p)
t = @async begin
    if bytesavailable(p) > 0
        m = readuntil(p,'\n')
        println(m)
        sleep(0.1)
        if contains(m,"Waiting for Inputs")
            println("matched")
            sleep(0.1)
            send_m(p,42)
            send_m(p,60)
        end
        sleep(0.1)
    end
end
close(p)
##
port = SerialPort(Arduino_dict[Ard])
LibSerialPort.set_speed(port,115200)
LibSerialPort.set_flow_control(port, rts = SP_RTS_ON,dtr = SP_DTR_ON)
open(port)
close(port)
##
list_ports()
Arduino_dict
Ard  = 5
running(Ard)
running!(Ard,true)
task = @spawnat :any run_opto(Ard)
running!(Ard,false)
fetch(task)
##
