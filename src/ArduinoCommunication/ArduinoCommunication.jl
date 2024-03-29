#Open arduino communication in a safe manner. The try loop avoid errors to break the process in case port is not accessible
function open_communication(Arduino_port)
    println("opening communication with $Arduino_port")
    port = SerialPort(Arduino_port)
    try
        open(port)
        LibSerialPort.set_speed(port,115200)
        LibSerialPort.set_flow_control(port, rts = SP_RTS_ON,dtr = SP_DTR_ON) ## Necessary to reset arduino upon opening the port
        println("Opening Port")
        println("Running Status $(running(Arduino_port))")
    catch e
        println(e)
        close(port)
        error("unable to open port")
    end
    return port
end

#This function open communication with arduino and send information about the stimulation parameters in a predermined order
function run_opto(Arduino_port::String,
    PreStim::Int64,InStim::Int64,PostStim::Int64,
    StimVolumes::Int64,UnstimVolumes::Int64,Stimulations::Int64,
    StimFreq1::Vector{Int64}, StimDur1::Vector{Int64},
    StimFreq2::Vector{Int64}, StimDur2::Vector{Int64},
    Pulse::Vector{Int64}, LightHZ::Vector{Int64},
    filename::String)

    port = open_communication(Arduino_port)
    task_begun = false # variable to control writing on the saving file
    @async begin # @async macro ensures workers don't freeze waiting for completion of steps
        #= The while loop used to close port via the Arduino controller booleans. 
        This has to be set to true before launching the function and set to false buy another worker to stop the function=#
        while running(Arduino_port)
            @async begin
                # While running(Arduino_port) we constantly read messages from arduino
                if bytesavailable(port) > 0
                    m = readuntil(port,'\n')
                    println(m) #To have an online read of the ongoing communication we print arduino messages on the terminal
                    sleep(0.001) # brief sleep ensure overlapping transmissions between Arduino and the Software
                    #First the function verifies that arduino is ready to receive messages
                    if contains(m,"Waiting for Inputs")
                        @async begin
                            println("Sending inputs: stimvolumes = $StimVolumes, unstimvolumes = $UnstimVolumes")
                            send_m(port,PreStim) # Volumes before stimulation
                            send_m(port,InStim) # Volumes to stimulate
                            send_m(port,PostStim) # Volumes after stimulation
                            send_m(port,UnstimVolumes) # Num of volumes to wait before and after the stimulation. It doubles in between two stimulations.
                            send_m(port,StimVolumes) # Num of volumes to stimulate
                            send_m(port,Stimulations) # Num of stimulation protocols to feed. Arduino use this num to set the length of vectors storing info
                            #= To have a more fine grain control over the stimulation onset and offset, within the stimulation block two frequency settings
                            are defined. This allows to have a period stimulated at a frequency followed by a period non stimulated or stimulated at a 
                            different frequency. Therefore a protocol is defined by a set of four values: The first stimulation frequency
                            and duration and the second stimukation frequency and duration. To communicate these parameters easily 
                            to arduino, they are grouped by kind in vectors of the same lengths. This allows arduino to use the same index to ensure the
                            corecct pairing of parameters across multiple protocols in a session. In other words the variable "Stimulations" fix is 
                            the length of these vectors=#
                            send_m(port,StimFreq1) # Frequency in Hz of the first stimulation type 
                            send_m(port,StimDur1) # Duration in ms of first stimulation type
                            send_m(port,StimFreq2) # Frequency in Hz of the second stimulation type
                            send_m(port,StimDur2) # Duration in ms of second stimulation type
                            send_m(port,Pulse) # Duration in ms of a stimulation pulse
                            send_m(port,LightHZ) # Vector containing the masking light frequency
                            sleep(0.001) 
                        end
                    end
                    #After transmitting all info we wait for Arduino to confirm carrect reception and set the task to start
                    if contains(m, "All Good:")
                        task_begun = true
                        sleep(0.001)
                    end
                    # Once reception is confirmed and task has begun we write Arduino stream on the output file
                    if task_begun
                        open(filename, "a") do io
                            print(io, m)
                            sleep(0.001)
                        end
                    end
                end
            end
        end
        #As soon as running(Arduino_port) is set to false by the other process we close the port 
        close(port)
        # We open and close the port again to send arduino back to "Waiting for input"
        open(port) 
        close(port)
        println("Port $(Arduino_port) closed")
    end
end


#= The function extracts the information to be send to Arduino from an Experiment structure. 
    The structure has multiple fields and subfields, which is useful to organise the GUI, but can become verbose to call function on it=#
function run_opto(ex::ExpStruct)
    Ard = ex.Session.Arduino
    prestim = ex.PreStimVolumes
    instim = ex.InStimVolumes
    poststim = ex.PostStimVolumes
    stimvolumes = ex.StimulatedVolumes
    unstimvolumes = ex.UnstimulatedVolumes
    stimulations = ex.Frequencies.Stimulations
    stimfreq1 = rm_missing(ex.Frequencies.Frequency1)
    stimdur1 = rm_missing(ex.Frequencies.Volumes1)
    stimfreq2 = rm_missing(ex.Frequencies.Frequency2)
    stimdur2= rm_missing(ex.Frequencies.Volumes2)
    pulsewidth = rm_missing(ex.Frequencies.Pulse)
    ledfreq = rm_missing(ex.Frequencies.MaskLed)
    filename = ex.Session.FileName

    run_opto(Ard,
        prestim, instim, poststim,
        stimvolumes, unstimvolumes, stimulations,
        stimfreq1,stimdur1,
        stimfreq2,stimdur2,
        pulsewidth, ledfreq,
        filename)
end

function rm_missing(x::Vector{Union{Missing,Int64}})
    convert(Vector{Int64}, filter(!ismissing,x))
end
