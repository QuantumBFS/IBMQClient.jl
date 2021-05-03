using Test
using JSON
using Dates
using Configurations
using IBMQClient.Schema

d = JSON.parse("""
{
"name": "cx",
"parameters": [],
"coupling_map": [[0,1],[0,2],[0,3],[1,2],[0,4]],
"qasm_def": "gate cx q1,q2 { CX q1, q2; }",
"conditional": true,
"latency_map": [[1,0,0,0,0],[1,0,0,0,0],
[1,0,0,0,0],[0,1,0,0,0],
[0,0,0,0,1]],
"description": "CNOT gate"
}
""")

info = Configurations.from_dict(GateInfo, d)
@test info.name == "cx"
@test info.parameters == String[]
@test info.coupling_map == [[0,1],[0,2],[0,3],[1,2],[0,4]]
@test info.conditional
@test info.latency_map == [[1,0,0,0,0],[1,0,0,0,0], [1,0,0,0,0],[0,1,0,0,0], [0,0,0,0,1]]
@test info.description == "CNOT gate"

d = JSON.parse("""
{
"name": "swap",
"parameters": [],
"coupling_map": [[2,3]],
"qasm_def": "gate swap a,b { CX a,b; CX b,a; CX a,b; }",
"conditional": false,
"description": "SWAP gate"
}
""")
info = Configurations.from_dict(GateInfo, d)

@test info.name == "swap"
@test info.parameters == String[]
@test info.coupling_map == [[2,3]]
@test info.qasm_def == "gate swap a,b { CX a,b; CX b,a; CX a,b; }"
@test info.conditional == false
@test info.description == "SWAP gate"

Qobj(;
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

Result(;
    backend_name="ibmqx2",
    backend_version=v"2.1.2",
    qobj_id="bell_Qobj_07272018",
    job_id="XY1253GSEF",
    date=DateTime("2018-04-02 15:00:00Z", dateformat"yyyy-mm-dd HH:MM:SSZ"),
    header=Dict("description"=>"Bell states"),
    success=true,
    status="COMPLETED",
    results=[
        ExpResult(;
            shots=1000,
            status="DONE",
            success=true,
            header=Dict("description"=>"|11>+|00> Bell"),
            data=ExpData(;
                counts=Dict("0x0"=>450, "0x1"=>10, "0x2"=>20, "0x3"=>520),
                memory=["0x0","0x0","0x3","0x2","0x3","0x0"],
            )
        ),
        ExpResult(;
            shots=1000,
            status="DONE",
            success=true,
            header=Dict("description"=>"|01>+|10> Bell"),
            data=ExpData(;
                counts=Dict("0x0"=>450, "0x1"=>510, "0x2"=>480, "0x3"=>5),
                memory=["0x2","0x1","0x1","0x2","0x2","0x2"],
            )
        )
    ]
)

# Teleportation
Qobj(;
    qobj_id="teleport_07272018",
    type="QASM",
    schema_version=v"1.0",
    header=Dict("description"=>"Teleport circuit"),
    config=ExpConfig(shots=1000, memory_slots=2),
    experiments=[
        Experiment(;
            instructions=[
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Gate(name="cx", qubits=[1, 2]),
                Gate(name="cx", qubits=[0, 1]),
                Measure(qubits=[1], memory=[1], register=[1]),
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Measure(qubits=[0], memory=[0], register=[0]),
                Gate(name="u1", qubits=[2], params=[π], conditional=0),
                Gate(name="u3", qubits=[2], params=[π, 0.0, π], conditional=1),
            ]
        ),
    ]
)

Result(;
    backend_name="ibmqx2",
    backend_version=v"2.1.2",
    qobj_id="teleport_07272018",
    job_id="XX12353ISEL",
    date=DateTime("2018-04-02 15:00:00Z", dateformat"yyyy-mm-dd HH:MM:SSZ"),
    header=Dict("description"=>"Teleport circuit"),
    success=true,
    status="COMPLETED",
    results=[
        ExpResult(;
            shots=1000,
            status="DONE",
            success=true,
            data=ExpData(;
                counts=Dict("0x0"=>250, "0x1"=>220, "0x2"=>260, "0x3"=>270),
                memory=["0x0","0x1","0x2","0x1","0x3","0x0"],
            )
        )       
    ]
)
