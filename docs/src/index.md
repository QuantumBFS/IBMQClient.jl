# IBMQClient

[![Build Status](https://github.com/QuantumBFS/IBMQClient.jl/workflows/CI/badge.svg)](https://github.com/QuantumBFS/IBMQClient.jl/actions)
[![Coverage](https://codecov.io/gh/QuantumBFS/IBMQClient.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/QuantumBFS/IBMQClient.jl)


Julia Wrapper for the IBM Quantum Experience REST API. This API wrapper is based on
IBM Q official implementation but is not an IBM official package.

## Usage

1. create an [`AccountInfo`](@ref)

```julia
using IBMQClient
using IBMQClient.Schema
account = AccountInfo(token)
```

2. create an [`Qobj`](@ref) based on the Qobj schema specification, e.g

```julia
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
```

3. find an available device

```julia
devices = IBMQClient.devices(account)
```

4. submit the job

```julia
job_info = IBMQClient.submit(account, RemoteJob(dev=devices[1]), qobj)
```

5. query the job status

```julia
job_info = IBMQClient.status(account, job_info)
```

6. download the results when `job_info` has status `COMPLETED`

```julia
IBMQClient.results(account, job_info)
```

## REPL Terminal Menu

We have a Terminal Menu for easy-reading IBM device information
in terminal. You can start it by

```julia
julia> using REPL.TerminalMenus
julia> menu = IBMQClient.DeviceMenu(devices)
julia> choice = request("choose a device:", menu)
choose a device:
   ibmq_qasm_simulator            nqubits: 1
   ibmqx2                         max_shots: 8192
   ibmq_16_melbourne              credits_required:: true
 → ibmq_armonk
v  ibmq_athens
```

## API References

```@autodocs
Modules = [IBMQClient]
```
