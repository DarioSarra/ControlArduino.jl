using ControlArduino
using Documenter

DocMeta.setdocmeta!(ControlArduino, :DocTestSetup, :(using ControlArduino); recursive=true)

makedocs(;
    modules=[ControlArduino],
    authors="DarioSarra",
    repo="https://github.com/DarioSarra/ControlArduino.jl/blob/{commit}{path}#{line}",
    sitename="ControlArduino.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://DarioSarra.github.io/ControlArduino.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/DarioSarra/ControlArduino.jl",
    devbranch="main",
)
