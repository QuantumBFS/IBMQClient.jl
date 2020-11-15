const Maybe{T} = Union{Nothing, T}

"abstract REST API type for IBM Q"
abstract type IBMQAPI <: REST.AbstractAPI end

function create_headers(::IBMQAPI, headers=HTTP.Header[]; kw...)
    headers = HTTP.mkheaders(headers)
    # insert headers
    # TODO: use version
    HTTP.setkv(headers, "X-Qx-Client-Application", "IBMQClient.jl")
    HTTP.setkv(headers, "Connection", "keep-alive")
    HTTP.setkv(headers, "Accept", "*/*")
    access_token = get(kw, :access_token, nothing)
    if access_token === nothing
        HTTP.rmkv(headers, "X-Access-Token")
    else
        HTTP.setkv(headers, "X-Access-Token", access_token)
    end
    return headers
end

# handle authentication
function REST.request(api::IBMQAPI, method::String, path::String, body=HTTP.nobody; headers=HTTP.Header[], kw...)
    headers = create_headers(api, headers; kw...)

    if body === nothing
        body = HTTP.nobody
    elseif body isa Dict
        # we convert Julia Dict to JSON in IBMQ REST API
        HTTP.setkv(headers, "Content-Type", "application/json")
        if body isa Dict
            body = JSON.json(body)
        end
    elseif body isa Vector{UInt8}
    elseif body isa AbstractString
    else
        error("invalid content type: $(typeof(body))")
    end

    return REST.request(REST.API(api), method, path, body; headers=headers, kw...)
end

# NOTE:
# unlike qiskit we want to distinguish and error when
# method does not exist in certain REST API endpoint.

Base.@kwdef struct AuthAPI <: IBMQAPI
    endpoint::URI = URI("https://auth.quantum-computing.ibm.com/api")
end

function login(api::AuthAPI, token::String)
    return REST.post(api, "users/loginWithToken", Dict("apiToken" => token)) |> REST.json
end

function user_info(api::AuthAPI, access_token::String)
    return REST.get(api, "users/me"; access_token=access_token) |> REST.json
end

function user_urls(api::AuthAPI, access_token::String)
    return user_info(api, access_token)["urls"]
end

struct ServiceAPI <: IBMQAPI
    endpoint::URI
end

ServiceAPI() = ServiceAPI("https://api.quantum-computing.ibm.com/api")
ServiceAPI(uri::String) = ServiceAPI(URI(uri))

function ServiceAPI(auth::AuthAPI, access_token::String)
    return ServiceAPI(URI(user_urls(auth, access_token)["http"]))
end

function hubs(api::ServiceAPI, access_token::String)
    return REST.get(api, "Network"; access_token=access_token) |> REST.json
end

function user_hubs(api::ServiceAPI, access_token::String)
    ret_hubs = NamedTuple{(:hub, :group, :project), NTuple{3, String}}[]
    for hub in hubs(api, access_token)
        hub_name = hub["name"]
        for (group_name, group) in hub["groups"], (project_name, project) in group["projects"]
            entry = (
                    hub = hub_name,
                    group = group_name,
                    project = project_name,)

            if Base.get(project, "isDefault", false)
                insert!(ret_hubs, 1, entry)
            else
                push!(ret_hubs, entry)
            end
        end
    end
    return ret_hubs
end

# this is similar to Account class in qiskit
struct ProjectAPI <: IBMQAPI
    endpoint::URI
end

function ProjectAPI(base::URI, hub::String, group::String, project::String)
    return ProjectAPI(base.uri, hub, group, project)
end

function ProjectAPI(base::String, hub::String, group::String, project::String)
    return ProjectAPI(URI(base * ibmq_template_hubs(hub, group, project)))
end

function ibmq_template_hubs(hub::String, group::String, project::String)
    return "/Network/$hub/Groups/$group/Projects/$project"
end

function indent(io::IO, offset=0)
    return " "^(Base.get(io, :indent, 0) + offset)
end

