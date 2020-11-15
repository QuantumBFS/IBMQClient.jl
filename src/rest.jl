module REST

using HTTP
using JSON

abstract type AbstractAPI end

# naive API type
struct API <: AbstractAPI
    endpoint::HTTP.URI
end

API(api::AbstractAPI) = API(endpoint(api))
endpoint(api::AbstractAPI) = api.endpoint
api_layers(::AbstractAPI; kw...) = HTTP.stack(;kw...)

function request(api::AbstractAPI, method::String, path::String, body=HTTP.nobody; headers=HTTP.Header[], query=nothing, kw...)
    uri = api_uri(api, path, query)
    layers = api_layers(api; kw...)
    response = HTTP.request(layers, method, uri, HTTP.mkheaders(headers), body; kw...)::HTTP.Response
    return response
end

function json(r::HTTP.Response)
    body = HTTP.payload(r, String)
    return JSON.parse(body)
end

# copied from GitHub.jl
# we need to dispatch this on different APIs
function handle_response_error(::AbstractAPI, r::HTTP.Response)
    if r.status >= 400
        error(
            "Error found in response:\n",
            "\tStatus Code: $(r.status)\n",
        )
    end
end

function get(api::AbstractAPI, path::String, body=HTTP.nobody; kw...)
    request(api, "GET", path, body; kw...)
end

post(api::AbstractAPI, path::String, body=HTTP.nobody; kw...) = request(api, "POST", path, body; kw...)
put(api::AbstractAPI, path::String, body=HTTP.nobody; kw...) = request(api, "PUT", path, body; kw...)
patch(api::AbstractAPI, path::String, body=HTTP.nobody; kw...) = request(api, "PATCH", path, body; kw...)
head(api::AbstractAPI, path::String, body=HTTP.nobody; kw...) = request(api, "HEAD", path, body; kw...)

function api_uri(api::AbstractAPI, path::String, query=nothing)
    uri = endpoint(api)::HTTP.URI
    # NOTE: this directly set the query to query
    if query === nothing
        return merge(endpoint(api); path=uri.path * path)
    else
        isempty(uri.query) || error("non empty query in API endpoint is not supported")
        return merge(endpoint(api); path=uri.path * path, query=query)
    end
end

end
