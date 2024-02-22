using Test
using IBMQClient

@testset "schema" begin
    include("schema.jl")
end

@testset "adapters" begin
    include("adapters.jl")
end

# this needs stdin to be a Base.TTY which is only the case when in the REPL (typeof(stdin) = IOStream when executed in a script).
# if we want to run this test, a workaround is needed (not sure what to do).
# @testset "menu" begin
#     include("menu.jl")
# end
