module Patch

using URIs

# URIs patch, delete this after #12 merged
if !hasmethod(joinpath, Tuple{URI, Vararg{String}})

    """
        joinpath(uri, path) -> URI
    Join the path component of URI and other parts.
    """
    function Base.joinpath(uri::URI, parts::String...)
        path = uri.path
        for p in parts
            if startswith(p, '/')
                path = p
            elseif isempty(path) || path[end] == '/'
                path *= p
            else
                path *= "/" * p
            end
        end
    
        if isempty(uri.path)
            path = "/" * path
        end
        return make_uri(uri; path=URIs.normpath(path))
    end

end

@static if hasmethod(merge, Tuple{URI})
    make_uri(x::URI; kw...) = merge(x; kw...)
else
    make_uri(x::URI; kw...) = URI(x; kw...)
end
 
end