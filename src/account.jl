mutable struct AccountInfo
    access_token::String
    user_info::Dict{String, Any}
    auth::AuthAPI
    service::ServiceAPI
    project::ProjectAPI
end

function AccountInfo(token::String)
    auth = AuthAPI()
    response = login(auth, token)
    access_token = response["id"]
    info = user_info(auth, access_token)
    service = ServiceAPI(info["urls"]["http"])
    user_hub = first(user_hubs(service, access_token))
    project = ProjectAPI(service.endpoint, user_hub.hub, user_hub.group, user_hub.project)
    return AccountInfo(access_token, info, auth, service, project)
end

# TODO: forward other REST APIs
user_urls(x::AccountInfo) = user_urls(x.auth, x.access_token)
hubs(x::AccountInfo) = hubs(x.service, x.access_token)
user_hubs(x::AccountInfo) = user_hubs(x.service, x.access_token)
devices(x::AccountInfo) = devices(x.project, x.access_token)
jobs(x::AccountInfo; kw...) = jobs(x.project, x.access_token; kw...)
create_remote_job(x::AccountInfo, dev::IBMQDevice; kw...) = create_remote_job(x.project, dev, x.access_token; kw...)

function Base.show(io::IO, ::MIME"text/plain", x::AccountInfo)
    indent = get(io, :indent, 0)
    println(io, " "^indent, "AccountInfo:")
    println(io, " "^indent, LIGHT_BLUE_FG("  email:        "), x.user_info["email"])
    print(io, " "^indent, LIGHT_BLUE_FG("  institution:  "), x.user_info["institution"])
end

Base.@kwdef struct JobInfo
    id::String
    name::Maybe{String}
    share_level::Maybe{String}
    tags::Maybe{Vector{String}}
    account::AccountInfo
    api::JobAPI

    device::IBMQDevice
    hub::String
    group::String
    project::String

    qobj::Dict{String, Any}
end

function Base.show(io::IO, ::MIME"text/plain", job::JobInfo)
    indent = get(io, :indent, 0)
    println(io, " "^indent, "JobInfo:")
    println(io, " "^indent, LIGHT_BLUE_FG("id: "), GREEN_FG(job.id))

    if job.name !== nothing
        println(io, " "^indent, LIGHT_BLUE_FG("name: "), GREEN_FG(job.name))
    end

    if job.tags !== nothing
        println(io, " "^indent, LIGHT_BLUE_FG("tags: "), GREEN_FG(string(job.tags)))
    end

    response = status(job.api, job.account.access_token)

    println(io, " "^indent, LIGHT_BLUE_FG("status: "), GREEN_FG(response["status"]))
    println(io, " "^indent, LIGHT_BLUE_FG("provider: "), GREEN_FG(join((job.hub, job.group, job.project), "/")))
    println(io, " "^indent, LIGHT_BLUE_FG("device: "))
    println(io)
    print(IOContext(io, :indent=>(indent+2)), job.device)
end

function submit(account::AccountInfo, device::IBMQDevice, qobj::Dict{String, Any}; job_name=nothing, job_share_level=nothing, job_tags=nothing)
    job_info = create_remote_job(account, device; job_name=job_name, job_share_level=job_share_level, job_tags=job_tags)

    job_id = job_info["id"]
    upload_url = job_info["objectStorageInfo"]["uploadUrl"]

    job_api = JobAPI(account.project, job_id)

    try
        put_object_storage(job_api, upload_url, qobj, account.access_token)
        response = callback_upload(job_api, account.access_token)
        return JobInfo(;
            id = job_id,
            name = job_name,
            share_level = job_share_level,
            tags = job_tags,
            account = account,
            api = job_api,
            device = device,
            hub = response["job"]["hubInfo"]["hub"]["name"],
            group = response["job"]["hubInfo"]["group"]["name"],
            project = response["job"]["hubInfo"]["project"]["name"],
            qobj = qobj,
        )
    catch e
        if e isa HTTP.ExceptionRequest.StatusError
            try
                cancel(job_api, account.access_token)
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

# NOTE: let's change UInt to BigInt
# when IBM has larger machines
struct DataInfo
    name::String
    n_qubits::Int
    counts::Dict{UInt, Int}
    time_token::Float64
    raw::Dict{String, Any}
end

function DataInfo(d::Dict)
    name = d["header"]["name"]
    time_taken = d["time_taken"]
    data = d["data"]
    c = Dict{UInt, Int}()
    for (k, v) in data["counts"]
        c[parse(UInt, k)] = v
    end
    # NOTE: we need to make sure our codegen put this info in header
    return DataInfo(name, d["header"]["n_qubits"], c, time_taken, d)
end

function print_data(io::IO, info::DataInfo, idx::Int = -1)
    indent = get(io, :indent, 0)
    if idx > 0
        println(io, " "^(indent-3), LIGHT_BLUE_FG("$idx: name: "), info.name)
    else
        println(io, " "^indent, LIGHT_BLUE_FG("name: "), info.name)
    end
    println(io, " "^indent, LIGHT_BLUE_FG("time_taken: "), info.time_token)
    println(io, " "^indent, LIGHT_BLUE_FG("counts: "))

    for (i, (b, c)) in enumerate(info.counts)
        print(io, " "^(indent+2), GREEN_FG(string(b; base=2, pad=info.n_qubits)), "=>", c)

        if i != length(info.counts)
            println(io)
        end
    end
end

function Base.show(io::IO, m::MIME"text/plain", info::DataInfo)
    indent = get(io, :indent, 0)
    println(io, " "^indent, "DataInfo:")
    print_data(IOContext(io, :indent=>indent+2), info)
end

struct ResultInfo
    job::JobInfo
    qobj_id::String
    success::Bool
    meta::Dict{String, Any}
    data::Vector{DataInfo}

    raw::Dict{String, Any}
end

function ResultInfo(job::JobInfo, d::Dict)
    ResultInfo(
        job,
        d["qobj_id"],
        d["success"],
        d["metadata"],
        DataInfo.(d["results"]),
        d
    )
end

function Base.show(io::IO, m::MIME"text/plain", info::ResultInfo)
    indent = get(io, :indent, 0)
    println(io, " "^indent, "ResultInfo:")
    println(io, " "^indent, "  job_id: ", GREEN_FG(info.job.id))
    println(io, " "^indent, "  data:")
    for k in 1:length(info.data)
        print_data(IOContext(io, :indent=>indent+6), info.data[k], k)

        if k != lastindex(info.data)
            println(io)
        end
    end
end

function result(job::JobInfo; use_object_storage::Bool = true)
    response = status(job.api, job.account.access_token)
    response["status"] == "COMPLETED" || return

    if use_object_storage
        url = result_url(job.api, job.account.access_token)["url"]
        result_response = get_object_storage(job.api, url, job.account.access_token)

        try
            callback_download(job.api, job.account.access_token)
        catch e
            if e isa HTTP.ExceptionRequest.StatusError
                error("An error occurred while sending download completion acknowledgement.")
            else
                rethrow(e)
            end
        end
        return ResultInfo(job, result_response)
    else
        response = retreive_job_info(job.api, job.account.access_token)
        if haskey(response, "qObjectResult")
            return response["qObjectResult"]
        else
            error("Unexpected return value received from the server: $response")
        end
    end
end
