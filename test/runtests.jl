using Test

@testset "schema" begin
    include("schema.jl")
end

@testset "adapters" begin
    include("adapters.jl")
end

# @testset "REST" begin
#     include("rest.jl")    
# end

# @testset "IBM Q Interface" begin
#     include("ibmq.jl")    
# end
