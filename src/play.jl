using Revise, Distributed
# this allows to create separate process so that you can run the opto on process 2 while keep using Julia pn process 1
 # add a process if there are less than 2
nprocs() != 3 && addprocs(2; exeflags="--project")
@everywhere using Pkg   # required
@everywhere Pkg.activate(".")
@everywhere using ControlArduino
##
test1 = SessionStruct("test", 54.0)
running(1)
##
replace(string(today()), "-"=>"")


list_ports()
ports = get_port_list()

sp = LibSerialPort.open("COM4", 115200)
set_read_timeout(sp, 5)
bytesavailable(sp) > 0 && readline(sp)
write(sp, 'S')


close(sp)
sp_flush(sp,SP_BUF_INPUT)
