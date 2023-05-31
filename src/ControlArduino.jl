module ControlArduino
    using Distributed
    nprocs() != 3 && addprocs(2,exeflags="--project")
    workers()
    @everywhere using Pkg   # required
    @everywhere Pkg.activate(".")
    @everywhere using LibSerialPort, Distributed
    @everywhere import Dates.today, Dates.Date

    using Interact
    # include("StimulationStructure.jl")
    const ArduinosController = falses(8)
    ports_available = get_port_list()
    const Arduino_dict = Dict(k => v for (k,v) in zip(ports_available,1:length(ports_available)))
    @everywhere include(joinpath(@__DIR__,"RunStim.jl"))
    include(joinpath(@__DIR__,"ExpWidget.jl"))

    export SessionStruct, FreqStruct, ExpStruct
    export run_task, ArduinosController, Arduino_dict, running, running!
end
