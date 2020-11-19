using Test
using IBMQClient
using IBMQClient.REST
using URIs

api = REST.API(URI("https://a.b.c"))

@test_request REST.get(api, "d/g") begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@a.b.c:/d/g?#")
end

@test_request REST.post(api, "d/g"; query=Dict("name"=>"Name")) begin
    @test response[:method] == "POST"
    @test response[:uri] == URI("https://@a.b.c:/d/g?name=Name#")
end

@test_request REST.put(api, "d/g"; query=Dict("name"=>"Name")) begin
    @test response[:method] == "PUT"
end
