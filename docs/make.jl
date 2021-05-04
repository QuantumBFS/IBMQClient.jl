using Documenter, IBMQClient

makedocs(;
    modules = [IBMQClient],
    format = Documenter.HTML(prettyurls = !("local" in ARGS)),
    pages = [
        "Home" => "index.md",
        "Schema" => "schema.md",
    ],
    repo = "https://github.com/QuantumBFS/IBMQClient.jl",
    sitename = "IBMQClient.jl",
)

deploydocs(; repo = "github.com/QuantumBFS/IBMQClient.jl")
