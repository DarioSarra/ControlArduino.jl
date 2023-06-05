module ControlArduino
using Interact, Blink, CSSUtil, LibSerialPort, Distributed
@everywhere import Dates.today, Dates.Date
include("included_files.jl")
include(joinpath("GUI", "Premade_Stim_Protocols.jl"))
include(joinpath("GUI", "GUI_utilities.jl"))
include(joinpath("GUI", "SessionWidget.jl"))
include(joinpath("GUI", "FrequencyWidget.jl"))
include(joinpath("GUI", "PeriodWidget.jl"))
include(joinpath("GUI", "ExperimentWidget.jl"))
# to control maintain an open communication Arduino without freezing the current terminal we need additional processes
nprocs() != 3 && addprocs(2, exeflags="--project")
workers()
#= every process has an independet library upload. We can use @everywhere to load libraries in all processes
the first step is always to activate the PKG library on the new processes, or we can't upload anything else=#
@everywhere using Pkg
@everywhere Pkg.activate(".") ##activate control arduino environment in all workers
# The following basic libraries need to work on all processes
@everywhere using LibSerialPort, Distributed
@everywhere import Dates.today, Dates.Date
@everywhere include("included_files.jl")
# the following functions and values define the GUI and are only loaded in the main process 


function laser_gui()
    f = FreqStruct();
    s = SessionStruct();
    p = PeriodStruct(60,600,60,10, 50);
    es = ExpStruct(s,p,f);
    w_ex = widget(es);
    w = Window();body!(w, fetch(w_ex));
    return es
end

export SessionStruct, FreqStruct, ExpStruct
export laser_gui

end
