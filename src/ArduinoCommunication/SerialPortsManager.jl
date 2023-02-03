ports_available = get_port_list()

#create a vector of booleans for each process, used to open and close communications with serial ports. Warnig max is 8
const ArduinosController = falses(length(ports_available))

#create a dictionary to bind each serial port to an index on the ArduinoController vector
const Arduino_dict = Dict(k => v for (k,v) in zip(ports_available,1:length(ports_available)))

#function take the runing state of the Arduino from the main process
running(Arduino_port) = @fetchfrom 1 ArduinosController[get(Arduino_dict,Arduino_port,0)]
#function change the runing state of the Arduino from process 2
running!(Arduino_port, val) = @fetchfrom 1 ArduinosController[get(Arduino_dict,Arduino_port,0)] = val