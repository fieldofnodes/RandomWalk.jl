using RandomWalk
using Documenter

DocMeta.setdocmeta!(RandomWalk, :DocTestSetup, :(using RandomWalk); recursive=true)

makedocs(;
    modules=[RandomWalk],
    authors="Jonathan Miller jonathan.miller@fieldofnodes.com",
    sitename="RandomWalk.jl",
    format=Documenter.HTML(;
        canonical="https://fieldofnodes.github.io/RandomWalk.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/fieldofnodes/RandomWalk.jl",
    devbranch="main",
)