struct GateInfo
    name::String
    parameters::Vector{String}
    qasm::String
    couping_map::Union{Nothing, Vector{Vector{Int}}}
end

function GateInfo(d::Dict)
    return GateInfo(d["name"], d["parameters"], d["qasm_def"], Base.get(d, "coupling_map", nothing))
end

function Base.show(io::IO, x::GateInfo)
    print(io, indent(io), "GateInfo")
    println(io, "(")
    println(io, indent(io, 2), "name=", repr(x.name))
    println(io, indent(io, 2), "parameters=[", join(map(repr, x.parameters), ", "), "]")
    # TODO: use QASM parser from YaoLang to pretty print this
    # println(io, " "^indent, "qasm=...")

    # TODO: plot the couping_map in terminal
    # println(io, " "^indent, "couping_map=...")
    print(io, indent(io), ")")
end

Base.@kwdef struct IBMQDevice
    name::String
    description::String
    credits_required::Bool
    # well we can't use local in Julia
    remote::Bool
    simulator::Bool
    version::String
    nqubits::Int
    gates::Vector{GateInfo}
    basis_gates::Vector{String}
    open_pulse::Bool
    max_shots::Int
    quantum_volume::Maybe{Int}
    support_instructions::Vector{String}
    raw::Dict
end

function IBMQDevice(d::Dict)
    IBMQDevice(;
        name=d["backend_name"],
        description=Base.get(d, "description", ""),
        credits_required=Base.get(d, "credits_required", false),
        remote=!d["local"],
        simulator=d["simulator"],
        version=d["backend_version"],
        nqubits=d["n_qubits"],
        gates=GateInfo.(d["gates"]),
        basis_gates=d["basis_gates"],
        open_pulse=d["open_pulse"],
        max_shots=d["max_shots"],
        quantum_volume=Base.get(d, "quantum_volume", nothing),
        support_instructions=Base.get(d, "support_instructions", String[]),
        raw=d,
    )
end

function _print_item(io::IO, key, value)
    print(io, indent(io, 2))
    printstyled(io, key, ": "; color=:light_blue)
    printstyled(io, value; color=:green)
    println(io)
end

function Base.show(io::IO, d::IBMQDevice)
    println(io, indent(io), "IBMQDevice:")
    _print_item(io, "name", d.name)
    _print_item(io, "nqubits", d.nqubits)
    _print_item(io, "max_shots", d.max_shots)
    _print_item(io, "credits_required", d.credits_required)
    _print_item(io, "version", d.version)
end

function devices(api::ProjectAPI, access_token::String; timeout = 0)
    raw_devs = REST.get(api, "devices/v/1"; readtimeout = timeout, access_token = access_token) |> REST.json
    return [IBMQDevice(dev) for dev in raw_devs]
end

function jobs(api::ProjectAPI, access_token::String; descending::Bool=true, limit::Int=10, skip::Int=0, extra_filter=nothing)
    order = descending ? "DESC" : "ASC"
    query = Dict{String, Any}(
        "order" => "creationDate " * order,
        "limit" => limit,
        "skip" => skip,
    )

    if !isnothing(extra_filter)
        query["where"] = extra_filter
    end

    REST.get(api, "Jobs/status/v/1"; access_token=access_token, query=Dict("filter" => JSON.json(query))) |> REST.json
end

function create_remote_job(api::ProjectAPI, device::IBMQDevice, access_token::String; job_name=nothing, job_share_level=nothing, job_tags=nothing)
    payload = Dict{String, Any}(
        "backend" => Dict{String, Any}(
            "name" => device.name,
        ),
        "allowObjectStorage" => true,
    )

    if !isnothing(job_name)
        payload["name"] = job_name
    end

    if !isnothing(job_share_level)
        payload["shareLevel"] = job_share_level
    end

    if !isnothing(job_tags)
        payload["tags"] = job_tags
    end

    return REST.post(api, "Jobs", payload; access_token=access_token) |> REST.json
end

