module ControlArduino
using Interact,Blink, CSSUtil
using LibSerialPort, Distributed
import Dates.today, Dates.Date
include("structure_files.jl")
include("communication_files.jl")
# the following functions and values define the GUI and are only loaded in the main process 
include("GUI_files.jl")

global ports_available = get_port_list()
#create a vector of booleans for each process, used to open and close communications with serial ports. Warnig max is 8
global ArduinosController = falses(length(ports_available))
# #create a dictionary to bind each serial port to an index on the ArduinoController vector
global Arduino_dict = Dict(k => v for (k,v) in zip(get_port_list(),1:length(get_port_list())))
nprocs() != 2 && addprocs(1, exeflags="--project")
# # to control maintain an open communication Arduino without freezing the current terminal we need additional processes
# #= every process has an independet library upload. We can use @everywhere to load libraries in all processes
# the first step is always to activate the PKG library on the new processes, or we can't upload anything else=#
@everywhere using Pkg
@everywhere Pkg.activate(".") ##activate control arduino environment in all workers
# # Next we need to re-call the use of certain libraries to other workers/processes
@everywhere using LibSerialPort, Distributed
@everywhere import Dates.today, Dates.Date
@everywhere include("structure_files.jl")
@everywhere include("communication_files.jl")
@everywhere using Interact,Blink, CSSUtil
@everywhere include("GUI_files.jl")

function laser_gui()
    f = FreqStruct();
    s = SessionStruct();
    p = PeriodStruct(2,10,2,3, 2);
    es = ExpStruct(s,p,f);
    w_ex = widget(es);
    w = Window();body!(w, fetch(w_ex));
    return w_ex, Arduino_dict, ArduinosController
end

export ports_available, ArduinosController, Arduino_dict
export SessionStruct, FreqStruct, ExpStruct
export laser_gui, running, running!

end

