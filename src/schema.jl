module Schema

using UUIDs
using Dates
using Configurations

export GateInfo, DeviceInfo, NDUV, GateProp,
    Properties, Status, JobStatus, ExpData, ExpResult, Result,
    ExpConfig, Instruction, BooleanFunction, CopyFunction,
    Gate, Barrier, Reset, Measure, Experiment, Qobj,
    UserInfo

abstract type IBMQSchema end

@option struct Subscription <: IBMQSchema
    surveys::Int = 0
    newsletter::Int = 0
    updates::Int = 0
    tips::Int = 0
    updatesInTool::Int = 0
end

@option struct UserInfo <: IBMQSchema
    id::String
    username::String
    email::String
    urls::Dict{String, Any}
    userType::String="Standard"
    firstName::Maybe{String} = nothing
    lastName::Maybe{String} = nothing
    institution::Maybe{String} = nothing
    applications::Vector{String} = String[]
    subscriptions::Subscription = Subscription()
    readOnly::Bool=false
    needsRefill::Bool=false
    iqxPreferences::Dict{String, Any} = Dict{String, Any}()
    loginAccounts::Vector{Any} = []
    ibmQNetwork::Bool=true
    qNetworkRoles::Vector{String} = []
    roles::Vector{Any} = []
    emailVerified::Bool=false
    terms::Dict{String, Any} = Dict{String, Any}()
    canScheduleBackends::Bool=true
    servicesRoles::Vector{String}=[]
end

UserInfo(d::AbstractDict{String}) = from_dict(UserInfo, d)

"""
    struct GateInfo <: IBMQSchema

The gate config data structure has the following keys.

- `name`: Gate name, as it will be referred to in the OpenQASM circuit.
- `parameters`: List of parameters for the gate (empty if no parameters).
- `coupling_map` (optional): List of qubits that the gate applies to, each element of the list is
an n-qubit list where n is the size of the gate (e.g. 1-qubit gate, 2-qubit gate).
- `qasm_def`: OpenQASM definition of the gate in terms of the basis gates [U,CX].
Each unitary gate has an efficient representation in this basis.
- `conditional` (optional): Gate supports conditional operation (true/false). If not
listed then defaults to the backend setting.
- `latency_map` (optional): List for each gate of length n registers that indicates
if the feedback speed to the register is fast (1) or slow (0). In the above example
the u3 gate for qubit 0 has low latency for conditionals to register 0, but qubits
1 and 2 have low latency to both registers 1 and 2.
- `description` (optional): Description of the gate.
"""
@option struct GateInfo <: IBMQSchema
    name::String
    parameters::Maybe{Vector{String}} = nothing
    coupling_map::Maybe{Vector{Vector{Int}}} = nothing
    qasm_def::Maybe{String} = nothing
    conditional::Maybe{Bool} = nothing
    latency_map::Maybe{Vector{Vector{Int}}} = nothing
    description::Maybe{String} = nothing
end

