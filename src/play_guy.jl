using Revise, ControlArduino

ui = button()
ui[]
w = Window()


##
/Users/dariosarra/Desktop
folders = Dict("ArduinoControlDir" => joinpath("Users","dariosarra","Desktop","ArduinoControlDir"))
dir_ui = dropdown(folders);
mouseid_ui = textbox("mouse_id");
layout_format = hbox(pad(1em,dir_ui),pad(1em,vbox("Subject ID",mouseid_ui)));
body!(w, layout_format);
