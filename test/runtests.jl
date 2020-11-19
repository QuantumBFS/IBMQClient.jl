using Test

@testset "REST" begin
    include("rest.jl")    
end

@testset "IBM REST" begin
    include("ibmq.jl")    
end
