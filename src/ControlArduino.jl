module ControlArduino
    using Reexport
    using LibSerialPort, Interact, Blink, CSSUtil, Distributed
    import Dates.today

    include("StimulationStructure.jl")
    include("RunStim.jl")

    export ArduinosController,Arduino_dict, running, running!
    export SessionStruct
    export run_task
end