"""
    struct DeviceInfo <: IBMQSchema

The backend will have a method Backend.configuration() which returns the required
backend config data structure. Backends can include additional items to this
structure.

- `backend_name`: Unique (to provider) backend identifier name. This could describe
a setup that goes through several changes, but retains common elements (e.g.,
for a physical device backend this could include the same coupling map and the
physical location, etc.)
backend version: Backend version string in the form `"X.X.X"`. Versions could
indicate, e.g., code changes, equipement upgrades, different cooldowns, new optimizations, etc.
- `n_qubits`: Number of qubits in the backend. Simulator backends return `"-1"`.
- `basis_gates`: List of the available gates on the backend as an array of gate names
(these should match the entries in gates).
- `coupling_map`: Representation of the physical coupling map on the device (the
coupling maps for each gate are defined in gates).
- `gates`: List of the available gates on the backend as a gate config data structure, see [`GateInfo`](@ref).
- `local`: Backend runs locally (`true`) or online (`false`).
- `simulator`: Backend is a simulator (`true`) or an experimental device (`false`).
- `conditional`: Backend supports conditional gates (`true`) or does not (`false`).
Individual gates may also support or not support conditionals.
- `configurable`: Backend (if simulator) is configurable (`true`). If true then there
are user specified configuration parameters (e.g., the topology, noise parameters,
etc.). The data structure for these settings is set by the specific backend.
- `n_registers` (required if conditional is `true`): Specifies the number of registers
slots (i.e. the number of register bits) that are available for conditional operations.
Each register can hold a bit value.
- `register_map` (required if conditional is `true`): Specifies the registers that each
qubit can store measurements. For this example, qubits 0 and 1 can store in
registers 0 and 1, qubit 2 in registers 2 and 3, and qubits 3 and 4 in registers 3
and 4.
- `open_pulse`: OpenPulse experiments are accepted on this backend.

The configuration structure may also have the following optional fields,

- `online_date`: Date that the backend was put online.
- `display_name`: Alternate name for the backend that is more descriptive that can
be used for display purposes.
- `sample_name`: Name of the sample for this given backend (likely blank for a
simulator).
- `description`: String to describe the backend.
- `url`: Internet address to the backend (if applicable).
- `tags`: List of tag strings for the backend that indicate true/false properties, e.g.,
`"credits_required"` (backend requires credits to run). Any absent tag means that
the property is false and new tags can be added.
- `quantum_volume`: quantum volume of given device.
- `max_experiments`: maximum experiment.
- `max_shots`: maximum shot can spawn.
"""
@option struct DeviceInfo <: IBMQSchema
    backend_name::String
    backend_version::VersionNumber
    n_qubits::Int
    memory::Bool = false
    max_shots::Maybe{Int} = nothing
    max_experiments::Maybe{Int} = nothing
    var"local"::Bool = false
    simulator::Bool = false
    conditional::Bool = true
    configurable::Bool = false
    credits_required::Bool = false
    allow_q_object::Bool = false
    allow_object_storage::Bool=false
    n_registers::Maybe{Int} = nothing
    open_pulse::Bool = false
    quantum_volume::Maybe{Int} = nothing
    online_date::Maybe{DateTime} = nothing
    display_name::Maybe{String} = nothing
    sample_name::Maybe{String} = nothing
    description::Maybe{String} = nothing
    url::Maybe{String} = nothing
    tags::Maybe{Vector{String}} = nothing
    register_map::Maybe{Vector{Vector{Int}}} = nothing
    coupling_map::Maybe{Vector{Vector{Int}}} = nothing
    basis_gates::Maybe{Vector{String}} = nothing
    gates::Vector{GateInfo}
end

function Configurations.convert_to_option(::Type{DeviceInfo}, ::Type{DateTime}, s::String)
    DateTime(s, dateformat"yyyy-mm-ddTHH:MM:SSZ")
end

"""
    struct NDUV <: IBMQSchema

Each of the parameters is expressed as a nduv struct (name-date-unit-value structure)
as below,
"""
@option struct NDUV <: IBMQSchema
    name::String
    date::DateTime
    unit::String
    value::Any
end

"""
    struct GateProp <: IBMQSchema

- `qubits`: Qubits involved in the gate.
- `gate`: Gate name, must be one of the gates from `"gates"` in the backend configuration structure.
- `parameters`: List of parameter structures which could generically include `"gate_err"`
(by gate error we mean the 1−Favg for the particular gate) and `"gate_time"`. Note
that each backend may measure gate error using different methodologies, this will
have to be conveyed by the backend over separate channels (e.g. at the URL).
"""
@option struct GateProp <: IBMQSchema
    qubits::Vector{Int}
    gate::String
    parameters::Vector{NDUV}
end

"""
    struct Properties <: IBMQSchema

The backend will have a call `Backend.properties()` which will return a backend props
data structure with backend properties (e.g. calibrations and coherences). Note that
this information is optionally provided by the backend, which will set how often and/or
under what conditions calibrations and characterizations need to be updated.

- `backend_name`, `backend_version`: Backend identifiers (from Backend.configuration())
that specify what backend these results were obtained from.
- `last_update_date`: Date/time of the last run calibration.
- `gates`: List of the qubit gate parameters (as a gate prop structure, see below).
- `qubits`: List of list of qubit parameters (e.g. coherences) which is in order of the
qubits. The qubit parameters could generically include “T1”, “T2”, “readoutErr”
and “frequency”.
- `general`: List of general backend parameters, see [`NDUV`](@ref).
"""
@option struct Properties <: IBMQSchema
    backend_name::String
    backend_version::VersionNumber
    last_update_date::DateTime
    gates::String
    qubits::Vector{Vector{NDUV}}
    general::Vector{NDUV}
