const LaserController = falses(8)
Arduino_dict = Dict(1=>"COM4")
#function take the runing state of the Arduino from process 2
running(Arduino) = @fetchfrom 2 LaserController[Arduino]
#function change the runing state of the Arduino from process 2
running!(Arduino, val) = @fetchfrom 2 LaserController[Arduino] = val

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

    if !port.open
        open(port)
        set_speed(port,115200)
        println("Opening Port")
    end

    println("Wait")
    sleep(0.5)
    read_m(port,file)
    sleep(0.5)
    # write(port,session_specs(ST))
    # sleep(1)

    @async begin
        while LaserController[ST.Arduino]
          if bytesavailable(port) > 0
            m = readuntil(port, '\n', 0.5)
             if occursin("-666",m)
                 println("All is well in $(ST.Arduino)")
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
