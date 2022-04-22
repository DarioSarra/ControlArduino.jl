using Revise, ControlArduino



list_ports()
ports = get_port_list()

sp = LibSerialPort.open("COM4", 115200)
set_read_timeout(sp, 5)
bytesavailable(sp) > 0 && readline(sp)
close(sp)
sp_flush(sp,SP_BUF_INPUT)