end

"""
    struct Status <: IBMQSchema

The backend will have a call Backend.status() which returns status information on
the backend in the backend status structure (only the operational and status msg
fields are required),

- `backend_name`, `backend_version`: Backend identifiers that specify the backend.
- `operational`: Backend is operational (true/false), i.e., currently running jobs.
- `pending_jobs`: Number of jobs in the queue for the backend (if no queue return
0).
- `status_msg`: Status message for the backend. For example, `"The backend is down
for calibration, will be back at 19:00"`.
"""
@option struct Status <: IBMQSchema
    backend_name::String
    backend_version::VersionNumber
    operational::Bool
    pending_jobs::Int
    status_msg::String
end

"""
    struct JobStatus <: IBMQSchema

A call to `Job.status()` returns back a job status data structure of the following
form.

- `job_id`: Backend generated id corresponding to this job (this will only be nonzero
if the job has been successfully initialized and accepted to run on the backend).
- `status`: String value corresponding to the job status (`"ERROR"`,`"QUEUED"`,
`"INITIALIZING"`, `"RUNNING"`, `"CANCELLED"` and `"DONE"`).
- `status_msg`: Backend defined status message.
"""
@option struct JobStatus <: IBMQSchema
    job_id::String
    status::String
    status_msg::String
end


"""
    struct ExpData <: IBMQSchema

The measurement data that is returned in exp data has one of several possible forms:
as a histogram of counts of the memory states, the memory, or (for simulators) the
statevector or unitary matrix.

- `counts`: Histogram of counts in the different memory states. Only states with
non-zero counts are listed as keys. The states are labeled in hex (e.g., a 4 slot
memory `"1010"` (bit string) is decimal 10 and hex `"0xA"`).
- `memory`: State of the classical memory. For OpenQASM (or OpenPulse Level 2)
this is a list of hex strings indicating the state for each shot.
- `statevector` (optional): Final statevector corresponding to evolution of the zero state.
- `unitary` (optional): Final unitary matrix corresponding to the quantum circuit.
- `snapshots` (optional): Snapshots data structure that returns data as dictated by the snapshot
command used by simulators.

## Snapshots

The snapshot is a special command reserved for simulators which allows a "snapshot"
of the simulator state to be recorded.

```json
{
    "name": "snapshot",
    "label": "snap1",
    "type": "state"
}
```

- `name`: `"snapshot"`.
- `label`: Snapshot label which is used to identify the snapshot in the output.
- `type`: Type of snapshot, e.g., `"state"` (take a snapshot of the quantum state).
The types of snapshots offered are defined in a separate specification document
for simulators.
"""
@option struct ExpData <: IBMQSchema
    counts::Dict{String, Int}
    memory::Maybe{Vector{String}} = nothing
    statevector::Maybe{Matrix{ComplexF64}} = nothing
    unitary::Maybe{Matrix{ComplexF64}} = nothing
    snapshots::Maybe{Dict{String, Any}} = nothing
end

"""
    struct ExpResult <: IBMQSchema

Each individual experiment returns an exp result data structure.

- `shots`: If a single integer, then this is the number of shots taken to obtain this
data (``s = n₁``). If the backend allows asynchronous calls to measurement, the
value of ``n₂`` will increase as more data is taken. For backends that return the data
in sections (e.g. for bandwidth reasons) shots is given as a two-element list where
the data is from shot ``n₁`` to shot ``n₂`` (``s = n₂ − n₁``). The next call will give the
data starting at ``n₂ + 1``.
- `status`: Status message for this particular experiment.
- `success`: Success of the experiment (bool).
- `header` (optional): Header structure for the experiment that was passed in with the Qobj.
- `seed` (optional): Experiment seed (for simulator backends).
- `meas_return` (optional): String which determines whether the returned data is
averaged over the shots avg or contains each shot single. This is an OpenPulse
option, but could also apply to snapshots.
- `data`: Generic return experiment data structure exp data that will depend on
the type of experiment (`"QASM"` or `"PULSE"`) and/or the type of backend (e.g.
simulator data). See below.
"""
@option struct ExpResult <: IBMQSchema
    metadata::Maybe{Dict{String, Any}} = nothing
    header::Maybe{Dict{String, Any}} = nothing
    shots::Union{Int, Vector{Int}}
    status::String
    success::Bool
    time_taken::Float64
    seed_simulator::Maybe{Int} = nothing
    seed::Maybe{Int} = nothing
    meas_return::Maybe{String} = nothing
    data::ExpData
