const ArduinosController = falses(8)
Arduino_dict = Dict(1=>"COM4", 2 => "/dev/ttyACM0")
#function take the runing state of the Arduino from process 2
running(Arduino) = @fetchfrom 2 ArduinosController[Arduino]
#function change the runing state of the Arduino from process 2
running!(Arduino, val) = @fetchfrom 2 ArduinosController[Arduino] = val

function session_specs(ST::SessionStruct)
    sp = [string(ST.Arduino),
    string(ST.Prwd1),
    string(ST.Psw1),
    string(ST.Prwd2),
    string(ST.Psw2),
    string(ST.Delta),
    string(Int64(ST.Barrier)),
    string(Int64(ST.Stimulation)),
    string(Int64(ST.PokesTracking))]
    join(string.('<',sp,'>'))
end

function run_task(ST::SessionStruct)
    port = SerialPort(Arduino_dict[ST.Arduino])
    file = ST.FileName

    if !port.is_open
        open(port)
        set_speed(port,115200)
        println("Opening Port")
    end

    println("Wait")
    sleep(0.5)
    m = read_m(port,file)
    println(m)
    sleep(0.5)
    # write(port,session_specs(ST))
    # sleep(1)

    @async begin
        while ArduinosController[ST.Arduino]
          if bytesavailable(port) > 0
            m = readuntil(port, '\n', 0.5)
            println(readuntil(port, '\n', 0.5))
             if occursin("Type 'S' to start",m)
                 println("All is well in $(ST.Arduino)")
                 write(port,'S')
             end
            open(ST.filename, "a") do io
                print(io, m)
            end
          end
          sleep(0.001)
        end
        close(port)
        println("Box $(ST.Arduino) port closed")
    end
end

function read_m(port,file)
    m = readuntil(port, '\n', 0.5)
    open(file, "a") do io
        print(io, m)
    end
    sleep(1)
    return(m)
end

function send_m(port,what,file)
    write(port,"<"*what*">")
    sleep(1)
end
