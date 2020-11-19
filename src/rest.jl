module REST

export @test_request

using HTTP
using JSON
using URIs
using Serialization
using ..Patch: make_uri
abstract type AbstractAPI end

const mocking = Ref{Bool}(false)

# naive API type
struct API <: AbstractAPI
    endpoint::URI
end

API(api::AbstractAPI) = API(endpoint(api))
endpoint(api::AbstractAPI) = api.endpoint
api_layers(::AbstractAPI; kw...) = HTTP.stack(;kw...)

function request(api::AbstractAPI, method::String, path::String, body=HTTP.nobody; headers=HTTP.Header[], query=nothing, kw...)::HTTP.Response
    uri = api_uri(api, path, query)
    layers = api_layers(api; kw...)

    if mocking[]
        response = reflect(layers, method, uri, HTTP.mkheaders(headers), body; kw...)
    else    
        response = HTTP.request(layers, method, uri, HTTP.mkheaders(headers), body; kw...)
    end
    return response
end

function json(r::HTTP.Response)
    if mocking[]
        return deserialize(IOBuffer(r.body))
    else
        body = HTTP.payload(r, String)
        return JSON.parse(body)
    end
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
    uri = endpoint(api)::URI
    # NOTE: this directly set the query to query
    if query === nothing
        return joinpath(api.endpoint, path)
    else
        isempty(uri.query) || error("non empty query in API endpoint is not supported")
        return make_uri(joinpath(api.endpoint, path); query=query)
    end
end

function reflect(layers, method, uri, headers, body; kw...)
    d = Dict{Symbol, Any}(
        :layers=>layers,
        :method=>method,
        :uri=>uri,
        :headers=>headers,
        :body=>body,
        :kw=>kw
    )

    io = IOBuffer()
    s = Serializer(io)
    serialize(s, d)
    return HTTP.Response(200, take!(io))
end

"""
    reflect(f)

Reflect requests.
"""
function reflect(f::Function)
    mocking[] = true
    ret = f()
    mocking[] = false

    if ret isa HTTP.Response
        return deserialize(IOBuffer(ret.body))
    else
        return ret
    end
end

macro test_request(ex, body)
    title = string(ex)
    quote
        @testset $title begin
            response = $reflect() do
                $ex
            end

            $body
        end
    end |> esc
end

end
