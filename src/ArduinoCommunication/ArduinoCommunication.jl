function run_opto(Arduino_port::String,
    StimVolumes::Int64,UnstimVolumes::Int64,Stimulations::Int64,
    StimFreq1::Vector{Int64}, StimDur1::Vector{Int64},
    StimFreq2::Vector{Int64}, StimDur2::Vector{Int64},
    filename::String)
    # StimVolumes%(StimDur1+StimDur2) != 0 && error("amount of stimulated volumes is not a multiple of summed stim durations 1 and 2")
    LightHZ = maximum(skipmissing(StimFreq1))
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
    println("Running Status $(running(Arduino_port))")
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
                            println("Sending inputs: stimvolumes = $StimVolumes, unstimvolumes = $UnstimVolumes")
                            send_m(port,StimVolumes)
                            send_m(port,UnstimVolumes)
                            send_m(port,Stimulations)
                            send_m(port, LightHZ)
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
        open(port)
        close(port)
        println("Port $(Arduino_port) closed")
    end
end

function run_opto(ex::ExpStruct)
    Ard = ex.Session.Arduino
    stimvolumes = ex.StimulatedVolumes
    unstimvolumes = ex.UnstimulatedVolumes
    stimulations = ex.Frequencies.Stimulations
    stimfreq1 = rm_missing(ex.Frequencies.Frequency1)
    stimdur1 = rm_missing(ex.Frequencies.Volumes1)
    stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
    stimdur2= rm_missing(ex.Frequencies.Volumes2)
    filename = ex.Session.FileName

    run_opto(Ard,
        stimvolumes, unstimvolumes, stimulations,
        stimfreq1,stimdur1,
        stimfreq2,stimdur2,
        filename)
end

function rm_missing(x::Vector{Union{Missing,Int64}})
    convert(Vector{Int64}, filter(!ismissing,x))
end
