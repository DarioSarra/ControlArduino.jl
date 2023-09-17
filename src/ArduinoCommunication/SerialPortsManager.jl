
#function take the runing state of the Arduino from the main process
function running(Arduino_port)
    @fetchfrom 1 ArduinosController[get(Arduino_dict,Arduino_port,0)]
end
#function change the runing state of the Arduino from process 2
function running!(Arduino_port, val)
    @fetchfrom 1 ArduinosController[get(Arduino_dict,Arduino_port,0)] = val
end