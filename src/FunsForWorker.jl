Arduino_dict = Dict(1 => "/dev/ttyACM1",
    2 => "/dev/ttyACM2",
    3 => "/dev/ttyACM0",
    4 =>"COM4", 5 => "COM5")
#function take the runing state of the Arduino from process 2
running(Arduino_port) = @fetchfrom 1 ArduinosController[Arduino_port]
#function change the runing state of the Arduino from process 2
running!(Arduino_port, val) = @fetchfrom 1 ArduinosController[Arduino_port] = val

function run_opto(Arduino_port)
    port = SerialPort(Arduino_dict[Arduino_port])
    open(port)
    LibSerialPort.set_speed(port,115200)
    LibSerialPort.set_flow_control(port, rts = SP_RTS_ON,dtr = SP_DTR_ON)
    # port = LibSerialPort.open(Arduino_dict[Arduino_port],115200)
    println("Opening Port")
    println("Status $(running(Arduino_port))")
    bytesavailable(port) > 0 && println("bytesavailable")
    @async begin
        while running(Arduino_port)
            @async begin
                if bytesavailable(port) > 0
                    m = readuntil(port,'\n')
                    println(m)
                    sleep(0.01)
                    if contains(m,"Waiting for Inputs")
                        println("matched")
                        sleep(0.01)
                        send_m(port,42)
                        send_m(port,60)
                    end
                    sleep(0.01)
                end
            end
        end
        close(port)
        println("Port $(Arduino_port) closed")
    end
end

function send_m(port,what)
    w = string(what)
    write(port,"<"*w*">")
    sleep(0.1)
end
