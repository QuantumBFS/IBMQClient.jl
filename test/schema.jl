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
    schema_version=v"1.3",
    header=Dict("description"=>"Bell states"),
    config=ExpConfig(shots=1000, memory_slots=2),
    experiments=[
        Experiment(;
            header=Dict("description"=>"|11>+|00> Bell"),
            config=ExpConfig(shots=1000, memory_slots=2, n_qubits=2),
            instructions=[
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Gate(name="cx", qubits=[0, 1]),
                Measure(qubits=[0, 1], memory=[0, 1]),
            ]
        ),
        Experiment(;
            header=Dict("description"=>"|01>+|10> Bell"),
            config=ExpConfig(shots=1000, memory_slots=2, n_qubits=2),
            instructions=[
                Gate(name="u2", qubits=[0], params=[0.0, π]),
                Gate(name="cx", qubits=[0, 1]),
                Gate(name="u3", qubits=[0], params=[π, 0.0, π]),
                Measure(qubits=[0, 1], memory=[0, 1]),
            ]
        )
    ]
)
