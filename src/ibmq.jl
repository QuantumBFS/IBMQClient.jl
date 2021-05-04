# NOTE:
# unlike qiskit we want to distinguish and error when
# method does not exist in certain REST API endpoint.

"""
    read_token(qiskitrc::String[=expanduser("~/.qiskit/qiskitrc")])

Read IBMQ API token from `.qiskit/qiskitrc` file. Default location is
`~/.qiskit/qiskitrc`.
"""
function read_token(qiskitrc::String=expanduser("~/.qiskit/qiskitrc"))
    conf = ConfParse(qiskitrc)
    parse_conf!(conf)
    return retrieve(conf, "ibmq", "token")
end

"""
    struct AccountInfo

    AccountInfo([token=read_token()])

Create an `AccountInfo` object from given IBMQ API token. You can
create your own token at https://quantum-computing.ibm.com/ after
login. It will look at `~/.qiskit/qiskitrc` for the API token by
default. See [`read_token`](@ref) for more information.
"""
@option struct AccountInfo
    access_token::String
    auth::AuthAPI
    service::ServiceAPI
    project::ProjectAPI
    user_info::Schema.UserInfo

    AccountInfo() = AccountInfo(read_token())

    function AccountInfo(token::String)
        auth = AuthAPI()
        response = login(auth, token)
        access_token = response["id"]
        info = user_info(auth, access_token)
        service = ServiceAPI(info["urls"]["http"])
        user_hub = first(user_hubs(service, access_token))
        project = ProjectAPI(service.endpoint, user_hub["hub"], user_hub["group"], user_hub["project"])
        new(access_token, auth, service, project, Schema.UserInfo(info))
    end
end

user_urls(x::AccountInfo) = x.user_info.urls
hubs(x::AccountInfo) = hubs(x.service, x.access_token)
user_hubs(x::AccountInfo) = user_hubs(x.service, x.access_token)

"""
    devices(x::AccountInfo)

Query available devices using given `AccountInfo`.
"""
function devices(x::AccountInfo)
    raw = devices(x.project, x.access_token)
    return Configurations.from_dict_inner.(Schema.DeviceInfo, raw)
end

@option struct StorageInfo
    maxJobSizeInBytes::Int
    uploadUrl::String
end

@option mutable struct JobInfo
    kind::String
    backend::Dict{String, String}
    userId::String
    status::String
    id::String
    # optional
    timePerStep::Maybe{Dict{String, String}} = nothing
    name::Maybe{String} = nothing
    share_level::Maybe{Int}=nothing
    tags::Maybe{Vector{String}}=nothing
    qobj::Maybe{Schema.Qobj} = nothing
    allowObjectStorage::Maybe{Bool} = nothing
    objectStorageInfo::Maybe{StorageInfo} = nothing
    deleted::Maybe{Bool} = nothing
    runMode::Maybe{String} = nothing
    creationDate::Maybe{DateTime} = nothing
    endDate::Maybe{DateTime} = nothing
    hubInfo::Maybe{Dict{String, Any}} = nothing
end

function update_job_info(info::JobInfo, new::AbstractDict)
    d = to_dict(info; exclude_nothing=true)
    merge!(d, new)
    d["qobj"] = info.qobj
    return Configurations.from_dict_inner(JobInfo, d)
end

function Configurations.convert_to_option(::Type{JobInfo}, ::Type{DateTime}, s::String)
    DateTime(s, dateformat"yyyy-mm-ddTHH:MM:SS.sZ")
end

"""
    jobs(x::AccountInfo; kw...)

Query jobs submitted using given `AccountInfo`.
"""
function jobs(x::AccountInfo; kw...)
    raw = jobs(x.project, x.access_token; kw...)
    return Configurations.from_dict_inner.(JobInfo, raw)
end

@option struct RemoteJob
    dev::String
    name::Maybe{String}=nothing
    share_level::Maybe{Int}=nothing
    tags::Maybe{Vector{String}}=nothing
end

function RemoteJob(dev::Schema.DeviceInfo, name, share_level, tags)
    RemoteJob(dev.backend_name, name, share_level, tags)
end

function create_remote_job(x::AccountInfo, job::RemoteJob)
    raw = create_remote_job(x.project, job.dev, x.access_token;
        job_name=job.name, job_share_level=job.share_level, job_tags=job.tags)

    # forward remote job info
    raw["name"] = job.name
    raw["share_level"] = job.share_level
    raw["tags"] = job.tags
    return Configurations.from_dict_inner(JobInfo, raw)
end

"""
    submit(account::AccountInfo, remote_job::RemoteJob, qobj::Schema.Qobj)

Submit a `Qobj` to remote device as a remote_job.
"""
function submit(account::AccountInfo, remote_job::RemoteJob, qobj::Schema.Qobj)
    info = create_remote_job(account, remote_job)
    job_id = info.id
    upload_url = info.objectStorageInfo.uploadUrl
    job_api = JobAPI(account.project, job_id)

    try
        put_object_storage(job_api, upload_url, qobj, account.access_token)
        response = callback_upload(job_api, account.access_token)
        return update_job_info(info, response["job"])
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

"""
    status(account::AccountInfo, job::JobInfo)

Query the current status of `job`.
"""
function status(account::AccountInfo, job::JobInfo)
    job_api = JobAPI(account.project, job.id)
    new = status(job_api, account.access_token)
    return update_job_info(job, new)
end

"""
    results(account::AccountInfo, job::JobInfo; use_object_storage::Bool = true)

Download the results of given `job`, return `nothing` if the job status is not `COMPLETED`.
"""
function results(account::AccountInfo, job::JobInfo; use_object_storage::Bool = true)
    response = status(account, job)
    response.status == "COMPLETED" || return

    job_api = JobAPI(account.project, job.id)

    if use_object_storage
        url = result_url(job_api, account.access_token)["url"]
        result_response = get_object_storage(job_api, url, account.access_token)

        try
            callback_download(job_api, account.access_token)
        catch e
            if e isa HTTP.ExceptionRequest.StatusError
                error("An error occurred while sending download completion acknowledgement.")
            else
                rethrow(e)
            end
        end
        return Configurations.from_dict_inner(Schema.Result, result_response)
    else
        response = retreive_job_info(job_api, account.access_token)
        if haskey(response, "qObjectResult")
            return response["qObjectResult"]
        else
            error("Unexpected return value received from the server: $response")
        end
    end
end
