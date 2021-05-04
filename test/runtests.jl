using Test
using IBMQClient

@testset "schema" begin
    include("schema.jl")
end

@testset "adapters" begin
    include("adapters.jl")
end
