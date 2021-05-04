using Test
using Random
using Faker
using Mocking
using IBMQClient
using Configurations
using IBMQClient.Schema

Mocking.activate()
include("response.jl")

patch = @patch function IBMQClient.request(api, method, path, body; kw...)
    if api isa AuthAPI && method == "POST" && path == "users/loginWithToken"
        return response["login"]
    elseif api isa AuthAPI && method == "GET" && path == "users/me"
        return response["user_info"]
    elseif api isa ServiceAPI && method == "GET" && path == "Network"
        return response["hubs"]
    elseif api isa ProjectAPI && method == "GET" && path == "devices/v/1"
        return response["devices"]
    elseif api isa ProjectAPI && method == "GET" && path == "Jobs/status/v/1"
        return response["jobs"]
    end
end

account = apply(patch) do
    AccountInfo(token)
end

@test account.user_info.email == email
@test account.access_token == access_token
@test IBMQClient.user_urls(account) == Dict{String, Any}(
    "services" => Dict{String, Any}(
        "extractorsService" => "https://api.quantum-computing.ibm.com/cqc",
        "quantumLab" => "https://notebooks.quantum-computing.ibm.com",
        "runtime" => "https://runtime-us-east.quantum-computing.ibm.com"
        ),
    "http" => "https://api-qcon.quantum-computing.ibm.com/api",
    "ws" => "wss://wss.quantum-computing.ibm.com/"
)

hubs = apply(patch) do
    IBMQClient.hubs(account)
end
@test hubs[1]["id"] == response["hubs"][1]["id"]
@test hubs[2]["id"] == response["hubs"][2]["id"]

user_hubs = apply(patch) do
    IBMQClient.user_hubs(account)
end

@test user_hubs == [
    Dict("project" => "main", "hub" => "ibm-q", "group" => "open"),
    Dict("project" => "main", "hub" => "ibm-q-research", "group" => "independent-8")
]

devices = apply(patch) do
    IBMQClient.devices(account)
end

@test devices == Configurations.from_dict_inner.(DeviceInfo, response["devices"])

jobs = apply(patch) do
    IBMQClient.jobs(account)
end

@test jobs == Configurations.from_dict_inner.(JobInfo, response["jobs"])

# token = "e773394070269e3deace4372ed915c99610ee5a0e3be7b2f821e6889f4f4fe93cafdebcce46009e0ec9dd3ff8dca3ad3eb126b3bc59617ee837f2e120e99f268"
# account = AccountInfo(token)
# jobs = IBMQClient.jobs(account.project, account.access_token)

# print(jobs[1:2])
