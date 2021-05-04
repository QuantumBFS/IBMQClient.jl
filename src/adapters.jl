# REST API adapters
# the adapters returns the raw JSON in Dict{String, Any}
export AuthAPI, ServiceAPI, ProjectAPI, JobAPI

abstract type AbstractAPI end

endpoint(api::AbstractAPI) = api.endpoint
api_layers(::AbstractAPI; kw...) = HTTP.stack(;kw...)
function api_uri(api::AbstractAPI, path::String, query=nothing)
    uri = endpoint(api)::URI
    # NOTE: this directly set the query to query
    if query === nothing
        return joinpath(uri, path)
    else
        isempty(uri.query) || error("non empty query in API endpoint is not supported")
        return URI(joinpath(uri, path); query=query)
    end
end

function to_json(response)
    body = HTTP.payload(response, String)
    return JSON.parse(body)
end

"abstract REST API type for IBM Q"
abstract type IBMQAPI <: AbstractAPI end

"""
    create_headers(api::IBMQAPI[, headers=HTTP.Header[]; kw...])

Create headers for a IBMQ REST API object.
"""
function create_headers(::IBMQAPI, headers=HTTP.Header[]; kw...)
    headers = HTTP.mkheaders(headers)
    # insert headers
    # TODO: use version
    HTTP.setkv(headers, "X-Qx-Client-Application", "IBMQClient.jl")
    HTTP.setkv(headers, "Connection", "keep-alive")
    HTTP.setkv(headers, "Accept", "*/*")
    access_token = Base.get(kw, :access_token, nothing)
    if access_token === nothing
        HTTP.rmkv(headers, "X-Access-Token")
    else
        HTTP.setkv(headers, "X-Access-Token", access_token)
    end
    return headers
end

function request(api::IBMQAPI, method::String, path::String, body=HTTP.nobody; headers=HTTP.Header[], query=nothing, kw...)
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

    uri = api_uri(api, path, query)
    layers = api_layers(api; kw...)
    response = @mock HTTP.request(layers, method, uri, HTTP.mkheaders(headers), body; kw...)
    return to_json(response)
end

function get(api::AbstractAPI, path::String, body=HTTP.nobody; kw...)
    @mock request(api, "GET", path, body; kw...)
end

post(api::AbstractAPI, path::String, body=HTTP.nobody; kw...) = @mock request(api, "POST", path, body; kw...)
put(api::AbstractAPI, path::String, body=HTTP.nobody; kw...) = @mock request(api, "PUT", path, body; kw...)
patch(api::AbstractAPI, path::String, body=HTTP.nobody; kw...) = @mock request(api, "PATCH", path, body; kw...)
head(api::AbstractAPI, path::String, body=HTTP.nobody; kw...) = @mock request(api, "HEAD", path, body; kw...)


"""
    AuthAPI <: IBMQAPI

IBM Q Authentication REST API.
"""
Base.@kwdef struct AuthAPI <: IBMQAPI
    endpoint::URI = URI("https://auth.quantum-computing.ibm.com/api")
end

"""
    login(::AuthAPI, token::String)

Login with user token.
"""
function login(api::AuthAPI, token::String)
    return post(api, "users/loginWithToken", Dict("apiToken" => token))
end

"""
    user_info(::AuthAPI, access_token::String)

Get user info of given IBM Q account access token.
"""
function user_info(api::AuthAPI, access_token::String)
    return get(api, "users/me"; access_token=access_token)
end

"""
    user_urls(::AuthAPI, access_token::String)

Get user urls to create services etc.
"""
function user_urls(api::AuthAPI, access_token::String)
    return user_info(api, access_token)["urls"]
end

"""
    ServiceAPI <: IBMQAPI

IBM Q service REST API.
"""
struct ServiceAPI <: IBMQAPI
    endpoint::URI
end

"""
    ServiceAPI([uri="https://api.quantum-computing.ibm.com/api"])

Create IBM Q service REST API object.
"""
ServiceAPI() = ServiceAPI("https://api.quantum-computing.ibm.com/api")
ServiceAPI(uri::String) = ServiceAPI(URI(uri))

"""
    ServiceAPI(::AuthAPI, access_token::String)

Create IBM Q service REST API by querying authentication server.
"""
function ServiceAPI(auth::AuthAPI, access_token::String)
    return ServiceAPI(URI(user_urls(auth, access_token)["http"]))
end

