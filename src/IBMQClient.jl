module IBMQClient

using HTTP
using JSON
using UUIDs
using URIs
using REPL.TerminalMenus
using Crayons.Box

include("rest.jl")
include("ibmq.jl")
include("account.jl")

@static if VERSION > v"1.6-"
    include("menu.jl")
else
    include("menu.old.jl")
end

end
