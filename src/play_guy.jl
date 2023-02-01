using Revise, Distributed
# this allows to create separate process so that you can run the opto on process 2 while keep using Julia pn process 1
 # add a process if there are less than 2
nprocs() != 3 && addprocs(2)
@everywhere using ControlArduino
##
ui = button()
ui[]
w = Window()
##
folders = Dict("ArduinoControlDir" => joinpath("Users","dariosarra","Desktop","ArduinoControlDir"))
dir_ui = dropdown(folders);
mouseid_ui = textbox("mouse_id");
layout_format = hbox(pad(1em,dir_ui),pad(1em,vbox("Subject ID",mouseid_ui)));
body!(w, layout_format);
##
default_dir = joinpath("C:\\Users","precl","OneDrive","Documents","OptoRawData")
isdir(default_dir)
