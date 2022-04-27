using Revise, Distributed
# this allows to create separate process so that you can run the opto on process 2 while keep using Julia pn process 1
# add a process if there are less than 2
using ControlArduino
# nprocs() != 3 && addprocs(2; exeflags="--project")
# @everywhere using Pkg   # required
# @everywhere Pkg.activate(".")
# @everywhere using ControlArduino
##
using LibSerialPort
ST = SessionStruct("test", 54.0)
port = SerialPort(Arduino_dict[ST.Arduino])
if !port.is_open
      open(port)
      set_speed(port,115200)
      println("Opening Port")
end
close(port)
is_running = true
@async begin
    while is_running
        if bytesavailable(port) > 0
            m = readline(port)
            println(m)
        end
    end
end

port.is_open
set_read_timeout(port, 2)
try
    line1 = readuntil(sp, '\n')
    line2 = readuntil(sp, '\n')
catch e
    if isa(e, LibSerialPort.Timeout)
        println("Too late!")
    else
        rethrow()
    end
end
m = readuntil(port, '\r')
close(port)
##
ST = SessionStruct("test", 54.0)
running!(test1.Arduino , true)
task = @spawnat 2 run_task(test1)
running!(test1.Arduino , false)
##
port = SerialPort(Arduino_dict[ST.Arduino])
port.is_open
open(port)
close(port)
@spawnat 2 close(port)
ArduinosController[ST.Arduino]
@fetchfrom 2 ArduinosController[ST.Arduino]
running(1)
##
using LibSerialPort
port = SerialPort(Arduino_dict[ST.Arduino])
file = ST.FileName
if !port.is_open
      open(port)
      set_speed(port,115200)
      println("Opening Port")
  end
 close(port)
##
