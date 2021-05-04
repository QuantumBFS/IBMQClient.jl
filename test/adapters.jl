using Test
using Random
using IBMQClient
using Configurations
using IBMQClient.Schema
using BrokenRecord

token = "pg3PIrchJpDoyv7cl5GedjE4Q86NuKyriLIIN3SskWMlNDIgnAHALINT8jWgyIdNiEWURUnp2qjr0T4ooP5T60DxejmhbeVFbt1fTeIUlNQPSIbc637GShmhc4xqD65b"
BrokenRecord.configure!(path=joinpath(pkgdir(IBMQClient), "test", "records"), ignore_query=["apiToken"], ignore_headers=["X-Access-Token", "apiToken"])

account = playback("account.json") do
    AccountInfo(token)
end

@test account.user_info.username == "Hagenes.Morris@gmail.com"
@test account.user_info.email == "Hagenes.Morris@gmail.com"
@test account.user_info.firstName == "Hagenes"
@test account.user_info.lastName == "Morris"
@test account.user_info.institution == "Perimeter Quantum Intelligence Lab"
@test account.access_token == "RzTg74jxdXpQAqm03HuVIYnG1XnSP63AZVVHcIfcxO2PCmcrFQFFQrTFr7SSTKWg"

user_urls = playback("user_urls.json") do
    IBMQClient.user_urls(account)
end

@test user_urls["http"] == "https://api-qcon.quantum-computing.ibm.com/api"

hubs = playback("hubs.json") do
    IBMQClient.hubs(account)
end

@test hubs[1]["name"] == "ibm-q-research"

user_hubs = playback("hubs.json") do
    IBMQClient.user_hubs(account)
end

@test user_hubs[1]["project"] == "main"
@test user_hubs[1]["hub"] == "ibm-q"
@test user_hubs[1]["group"] == "open"

@test user_hubs[2]["project"] == "main"
@test user_hubs[2]["hub"] == "ibm-q-research"
@test user_hubs[2]["group"] == "independent-8"


devices = playback("devices.json") do
    IBMQClient.devices(account)
end

@test devices[1].backend_name == "ibmq_qasm_simulator"

jobs = playback("jobs.json") do 
    IBMQClient.jobs(account)
end

@test jobs[1].kind == "q-object-external-storage"
@test jobs[1].backend["name"] == "ibmq_qasm_simulator"

qobj = Qobj(;
    qobj_id="bell_Qobj_07272018",
    type="QASM",
    schema_version=v"1",
    header=Dict("description"=>"Bell states"),
    config=ExpConfig(shots=1000, memory_slots=2),
    experiments=[
        Experiment(;
            header=Dict("description"=>"|11>+|00> Bell"),
            instructions=[
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Gate(name="cx", qubits=[0, 1]),
                Measure(qubits=[0, 1], memory=[0, 1]),
            ]
        ),
        Experiment(;
            header=Dict("description"=>"|01>+|10> Bell"),
            instructions=[
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Gate(name="cx", qubits=[0, 1]),
                Gate(name="u3", qubits=[0], params=[π, 0.0, π]),
                Measure(qubits=[0, 1], memory=[0, 1]),
            ]
        )
    ]
)

job_info = playback("submit.json") do
    IBMQClient.submit(account, RemoteJob(dev=devices[1]), qobj)
end

@test job_info.status == "CREATED"

status_job_info = playback("status.json") do
    IBMQClient.status(account, job_info)
end

@test status_job_info.status == "COMPLETED"

results = playback("result.json") do
    IBMQClient.results(account, job_info)
end

@test results.backend_name == "ibmq_qasm_simulator"
@test results.status == "COMPLETED"

using REPL.TerminalMenus
const CR = "\r"
const LF = "\n"
const UP = "\eOA"
const DOWN = "\eOB"
const ALL = "a"
const NONE = "n"
const DONE = "d"
const SIGINT = "\x03"
const QUIT = "q"

menu = IBMQClient.DeviceMenu(devices)
print(
    stdin.buffer,
    DOWN,
    LF,
    CR,
)

choice = request("choose a device:", menu)
@test choice == 2
readavailable(stdin.buffer)

print(
    stdin.buffer,
    DOWN,
    DOWN,
    DOWN,
    LF,
    CR,
)
choice = request("choose a device:", menu)
@test choice == 4
readavailable(stdin.buffer)

print(
    stdin.buffer,
    DOWN,
    DOWN,
    DOWN,
    QUIT,
)
choice = request("choose a device:", menu)
@test choice == -1
readavailable(stdin.buffer)

@test_throws InterruptException begin
    print(
        stdin.buffer,
        DOWN,
        DOWN,
        DOWN,
        SIGINT,
    )
    request("choose a device:", menu)
    readavailable(stdin.buffer)
end
