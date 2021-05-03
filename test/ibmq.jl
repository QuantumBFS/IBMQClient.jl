using Test
using IBMQClient
using Random
using IBMQClient.REST
using IBMQClient.Schema

token = randstring(40)
access_token = randstring(40)
job_id = randstring(10)
api = AuthAPI()

@test_request IBMQClient.login(api, token) begin
    @test response[:method] == "POST"
    @test response[:body] == "{\"apiToken\":\"$token\"}"
    @test response[:uri] == URI("https://@auth.quantum-computing.ibm.com:/api/users/loginWithToken?#")
    @test ("X-Qx-Client-Application" => "IBMQClient.jl") in response[:headers]
    @test ("Content-Type" => "application/json") in response[:headers]
end

@test_request IBMQClient.user_info(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@auth.quantum-computing.ibm.com:/api/users/me?#")
    @test ("X-Access-Token" => access_token) in response[:headers]
end

api = ServiceAPI()

@test_request IBMQClient.hubs(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@api.quantum-computing.ibm.com:/api/Network?#")
    @test ("X-Access-Token" => access_token) in response[:headers]
end

api = ProjectAPI("https://qc.ibm.com/", "test_hub", "test_group", "test_project")

@test api.endpoint == URI("https://qc.ibm.com//Network/test_hub/Groups/test_group/Projects/test_project")

@test_request IBMQClient.jobs(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs/status/v/1?filter=%7B%22order%22%3A%22creationDate%20DESC%22%2C%22skip%22%3A0%2C%22limit%22%3A10%7D#")
    @test ("X-Access-Token"=>access_token) in response[:headers]
end

fake_dev = DeviceInfo(;
    backend_name="fake",
    n_qubits=10,
    backend_version=v"1.2.2",
    description="",
    gates=GateInfo[],
)

@test_request IBMQClient.create_remote_job(api, fake_dev.backend_name, access_token) begin
    @test response[:method] == "POST"
    @test response[:body] == "{\"backend\":{\"name\":\"fake\"},\"allowObjectStorage\":true}"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs?#")
    @test ("X-Access-Token"=>access_token) in response[:headers]
end


api = JobAPI(api, job_id)

@test_request IBMQClient.upload_url(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs/$job_id/jobUploadUrl?#")
    @test ("X-Access-Token"=>access_token) in response[:headers]
end

@test_request IBMQClient.retreive_job_info(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs/$job_id/v/1?#")
end

@test_request IBMQClient.cancel(api, access_token) begin
    @test response[:method] == "POST"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs/$job_id/cancel?#")
end

@test_request IBMQClient.properties(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs/$job_id/properties?#")
end

@test_request IBMQClient.result_url(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs/$job_id/resultDownloadUrl?#")
end

@test_request IBMQClient.download_url(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs/$job_id/jobDownloadUrl?#")
end

@test_request IBMQClient.status(api, access_token) begin
    @test response[:method] == "GET"
    @test response[:uri] == URI("https://@qc.ibm.com:/Network/test_hub/Groups/test_group/Projects/test_project/Jobs/$job_id/status/v/1?#")
end
