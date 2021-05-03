using Test

@testset "schema" begin
    include("schema.jl")
end

@testset "REST" begin
    include("rest.jl")    
end

@testset "IBM REST" begin
    include("ibmq.jl")    
end

using IBMQClient
using Configurations
using Test
using UUIDs
using JSON
using Random
using IBMQClient.Schema
# using IBMQClient.REST
# using IBMQClient: IBMQDevice, GateInfo

token = "e773394070269e3deace4372ed915c99610ee5a0e3be7b2f821e6889f4f4fe93cafdebcce46009e0ec9dd3ff8dca3ad3eb126b3bc59617ee837f2e120e99f268"

account = IBMQClient.AccountInfo(token)
ds = IBMQClient.devices(account)
# job = IBMQClient.create_remote_job(account, RemoteJob(dev=ds[1]))
qobj = Qobj(;
    qobj_id=string(uuid1()),
    type="QASM",
    schema_version=v"1.3",
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
    ]
)

job = IBMQClient.submit(account, RemoteJob(dev=ds[1]), qobj)
IBMQClient.status(account, job)

using REPL.TerminalMenus
menu = IBMQClient.DeviceMenu(ds);
choice = request("choose a device:", menu)
