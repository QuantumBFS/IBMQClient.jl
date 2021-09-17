using Test
using Aqua
using IBMQClient
Aqua.test_all(IBMQClient)

@testset "schema" begin
    include("schema.jl")
end

@testset "adapters" begin
    include("adapters.jl")
end
