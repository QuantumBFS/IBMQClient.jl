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
    user_info = user_info(auth, access_token)
    service = ServiceAPI(user_info["urls"]["http"])
    user_hub = first(user_hubs(service, access_token))
    project = ProjectAPI(service.endpoint, user_hub.hub, user_hub.group, user_hub.project)
    return AccountInfo(access_token, user_info, auth, service, project)
end

devices(x::AccountInfo) = devices(x.project, x.access_token)

function Base.show(io::IO, ::MIME"text/plain", x::AccountInfo)
    indent = get(io, :indent, 0)
    println(io, " "^indent, "AccountInfo:")
    println(io, " "^indent, LIGHT_BLUE_FG("  email:        "), x.user_info["email"])
    print(io, " "^indent, LIGHT_BLUE_FG("  institution:  "), x.user_info["institution"])
end
