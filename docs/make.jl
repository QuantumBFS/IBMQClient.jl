using Documenter, IBMQClient, DocThemeIndigo
using IBMQClient.Schema
indigo = DocThemeIndigo.install(IBMQClient)

makedocs(;
    modules=[IBMQClient, Schema],
    authors="Roger-luo <rogerluo.rl18@gmail.com> and contributors",
    repo="https://github.com/QuantumBFS/IBMQClient.jl/blob/{commit}{path}#{line}",
    sitename="IBMQClient.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://QuantumBFS.github.io/IBMQClient.jl",
        assets=String[indigo, "assets/default.css"],
    ),
    pages=[
        "Quick Start" => "index.md",
        "Schema" => "schema.md",
    ],
)

deploydocs(;
    repo="github.com/QuantumBFS/IBMQClient.jl",
)
