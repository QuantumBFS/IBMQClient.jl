module IBMQClient

export QiskitRC, AccountInfo, JobInfo, RemoteJob

using HTTP
using JSON
using UUIDs
using URIs
using Dates
using Configurations
using REPL.TerminalMenus
using Crayons.Box

include("schema.jl")
include("convert.jl")
include("rest.jl")
include("adapters.jl")

include("ibmq.jl")
# include("account.jl")

@static if VERSION > v"1.6-"
    include("menu.jl")
else
    include("menu.old.jl")
end

end
