# Arduino_dict = Dict(1 => "/dev/ttyACM1",
#     2 => "/dev/ttyACM2",
#     3 => "/dev/ttyACM0",
#     4 =>"COM4", 5 => "COM5")
const ArduinosController = falses(8)
ports_available = get_port_list()
const Arduino_dict = Dict(k => v for (k,v) in zip(ports_available,1:length(ports_available)))
#function take the runing state of the Arduino from process 2
running(Arduino_port) = @fetchfrom 1 ArduinosController[get(Arduino_dict,Arduino_port,0)]
#function change the runing state of the Arduino from process 2
running!(Arduino_port, val) = @fetchfrom 1 ArduinosController[get(Arduino_dict,Arduino_port,0)] = val

function send_m(port,what::Int64)
    w = string(what)
    write(port,"<"*w*">")
end

function send_m(port,what::Vector{Int64})
    for x in what
        send_m(port,x)
    end
    sleep(1)
end

function run_opto(Arduino_port,
    StimVolumes,UnstimVolumes,Stimulations,
    StimFreq1, StimDur1,
    StimFreq2, StimDur2,
    filename)
    # StimVolumes%(StimDur1+StimDur2) != 0 && error("amount of stimulated volumes is not a multiple of summed stim durations 1 and 2")
    port = SerialPort(Arduino_port)
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
                        @async begin
                            println("Sending inputs: stimvolumes = $stimvolumes, unstimvolumes = $unstimvolumes")
                            send_m(port,StimVolumes)
                            send_m(port,UnstimVolumes)
                            send_m(port,Stimulations)
                            send_m(port,StimFreq1)
                            send_m(port,StimDur1)
                            send_m(port,StimFreq2)
                            send_m(port,StimDur2)
                            sleep(0.001)
                        end
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