end

"""
    struct Result <: IBMQSchema

The results data structure from Job.result().

- `backend_name`, `backend_version`: Backend identifiers that specify what backend these results were obtained from.
- `qobj_id`: User generated id corresponding to the qobj id in the `Qobj`.
- `job_id`: Unique backend job identifier corresponding to these results.
- `date`: Date when the job was run.
- `header` (optional): Header structure for the job that was passed in with the `Qobj`.
- `results`: List of `m` (number of experiments) exp result data structures (defined below).
"""
@option struct Result <: IBMQSchema
    header::Maybe{Dict{String, Any}} = nothing
    metadata::Maybe{Dict{String, Any}} = nothing
    time_taken::Maybe{Float64} = nothing
    qobj_id::String
    job_id::String
    backend_name::String
    backend_version::VersionNumber
    date::DateTime
    status::String
    success::Bool
    results::Vector{ExpResult}
end

function Configurations.convert_to_option(::Type{Result}, ::Type{DateTime}, s::String)
    # NOTE: we only use millisecond since Dates doesn't support 6 digits precision
    # might worth an issue in upstream?
    DateTime(s[1:21], dateformat"yyyy-mm-ddTHH:MM:SS.s")
end


"""
    struct ExpConfig <: IBMQSchema

- `shots`: Number of times to repeat the experiment (for some simulators this may
be limited to 1, e.g., a unitary simulator).
- `memory_slots`: Number of classical memory slots used in this job. Memory slots
are used to record the results of qubit measurements and read out at the end of
an experiment. They cannot be used for feedback (those are the registers).
- `seed` (optional): Randomization seed for simulators.
- `max_credits` (optional): For credit-based backends, the maximum number of
credits that a user is willing to spend on this run (an error will be thrown if the
run required more than max credits).
"""
@option struct ExpConfig <: IBMQSchema
    shots::Int = 1024
    memory_slots::Int
    seed::Maybe{Int} = nothing
    max_credits::Maybe{Int} = nothing
end

"""
    abstract type Instruction <: IBMQSchema end

Abstract type for Qobj schema instructions.
"""
abstract type Instruction <: IBMQSchema end

Configurations.is_option(::Type{T}) where {T <: Instruction} = true

"""
    struct BooleanFunction <: Instruction

A boolean function is a command that takes in a register as an argument and computes
a boolean value that is written back into one of the register slots.

- `name`: `"bfunc"`.
- `mask`: Hex value which is applied as an AND to the register bits. In the given example ,`"0xF"` uses the first 4 bits of the register. The backend may put constraints
on the number of register bits that can be used in this function.
- `relation`: Relational operator for comparing the masked register to the val
(`"="`: equals, `"!="` not equals).
- `val`: Value to which to compare the masked register. In other words, the output
of the function is (register AND mask) relation val. In the above example this
is true when the first 4 register bits are `"0101"`
- `register`: Register slot in which to store the boolean function result. This
register value can then be used to apply conditional commands (see the following
sections).
- `memory` (optional): Memory slot in which to store the boolean function result.
"""
@option struct BooleanFunction <: Instruction
    name::String = "bfunc"
    mask::String
    relation::String
    val::String
    register::Int
    memory::Maybe{Int} = nothing
end

"""
    struct CopyFunction <: Instruction

A copy function is a command that copies a register slot.

- `name`: `"copy"`.
- `register_orig`: Register slot to copy.
- `register_copy`: Register slot(s) to copy to.
"""
@option struct CopyFunction <: Instruction
    name::String = "copy"
    register_orig::Int
    register_copy::Vector{Int}
end