"""
    hubs(api::ServiceAPI, access_token::String)

Get alll IBM hubs.
"""
function hubs(api::ServiceAPI, access_token::String)
    return get(api, "Network"; access_token=access_token)
end

"""
    user_hubs(api::ServiceAPI, access_token::String)

Get given users' hubs.
"""
function user_hubs(api::ServiceAPI, access_token::String)
    ret_hubs = Dict{String, String}[]
    for hub in hubs(api, access_token)
        hub_name = hub["name"]
        for (group_name, group) in hub["groups"], (project_name, project) in group["projects"]
            entry = Dict(
                "hub" => hub_name,
                "group" => group_name,
                "project" => project_name
            )

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
"""
    ProjectAPI <: IBMQAPI

IBM Q Project REST API.
"""
struct ProjectAPI <: IBMQAPI
    endpoint::URI
end

"""
    ProjectAPI(base, hub::String, group::String, project::String)

Create IBM Q Project REST API from given base uri, `hub`, `group` and project name `project`.
"""
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

"""
    devices(api::ProjectAPI, access_token::String; timeout = 0)

Query available devices.
"""
function devices(api::ProjectAPI, access_token::String; timeout = 0)
    return get(api, "devices/v/1"; readtimeout = timeout, access_token = access_token)
end

"""
    jobs(api::ProjectAPI, access_token::String; descending::Bool=true, limit::Int=10, skip::Int=0, extra_filter=nothing)

Query available jobs. 

## Args
- `limit`: Maximum number of items to return.
- `skip`: Offset for the items to return.
- `descending`: Whether the jobs should be in descending order.
- `extra_filter`: Additional filtering passed to the query.
"""
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

    get(api, "Jobs/status/v/1"; access_token=access_token, query=Dict("filter" => JSON.json(query)))
end

"""
    create_remote_job(api::ProjectAPI, device::IBMQDevice, access_token::String; job_name=nothing, job_share_level=nothing, job_tags=nothing)

Create a job instance on the remote server.

## Args

- `device_name`: A IBM Q device name.
- `job_name`: Custom name to be assigned to the job.
- `job_share_level`: Level the job should be shared at.
- `job_tags`: Tags to be assigned to the job.
"""
function create_remote_job(api::ProjectAPI, device_name::String, access_token::String; job_name=nothing, job_share_level=nothing, job_tags=nothing)
    payload = Dict{String, Any}(
        "backend" => Dict{String, Any}(
            "name" => device_name,
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

    return post(api, "Jobs", payload; access_token=access_token)
end

struct JobAPI <: IBMQAPI
    endpoint::URI
end

function JobAPI(api::ProjectAPI, job_id::String)
    JobAPI(joinpath(api.endpoint, "Jobs/$job_id"))
end

function upload_url(api::JobAPI, access_token::String)
    get(api, "jobUploadUrl"; access_token=access_token)
end

function retreive_job_info(api::JobAPI, access_token::String)
    get(api, "v/1"; access_token=access_token)
end

function cancel(api::JobAPI, access_token::String)
    post(api, "cancel"; access_token=access_token)
end

function properties(api::JobAPI, access_token::String)
    get(api, "properties"; access_token=access_token)
end

function result_url(api::JobAPI, access_token::String)
    get(api, "resultDownloadUrl"; access_token=access_token)
end

function download_url(api::JobAPI, access_token::String)
    get(api, "jobDownloadUrl"; access_token=access_token)
end

function status(api::JobAPI, access_token::String)
    get(api, "status/v/1"; access_token=access_token)
end

function put_object_storage(api::JobAPI, url::String, qobj::Schema.Qobj, access_token::String)
    put_object_storage(api, url, to_dict(qobj; include_defaults=true, exclude_nothing=true), access_token)
end

function put_object_storage(api::JobAPI, url::String, qobj::AbstractDict{String, Any}, access_token::String)
    put_object_storage(api, url, JSON.json(qobj), access_token)
end

function put_object_storage(api::JobAPI, url::String, qobj::String, access_token::String)
    HTTP.put(url, create_headers(api; access_token=access_token), qobj; readtimeout=600)
end

function get_object_storage(api::JobAPI, url::String, access_token::String)
    response = HTTP.get(url, create_headers(api; access_token=access_token); readtimeout=600)
    return to_json(response)
end

function callback_upload(api::JobAPI, access_token::String)
    post(api, "jobDataUploaded"; access_token=access_token)
end

function callback_download(api::JobAPI, access_token::String)
    post(api, "resultDownloaded"; access_token=access_token)
end