function create_qobj(device::IBMQDevice, experiments::Dict...;
    schema_version="1.3.0", type="QASM", shots::Int=1024, memory::Bool=false, parameter_binds=[],
    init_qubits::Bool=true, parametric_pulses=[], memory_slots::Int=-1, n_qubits::Int=-1)

    for ex in experiments
        config = ex["config"]
        if haskey(config, "n_qubits")
            n_qubits = max(config["n_qubits"], n_qubits)
        end

        if haskey(config, "memory_slots")
            memory_slots = max(config["memory_slots"], memory_slots)
        end
    end

    n_qubits > 0 || error("please specify the number of qubits")
    memory_slots > 0 || error("please specify the number of memory slots")

    return Dict{String, Any}(
        "qobj_id" => string(uuid1()),
        "header" => Dict{String, Any}(
            "backend_name" => device.name,
            "backend_version" => device.version,
        ),
        "config" => Dict{String, Any}(
            "memory" => memory,
            "parameter_binds" => parameter_binds,
            "init_qubits" => init_qubits,
            "parametric_pulses" => parametric_pulses,
            "memory_slots" => memory_slots,
            "n_qubits" => n_qubits,
        ),
        "schema_version" => schema_version,
        "type" => type,
        "experiments" => collect(Any, experiments)
    )
end

struct JobAPI <: IBMQAPI
    endpoint::URI
end

function JobAPI(api::ProjectAPI, job_id::String)
    JobAPI(joinpath(api.endpoint, "Jobs/$job_id"))
end

function upload_url(api::JobAPI, access_token::String)
    REST.get(api, "jobUploadUrl"; access_token=access_token) |> REST.json
end

function retreive_job_info(api::JobAPI, access_token::String)
    REST.get(api, "v/1"; access_token=access_token) |> REST.json
end

function cancel(api::JobAPI, access_token::String)
    REST.post(api, "cancel"; access_token=access_token) |> REST.json
end

function properties(api::JobAPI, access_token::String)
    REST.get(api, "properties"; access_token=access_token) |> REST.json
end

function result_url(api::JobAPI, access_token::String)
    REST.get(api, "resultDownloadUrl"; access_token=access_token) |> REST.json
end

function download_url(api::JobAPI, access_token::String)
    REST.get(api, "jobDownloadUrl"; access_token=access_token) |> REST.json
end

function status(api::JobAPI, access_token::String)
    REST.get(api, "status/v/1"; access_token=access_token) |> REST.json
end

function put_object_storage(api::JobAPI, url::String, qobj::Dict{String, Any}, access_token::String)
    HTTP.put(url, create_headers(api; access_token=access_token), JSON.json(qobj); readtimeout=600)
end

function get_object_storage(api::JobAPI, url::String, access_token::String)
    HTTP.get(url, create_headers(api; access_token=access_token); readtimeout=600) |> REST.json
end

function callback_upload(api::JobAPI, access_token::String)
    REST.post(api, "jobDataUploaded"; access_token=access_token) |> REST.json
end

function callback_download(api::JobAPI, access_token::String)
    REST.post(api, "resultDownloaded"; access_token=access_token) |> REST.json
end

function submit(api::ProjectAPI, device::IBMQDevice, qobj::Dict{String, Any}, access_token::String; kw...)
    job_info = create_remote_job(api, device, access_token; kw...)

    job_id = job_info["id"]
    upload_url = job_info["objectStorageInfo"]["uploadUrl"]

    job_api = JobAPI(api, job_id)

    try
        put_object_storage(job_api, upload_url, qobj, access_token)
        response = callback_upload(job_api, access_token)
        return response["job"]
    catch e
        if e isa HTTP.ExceptionRequest.StatusError
            try
                cancel(job_api, access_token)
            catch e
                if !(e isa HTTP.ExceptionRequest.StatusError)
                    rethrow(e)
                end
            end
        else
            rethrow(e)
        end
    end
    return
end

struct Job
    api::JobAPI
    access_token::String
end