"""
    struct Gate <: Instruction

- `name`: Name of the gate.
- `qubits`: List of qubits to apply the gate.
- `params` (optional): List of parameters for the gate (if the gate has parameters,
such as u1, u2, u3).
- `texparams` (optional): List of parameters for the gate in latex notation.
- `conditional` (optional): Apply the gate if the given register (in this example
register 3) is 1 (true) and conditionals are supported. If left blank then the gate
has no conditional element (i.e. no feedback). By default this is blank.
"""
@option struct Gate <: Instruction
    name::String
    qubits::Vector{Int}
    params::Maybe{Vector{Float64}} = nothing
    texparams::Maybe{Vector{String}} = nothing
    conditional::Maybe{Int} = nothing
end

"""
    struct Barrier <: Instruction

- `name`: `"barrier"`.
- `qubits`: List of qubits on which to apply the barrier.
"""
@option struct Barrier <: Instruction
    name::String = "barrier"
    qubits::Vector{Int}
end

"""
    struct Reset <: Instruction

- `name`: `"reset"`.
- `qubits`: List of qubits to reset.
"""
@option struct Reset <: Instruction
    name::String = "reset"
    qubits::Vector{Int}
end

"""
    struct Measure <: Instruction

- `name`: `"measure"`.
- `qubits`: List of qubits to measure.
- `memory`: List of memory slots in which to store the measurement results (must
be the same length as qubits). Subsequent measurements that write to the same
memory slot will overwrite the previous measurement.
- `register` (optional): List of register slots in which to store the measurement
results (must be the same length as qubits). These can be used for fast feedback
(if allowed). The allowed slots for a qubit may be constrained by the backend
register map.
"""
@option struct Measure <: Instruction
    name::String = "measure"
    qubits::Vector{Int}
    memory::Vector{Int}
    register::Maybe{Vector{Int}} = nothing
end

"""
    struct Experiment <: IBMQSchema

- `header` (optional): User-defined structure that contains metadata on each experiment and
is not used by the backend. The header will be passed through to the result data
structure unchanged. For example, this may contain a fitting parameters for the
experiment. In addition, this header can contain a mapping of backend memory
and backend qubits to OpenQASM registers. This is because an OpenQASM
circuit may contain multiple classical and quantum registers, but Qobj flattens
them into a single memory and single set of qubits.
- `config` (optional): Configuration structure for user settings that can be different in each
experiment. These will override the configuration settings of the whole job. See [`ExpConfig`](@ref).
- `instructions`: List of sequence commands that define the experiment. See [`Instruction`](@ref).
"""
@option struct Experiment <: IBMQSchema
    header::Maybe{Dict{String, Any}} = nothing
    # NOTE: the schema specification didn't mention
    # but this can be optional
    config::Maybe{ExpConfig} = nothing
    instructions::Vector{Instruction} = Instruction[]
end

"""
    struct Qobj <: IBMQSchema

Experiments are loaded in through the backend using a Qobj data structure which
encapsulates the user configuration settings and experiment sequences.

- `qobj_id`: User generated run identifier
- `type`: Type of experiment, can be either `"QASM"` for openQASM experiments or `"PULSE"` for OpenPulse experiments.
- `schema_version`: Version of the schema that was used to generate and validate this `Qobj`.
- `experiments`: : List of m experiment sequences to run. Each experiment is an
experiment data structure. Each experiment is run once in the order that they
are specified in this list and then the sequence is repeated until the specified
number of shots has been performed.
- `header` (optional): User-defined structure that contains metadata on the job and is not used
by the backend. The header will be passed through to the result data structure
unchanged. For example, this may contain a description of the full job and/or
the backend that the experiments were compiled for.
- `config`: Configuration settings structure, see also [`ExpConfig`](@ref).
"""
@option struct Qobj <: IBMQSchema
    qobj_id::String = string(uuid1())
    type::String = "QASM"
    schema_version::VersionNumber = v"1.3"
    experiments::Vector{Experiment} = Experiment[]
    header::Maybe{Dict{String, Any}} = nothing
    config::ExpConfig
end

Configurations.to_dict(::Type{T}, x::VersionNumber) where {T <: IBMQSchema} = string(x)

end
