module IBMQClient

using HTTP
using JSON
using UUIDs
using URIs
using REPL.TerminalMenus
using Crayons.Box

include("patch.jl")

using .Patch: make_uri

include("rest.jl")
include("ibmq.jl")
include("account.jl")
include("menu.jl")

end
