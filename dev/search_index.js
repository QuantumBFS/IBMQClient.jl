var documenterSearchIndex = {"docs":
[{"location":"schema/#Schema","page":"Schema","title":"Schema","text":"","category":"section"},{"location":"schema/","page":"Schema","title":"Schema","text":"Modules = [IBMQClient.Schema]","category":"page"},{"location":"schema/#IBMQClient.Schema.Barrier","page":"Schema","title":"IBMQClient.Schema.Barrier","text":"struct Barrier <: Instruction\n\nname: \"barrier\".\nqubits: List of qubits on which to apply the barrier.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.BooleanFunction","page":"Schema","title":"IBMQClient.Schema.BooleanFunction","text":"struct BooleanFunction <: Instruction\n\nA boolean function is a command that takes in a register as an argument and computes a boolean value that is written back into one of the register slots.\n\nname: \"bfunc\".\nmask: Hex value which is applied as an AND to the register bits. In the given example ,\"0xF\" uses the first 4 bits of the register. The backend may put constraints\n\non the number of register bits that can be used in this function.\n\nrelation: Relational operator for comparing the masked register to the val\n\n(\"=\": equals, \"!=\" not equals).\n\nval: Value to which to compare the masked register. In other words, the output\n\nof the function is (register AND mask) relation val. In the above example this is true when the first 4 register bits are \"0101\"\n\nregister: Register slot in which to store the boolean function result. This\n\nregister value can then be used to apply conditional commands (see the following sections).\n\nmemory (optional): Memory slot in which to store the boolean function result.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.CopyFunction","page":"Schema","title":"IBMQClient.Schema.CopyFunction","text":"struct CopyFunction <: Instruction\n\nA copy function is a command that copies a register slot.\n\nname: \"copy\".\nregister_orig: Register slot to copy.\nregister_copy: Register slot(s) to copy to.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.DeviceInfo","page":"Schema","title":"IBMQClient.Schema.DeviceInfo","text":"struct DeviceInfo <: IBMQSchema\n\nThe backend will have a method Backend.configuration() which returns the required backend config data structure. Backends can include additional items to this structure.\n\nbackend_name: Unique (to provider) backend identifier name. This could describe\n\na setup that goes through several changes, but retains common elements (e.g., for a physical device backend this could include the same coupling map and the physical location, etc.) backend version: Backend version string in the form \"X.X.X\". Versions could indicate, e.g., code changes, equipement upgrades, different cooldowns, new optimizations, etc.\n\nn_qubits: Number of qubits in the backend. Simulator backends return \"-1\".\nbasis_gates: List of the available gates on the backend as an array of gate names\n\n(these should match the entries in gates).\n\ncoupling_map: Representation of the physical coupling map on the device (the\n\ncoupling maps for each gate are defined in gates).\n\ngates: List of the available gates on the backend as a gate config data structure, see GateInfo.\nlocal: Backend runs locally (true) or online (false).\nsimulator: Backend is a simulator (true) or an experimental device (false).\nconditional: Backend supports conditional gates (true) or does not (false).\n\nIndividual gates may also support or not support conditionals.\n\nconfigurable: Backend (if simulator) is configurable (true). If true then there\n\nare user specified configuration parameters (e.g., the topology, noise parameters, etc.). The data structure for these settings is set by the specific backend.\n\nn_registers (required if conditional is true): Specifies the number of registers\n\nslots (i.e. the number of register bits) that are available for conditional operations. Each register can hold a bit value.\n\nregister_map (required if conditional is true): Specifies the registers that each\n\nqubit can store measurements. For this example, qubits 0 and 1 can store in registers 0 and 1, qubit 2 in registers 2 and 3, and qubits 3 and 4 in registers 3 and 4.\n\nopen_pulse: OpenPulse experiments are accepted on this backend.\n\nThe configuration structure may also have the following optional fields,\n\nonline_date: Date that the backend was put online.\ndisplay_name: Alternate name for the backend that is more descriptive that can\n\nbe used for display purposes.\n\nsample_name: Name of the sample for this given backend (likely blank for a\n\nsimulator).\n\ndescription: String to describe the backend.\nurl: Internet address to the backend (if applicable).\ntags: List of tag strings for the backend that indicate true/false properties, e.g.,\n\n\"credits_required\" (backend requires credits to run). Any absent tag means that the property is false and new tags can be added.\n\nquantum_volume: quantum volume of given device.\nmax_experiments: maximum experiment.\nmax_shots: maximum shot can spawn.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.ExpConfig","page":"Schema","title":"IBMQClient.Schema.ExpConfig","text":"struct ExpConfig <: IBMQSchema\n\nshots: Number of times to repeat the experiment (for some simulators this may\n\nbe limited to 1, e.g., a unitary simulator).\n\nmemory_slots: Number of classical memory slots used in this job. Memory slots\n\nare used to record the results of qubit measurements and read out at the end of an experiment. They cannot be used for feedback (those are the registers).\n\nseed (optional): Randomization seed for simulators.\nmax_credits (optional): For credit-based backends, the maximum number of\n\ncredits that a user is willing to spend on this run (an error will be thrown if the run required more than max credits).\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.ExpData","page":"Schema","title":"IBMQClient.Schema.ExpData","text":"struct ExpData <: IBMQSchema\n\nThe measurement data that is returned in exp data has one of several possible forms: as a histogram of counts of the memory states, the memory, or (for simulators) the statevector or unitary matrix.\n\ncounts: Histogram of counts in the different memory states. Only states with\n\nnon-zero counts are listed as keys. The states are labeled in hex (e.g., a 4 slot memory \"1010\" (bit string) is decimal 10 and hex \"0xA\").\n\nmemory: State of the classical memory. For OpenQASM (or OpenPulse Level 2)\n\nthis is a list of hex strings indicating the state for each shot.\n\nstatevector (optional): Final statevector corresponding to evolution of the zero state.\nunitary (optional): Final unitary matrix corresponding to the quantum circuit.\nsnapshots (optional): Snapshots data structure that returns data as dictated by the snapshot\n\ncommand used by simulators.\n\nSnapshots\n\nThe snapshot is a special command reserved for simulators which allows a \"snapshot\" of the simulator state to be recorded.\n\n{\n    \"name\": \"snapshot\",\n    \"label\": \"snap1\",\n    \"type\": \"state\"\n}\n\nname: \"snapshot\".\nlabel: Snapshot label which is used to identify the snapshot in the output.\ntype: Type of snapshot, e.g., \"state\" (take a snapshot of the quantum state).\n\nThe types of snapshots offered are defined in a separate specification document for simulators.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.ExpResult","page":"Schema","title":"IBMQClient.Schema.ExpResult","text":"struct ExpResult <: IBMQSchema\n\nEach individual experiment returns an exp result data structure.\n\nshots: If a single integer, then this is the number of shots taken to obtain this\n\ndata (s = n₁). If the backend allows asynchronous calls to measurement, the value of n₂ will increase as more data is taken. For backends that return the data in sections (e.g. for bandwidth reasons) shots is given as a two-element list where the data is from shot n₁ to shot n₂ (s = n₂  n₁). The next call will give the data starting at n₂ + 1.\n\nstatus: Status message for this particular experiment.\nsuccess: Success of the experiment (bool).\nheader (optional): Header structure for the experiment that was passed in with the Qobj.\nseed (optional): Experiment seed (for simulator backends).\nmeas_return (optional): String which determines whether the returned data is\n\naveraged over the shots avg or contains each shot single. This is an OpenPulse option, but could also apply to snapshots.\n\ndata: Generic return experiment data structure exp data that will depend on\n\nthe type of experiment (\"QASM\" or \"PULSE\") and/or the type of backend (e.g. simulator data). See below.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Experiment","page":"Schema","title":"IBMQClient.Schema.Experiment","text":"struct Experiment <: IBMQSchema\n\nheader (optional): User-defined structure that contains metadata on each experiment and\n\nis not used by the backend. The header will be passed through to the result data structure unchanged. For example, this may contain a fitting parameters for the experiment. In addition, this header can contain a mapping of backend memory and backend qubits to OpenQASM registers. This is because an OpenQASM circuit may contain multiple classical and quantum registers, but Qobj flattens them into a single memory and single set of qubits.\n\nconfig (optional): Configuration structure for user settings that can be different in each\n\nexperiment. These will override the configuration settings of the whole job. See ExpConfig. instructions: List of sequence commands that define the experiment. See Instruction.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Gate","page":"Schema","title":"IBMQClient.Schema.Gate","text":"struct Gate <: Instruction\n\nname: Name of the gate.\nqubits: List of qubits to apply the gate.\nparams (optional): List of parameters for the gate (if the gate has parameters,\n\nsuch as u1, u2, u3).\n\ntexparams (optional): List of parameters for the gate in latex notation.\nconditional (optional): Apply the gate if the given register (in this example\n\nregister 3) is 1 (true) and conditionals are supported. If left blank then the gate has no conditional element (i.e. no feedback). By default this is blank.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.GateInfo","page":"Schema","title":"IBMQClient.Schema.GateInfo","text":"struct GateInfo <: IBMQSchema\n\nThe gate config data structure has the following keys.\n\nname: Gate name, as it will be referred to in the OpenQASM circuit.\nparameters: List of parameters for the gate (empty if no parameters).\ncoupling_map (optional): List of qubits that the gate applies to, each element of the list is\n\nan n-qubit list where n is the size of the gate (e.g. 1-qubit gate, 2-qubit gate).\n\nqasm_def: OpenQASM definition of the gate in terms of the basis gates [U,CX].\n\nEach unitary gate has an efficient representation in this basis.\n\nconditional (optional): Gate supports conditional operation (true/false). If not\n\nlisted then defaults to the backend setting.\n\nlatency_map (optional): List for each gate of length n registers that indicates\n\nif the feedback speed to the register is fast (1) or slow (0). In the above example the u3 gate for qubit 0 has low latency for conditionals to register 0, but qubits 1 and 2 have low latency to both registers 1 and 2.\n\ndescription (optional): Description of the gate.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.GateProp","page":"Schema","title":"IBMQClient.Schema.GateProp","text":"struct GateProp <: IBMQSchema\n\nqubits: Qubits involved in the gate.\ngate: Gate name, must be one of the gates from \"gates\" in the backend configuration structure.\nparameters: List of parameter structures which could generically include \"gate_err\"\n\n(by gate error we mean the 1−Favg for the particular gate) and \"gate_time\". Note that each backend may measure gate error using different methodologies, this will have to be conveyed by the backend over separate channels (e.g. at the URL).\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Instruction","page":"Schema","title":"IBMQClient.Schema.Instruction","text":"abstract type Instruction <: IBMQSchema end\n\nAbstract type for Qobj schema instructions.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.JobStatus","page":"Schema","title":"IBMQClient.Schema.JobStatus","text":"struct JobStatus <: IBMQSchema\n\nA call to Job.status() returns back a job status data structure of the following form.\n\njob_id: Backend generated id corresponding to this job (this will only be nonzero\n\nif the job has been successfully initialized and accepted to run on the backend).\n\nstatus: String value corresponding to the job status (\"ERROR\",\"QUEUED\",\n\n\"INITIALIZING\", \"RUNNING\", \"CANCELLED\" and \"DONE\").\n\nstatus_msg: Backend defined status message.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Measure","page":"Schema","title":"IBMQClient.Schema.Measure","text":"struct Measure <: Instruction\n\nname: \"measure\".\nqubits: List of qubits to measure.\nmemory: List of memory slots in which to store the measurement results (must\n\nbe the same length as qubits). Subsequent measurements that write to the same memory slot will overwrite the previous measurement.\n\nregister (optional): List of register slots in which to store the measurement\n\nresults (must be the same length as qubits). These can be used for fast feedback (if allowed). The allowed slots for a qubit may be constrained by the backend register map.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.NDUV","page":"Schema","title":"IBMQClient.Schema.NDUV","text":"struct NDUV <: IBMQSchema\n\nEach of the parameters is expressed as a nduv struct (name-date-unit-value structure) as below,\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Properties","page":"Schema","title":"IBMQClient.Schema.Properties","text":"struct Properties <: IBMQSchema\n\nThe backend will have a call Backend.properties() which will return a backend props data structure with backend properties (e.g. calibrations and coherences). Note that this information is optionally provided by the backend, which will set how often and/or under what conditions calibrations and characterizations need to be updated.\n\nbackend_name, backend_version: Backend identifiers (from Backend.configuration())\n\nthat specify what backend these results were obtained from.\n\nlast_update_date: Date/time of the last run calibration.\ngates: List of the qubit gate parameters (as a gate prop structure, see below).\nqubits: List of list of qubit parameters (e.g. coherences) which is in order of the\n\nqubits. The qubit parameters could generically include “T1”, “T2”, “readoutErr” and “frequency”.\n\ngeneral: List of general backend parameters, see NDUV.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Qobj","page":"Schema","title":"IBMQClient.Schema.Qobj","text":"struct Qobj <: IBMQSchema\n\nExperiments are loaded in through the backend using a Qobj data structure which encapsulates the user configuration settings and experiment sequences.\n\nqobj_id: User generated run identifier\ntype: Type of experiment, can be either \"QASM\" for openQASM experiments or \"PULSE\" for OpenPulse experiments.\nschema_version: Version of the schema that was used to generate and validate this Qobj.\nexperiments: : List of m experiment sequences to run. Each experiment is an\n\nexperiment data structure. Each experiment is run once in the order that they are specified in this list and then the sequence is repeated until the specified number of shots has been performed.\n\nheader (optional): User-defined structure that contains metadata on the job and is not used\n\nby the backend. The header will be passed through to the result data structure unchanged. For example, this may contain a description of the full job and/or the backend that the experiments were compiled for.\n\nconfig: Configuration settings structure, see also ExpConfig.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Reset","page":"Schema","title":"IBMQClient.Schema.Reset","text":"struct Reset <: Instruction\n\nname: \"reset\".\nqubits: List of qubits to reset.\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Result","page":"Schema","title":"IBMQClient.Schema.Result","text":"struct Result <: IBMQSchema\n\nThe results data structure from Job.result().\n\nbackend_name, backend_version: Backend identifiers that specify what backend these results were obtained from.\nqobj_id: User generated id corresponding to the qobj id in the Qobj.\njob_id: Unique backend job identifier corresponding to these results.\ndate: Date when the job was run.\nheader (optional): Header structure for the job that was passed in with the Qobj.\nresults: List of m (number of experiments) exp result data structures (defined below).\n\n\n\n\n\n","category":"type"},{"location":"schema/#IBMQClient.Schema.Status","page":"Schema","title":"IBMQClient.Schema.Status","text":"struct Status <: IBMQSchema\n\nThe backend will have a call Backend.status() which returns status information on the backend in the backend status structure (only the operational and status msg fields are required),\n\nbackend_name, backend_version: Backend identifiers that specify the backend.\noperational: Backend is operational (true/false), i.e., currently running jobs.\npending_jobs: Number of jobs in the queue for the backend (if no queue return\n\n0).\n\nstatus_msg: Status message for the backend. For example, `\"The backend is down\n\nfor calibration, will be back at 19:00\"`.\n\n\n\n\n\n","category":"type"},{"location":"#IBMQClient","page":"Quick Start","title":"IBMQClient","text":"","category":"section"},{"location":"","page":"Quick Start","title":"Quick Start","text":"(Image: Build Status) (Image: Coverage)","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"Julia Wrapper for the IBM Quantum Experience REST API. This API wrapper is based on IBM Q official implementation but is not an IBM official package.","category":"page"},{"location":"#Usage","page":"Quick Start","title":"Usage","text":"","category":"section"},{"location":"","page":"Quick Start","title":"Quick Start","text":"create an AccountInfo","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"using IBMQClient\nusing IBMQClient.Schema\naccount = AccountInfo(token)","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"create an Qobj based on the Qobj schema specification, e.g","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"qobj = Qobj(;\n    qobj_id=\"bell_Qobj_07272018\",\n    type=\"QASM\",\n    schema_version=v\"1\",\n    header=Dict(\"description\"=>\"Bell states\"),\n    config=ExpConfig(shots=1000, memory_slots=2),\n    experiments=[\n        Experiment(;\n            header=Dict(\"description\"=>\"|11>+|00> Bell\"),\n            instructions=[\n                Gate(name=\"u2\", qubits=[0], params=[0.0, π]),\n                Gate(name=\"cx\", qubits=[0, 1]),\n                Measure(qubits=[0, 1], memory=[0, 1]),\n            ]\n        ),\n        Experiment(;\n            header=Dict(\"description\"=>\"|01>+|10> Bell\"),\n            instructions=[\n                Gate(name=\"u2\", qubits=[0], params=[0.0, π]),\n                Gate(name=\"cx\", qubits=[0, 1]),\n                Gate(name=\"u3\", qubits=[0], params=[π, 0.0, π]),\n                Measure(qubits=[0, 1], memory=[0, 1]),\n            ]\n        )\n    ]\n)","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"find an available device","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"devices = IBMQClient.devices(account)","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"submit the job","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"job_info = IBMQClient.submit(account, RemoteJob(dev=devices[1]), qobj)","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"query the job status","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"job_info = IBMQClient.status(account, job_info)","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"download the results when job_info has status COMPLETED","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"IBMQClient.results(account, job_info)","category":"page"},{"location":"#REPL-Terminal-Menu","page":"Quick Start","title":"REPL Terminal Menu","text":"","category":"section"},{"location":"","page":"Quick Start","title":"Quick Start","text":"We have a Terminal Menu for easy-reading IBM device information in terminal. You can start it by","category":"page"},{"location":"","page":"Quick Start","title":"Quick Start","text":"julia> using REPL.TerminalMenus\njulia> menu = IBMQClient.DeviceMenu(devices)\njulia> choice = request(\"choose a device:\", menu)\nchoose a device:\n   ibmq_qasm_simulator            nqubits: 1\n   ibmqx2                         max_shots: 8192\n   ibmq_16_melbourne              credits_required:: true\n → ibmq_armonk\nv  ibmq_athens","category":"page"},{"location":"#API-References","page":"Quick Start","title":"API References","text":"","category":"section"},{"location":"","page":"Quick Start","title":"Quick Start","text":"Modules = [IBMQClient]","category":"page"},{"location":"#IBMQClient.AccountInfo","page":"Quick Start","title":"IBMQClient.AccountInfo","text":"struct AccountInfo\n\nAccountInfo([token=read_token()])\n\nCreate an AccountInfo object from given IBMQ API token. You can create your own token at https://quantum-computing.ibm.com/ after login. It will look at ~/.qiskit/qiskitrc for the API token by default. See read_token for more information.\n\n\n\n\n\n","category":"type"},{"location":"#IBMQClient.AuthAPI","page":"Quick Start","title":"IBMQClient.AuthAPI","text":"AuthAPI <: IBMQAPI\n\nIBM Q Authentication REST API.\n\n\n\n\n\n","category":"type"},{"location":"#IBMQClient.IBMQAPI","page":"Quick Start","title":"IBMQClient.IBMQAPI","text":"abstract REST API type for IBM Q\n\n\n\n\n\n","category":"type"},{"location":"#IBMQClient.ProjectAPI","page":"Quick Start","title":"IBMQClient.ProjectAPI","text":"ProjectAPI <: IBMQAPI\n\nIBM Q Project REST API.\n\n\n\n\n\n","category":"type"},{"location":"#IBMQClient.ProjectAPI-Tuple{URIs.URI, String, String, String}","page":"Quick Start","title":"IBMQClient.ProjectAPI","text":"ProjectAPI(base, hub::String, group::String, project::String)\n\nCreate IBM Q Project REST API from given base uri, hub, group and project name project.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.ServiceAPI","page":"Quick Start","title":"IBMQClient.ServiceAPI","text":"ServiceAPI <: IBMQAPI\n\nIBM Q service REST API.\n\n\n\n\n\n","category":"type"},{"location":"#IBMQClient.ServiceAPI-Tuple{AuthAPI, String}","page":"Quick Start","title":"IBMQClient.ServiceAPI","text":"ServiceAPI(::AuthAPI, access_token::String)\n\nCreate IBM Q service REST API by querying authentication server.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.ServiceAPI-Tuple{}","page":"Quick Start","title":"IBMQClient.ServiceAPI","text":"ServiceAPI([uri=\"https://api.quantum-computing.ibm.com/api\"])\n\nCreate IBM Q service REST API object.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.create_headers","page":"Quick Start","title":"IBMQClient.create_headers","text":"create_headers(api::IBMQAPI[, headers=HTTP.Header[]; kw...])\n\nCreate headers for a IBMQ REST API object.\n\n\n\n\n\n","category":"function"},{"location":"#IBMQClient.create_remote_job-Tuple{ProjectAPI, String, String}","page":"Quick Start","title":"IBMQClient.create_remote_job","text":"create_remote_job(api::ProjectAPI, device::IBMQDevice, access_token::String; job_name=nothing, job_share_level=nothing, job_tags=nothing)\n\nCreate a job instance on the remote server.\n\nArgs\n\ndevice_name: A IBM Q device name.\njob_name: Custom name to be assigned to the job.\njob_share_level: Level the job should be shared at.\njob_tags: Tags to be assigned to the job.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.devices-Tuple{AccountInfo}","page":"Quick Start","title":"IBMQClient.devices","text":"devices(x::AccountInfo)\n\nQuery available devices using given AccountInfo.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.devices-Tuple{ProjectAPI, String}","page":"Quick Start","title":"IBMQClient.devices","text":"devices(api::ProjectAPI, access_token::String; timeout = 0)\n\nQuery available devices.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.hubs-Tuple{ServiceAPI, String}","page":"Quick Start","title":"IBMQClient.hubs","text":"hubs(api::ServiceAPI, access_token::String)\n\nGet alll IBM hubs.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.jobs-Tuple{AccountInfo}","page":"Quick Start","title":"IBMQClient.jobs","text":"jobs(x::AccountInfo; kw...)\n\nQuery jobs submitted using given AccountInfo.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.jobs-Tuple{ProjectAPI, String}","page":"Quick Start","title":"IBMQClient.jobs","text":"jobs(api::ProjectAPI, access_token::String; descending::Bool=true, limit::Int=10, skip::Int=0, extra_filter=nothing)\n\nQuery available jobs. \n\nArgs\n\nlimit: Maximum number of items to return.\nskip: Offset for the items to return.\ndescending: Whether the jobs should be in descending order.\nextra_filter: Additional filtering passed to the query.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.login","page":"Quick Start","title":"IBMQClient.login","text":"login([qiskitrc::String=\"~/.qiskit/qiskitrc\"])\n\nLogin from local qiskitrc cache.\n\n\n\n\n\n","category":"function"},{"location":"#IBMQClient.login-Tuple{AuthAPI, String}","page":"Quick Start","title":"IBMQClient.login","text":"login(::AuthAPI, token::String)\n\nLogin with user token.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.read_token","page":"Quick Start","title":"IBMQClient.read_token","text":"read_token(qiskitrc::String[=expanduser(\"~/.qiskit/qiskitrc\")])\n\nRead IBMQ API token from .qiskit/qiskitrc file. Default location is ~/.qiskit/qiskitrc.\n\n\n\n\n\n","category":"function"},{"location":"#IBMQClient.results-Tuple{AccountInfo, JobInfo}","page":"Quick Start","title":"IBMQClient.results","text":"results(account::AccountInfo, job::JobInfo; use_object_storage::Bool = true)\n\nDownload the results of given job, return nothing if the job status is not COMPLETED.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.status-Tuple{AccountInfo, JobInfo}","page":"Quick Start","title":"IBMQClient.status","text":"status(account::AccountInfo, job::JobInfo)\n\nQuery the current status of job.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.submit-Tuple{AccountInfo, RemoteJob, Qobj}","page":"Quick Start","title":"IBMQClient.submit","text":"submit(account::AccountInfo, remote_job::RemoteJob, qobj::Schema.Qobj)\n\nSubmit a Qobj to remote device as a remote_job.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.user_hubs-Tuple{ServiceAPI, String}","page":"Quick Start","title":"IBMQClient.user_hubs","text":"user_hubs(api::ServiceAPI, access_token::String)\n\nGet given users' hubs.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.user_info-Tuple{AuthAPI, String}","page":"Quick Start","title":"IBMQClient.user_info","text":"user_info(::AuthAPI, access_token::String)\n\nGet user info of given IBM Q account access token.\n\n\n\n\n\n","category":"method"},{"location":"#IBMQClient.user_urls-Tuple{AuthAPI, String}","page":"Quick Start","title":"IBMQClient.user_urls","text":"user_urls(::AuthAPI, access_token::String)\n\nGet user urls to create services etc.\n\n\n\n\n\n","category":"method"}]
}
