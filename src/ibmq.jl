# NOTE:
# unlike qiskit we want to distinguish and error when
# method does not exist in certain REST API endpoint.
@option struct IBMQRC
    token::String
    url::String = "https://auth.quantum-computing.ibm.com/api"
    verify::Bool = true
end

@option struct QiskitRC
    ibmq::IBMQRC
end

function read_token(qiskitrc::String=expanduser("~/.qiskit/qiskitrc"))
    d = from_toml(QiskitRC, qiskitrc)
    return d.ibmq.token
end

"""
    login([qiskitrc::String="~/.qiskit/qiskitrc"])

Login from local `qiskitrc` cache.
"""
function login(qiskitrc::String=expanduser("~/.qiskit/qiskitrc"))
    rc = from_toml(QiskitRC, qiskitrc)
    return login(AuthAPI(URI(rc.ibmq.url)), rc.ibmq.token)
end

@option struct AccountInfo
    access_token::String
    auth::AuthAPI
    service::ServiceAPI
    project::ProjectAPI
    user_info::Schema.UserInfo
end

function AccountInfo(token::String)
    auth = AuthAPI()
    response = login(auth, token)
    access_token = response["id"]
    info = user_info(auth, access_token)
    service = ServiceAPI(info["urls"]["http"])
    user_hub = first(user_hubs(service, access_token))
    project = ProjectAPI(service.endpoint, user_hub["hub"], user_hub["group"], user_hub["project"])
    return AccountInfo(access_token, auth, service, project, Schema.UserInfo(info))
end

user_urls(x::AccountInfo) = x.user_info.urls
hubs(x::AccountInfo) = hubs(x.service, x.access_token)
user_hubs(x::AccountInfo) = user_hubs(x.service, x.access_token)

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

function JobInfo(info::JobInfo; kw...)
    d = to_dict(info; exclude_nothing=true)
    Configurations.from_kwargs!(d, JobInfo; kw...)
    return Configurations.from_dict_inner(JobInfo, d)
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

function status(account::AccountInfo, job::JobInfo)
    job_api = JobAPI(account.project, job.id)
    new = status(job_api, account.access_token)
    return update_job_info(job, new)
end
