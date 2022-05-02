Arduino_dict = Dict(1 => "/dev/ttyACM1",
    2 => "/dev/ttyACM2",
    3 => "/dev/ttyACM0",
    4 =>"COM4", 5 => "COM5")
#function take the runing state of the Arduino from process 2
running(Arduino_port) = @fetchfrom 1 ArduinosController[Arduino_port]
#function change the runing state of the Arduino from process 2
running!(Arduino_port, val) = @fetchfrom 1 ArduinosController[Arduino_port] = val

function send_m(port,what::Int64)
    w = string(what)
    write(port,"<"*w*">")
    sleep(0.1)
end

function send_m(port,what::Vector{Int64})
    for x in what
        send_m(port,x)
    end
end

function run_opto(Arduino_port,
    StimVolumes,UnstimVolumes,
    StimFreq1, StimDur1,
    StimFreq2, StimDur2,
    filename)
    # StimVolumes%(StimDur1+StimDur2) != 0 && error("amount of stimulated volumes is not a multiple of summed stim durations 1 and 2")
    port = SerialPort(Arduino_dict[Arduino_port])
    try
        open(port)
    catch e
        println(e)
        close(port)
        error("unable to open port")
    end
    LibSerialPort.set_speed(port,115200)
    LibSerialPort.set_flow_control(port, rts = SP_RTS_ON,dtr = SP_DTR_ON) ## Necessary to reset arduino upon opening the port
    println("Opening Port")
    println("Status $(running(Arduino_port))")
    task_begun = false
    @async begin
        while running(Arduino_port)
            @async begin
                if bytesavailable(port) > 0
                    m = readuntil(port,'\n')
                    println(m)
                    sleep(0.001)
                    if contains(m,"Waiting for Inputs")
                        println("Sending inputs: stimvolumes = $stimvolumes, unstimvolumes = $unstimvolumes")
                        sleep(0.001)
                        send_m(port,StimVolumes)
                        send_m(port,UnstimVolumes)
                        send_m(port,StimFreq1)
                        send_m(port,StimDur1)
                        send_m(port,StimFreq2)
                        send_m(port,StimDur2)

                        sleep(0.001)
                    end
                    if task_begun
                        open(filename, "a") do io
                            print(io, m)
                            sleep(0.001)
                        end
                    end
                    if contains(m, "All Good:")
                        task_begun = true
                        sleep(0.001)
                    end
                end
            end
        end
        close(port)
        println("Port $(Arduino_port) closed")
    end
end
