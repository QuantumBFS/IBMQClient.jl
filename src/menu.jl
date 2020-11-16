mutable struct DeviceMenu{D, C} <: TerminalMenus._ConfiguredMenu{C}
    options::Vector{D}
    pagesize::Int
    indent::Int
    pageoffset::Int
    selected::Int
    config::C
end

function DeviceMenu(devices::Vector; pagesize::Int=5, warn::Bool=true, kwargs...)
    length(devices) < 1 && error("DeviceMenu must have at least one option")
    pagesize < 4 && error("minimum pagesize must be larger than 4")
    pagesize = pagesize == -1 ? length(devices) : pagesize
    # pagesize shouldn't be bigger than options
    pagesize = min(length(devices), pagesize)
    # after other checks, pagesize must be greater than 1
    pagesize < 1 && error("pagesize must be >= 1")

    pageoffset = 0
    selected = -1 # none
    indent = maximum(x->length(x.name), devices) + 2
    return DeviceMenu(devices, pagesize, indent, pageoffset, selected, TerminalMenus.Config(;kwargs...))
end

function TerminalMenus.options(m::DeviceMenu)
    return m.options
end

TerminalMenus.cancel(m::DeviceMenu) = m.selected = -1

function TerminalMenus.pick(m::DeviceMenu, cursor::Int)
    m.selected = cursor
    return true #break out of the menu
end

function TerminalMenus.printmenu(out::IO, m::DeviceMenu, cursoridx::Int; oldstate=nothing, init::Bool=false)
    buf = IOBuffer()
    lastoption = length(m.options)
    ncleared = oldstate === nothing ? m.pagesize-1 : oldstate

    if init
        # like clamp, except this takes the min if max < min
        m.pageoffset = max(0, min(cursoridx - m.pagesize ÷ 2, lastoption - m.pagesize))
    else
        print(buf, "\x1b[999D\x1b[$(ncleared)A")   # move left 999 spaces and up `ncleared` lines
    end

    firstline = m.pageoffset+1
    lastline = min(m.pagesize+m.pageoffset, lastoption)
    curr_device = m.options[cursoridx]

    for i in firstline:lastline
        # clearline
        print(buf, "\x1b[2K")

        upscrollable = i == firstline && m.pageoffset > 0
        downscrollable = i == lastline && i != lastoption

        if upscrollable && downscrollable
            print(buf, TerminalMenus.updown_arrow(m)::Union{Char,String})
        elseif upscrollable
            print(buf, TerminalMenus.up_arrow(m)::Union{Char,String})
        elseif downscrollable
            print(buf, TerminalMenus.down_arrow(m)::Union{Char,String})
        else
            print(buf, ' ')
        end

        TerminalMenus.printcursor(buf, m, i == cursoridx)
        name = m.options[i].name
        indent = " "^(m.indent - length(name))
        device = m.options[cursoridx]

        line_idx = i - firstline + 1
        print(buf, GREEN_FG(name))
 
        if line_idx == 1
            print(buf, indent, LIGHT_BLUE_FG("nqubits: "), GREEN_FG(string(device.nqubits)))
        elseif line_idx == 2
            print(buf, indent, LIGHT_BLUE_FG("max_shots: "), GREEN_FG(string(device.max_shots)))
        elseif line_idx == 3
            print(buf, indent, LIGHT_BLUE_FG("credits_required:: "), GREEN_FG(string(device.credits_required)))
        end

        (firstline == lastline || i != lastline) && print(buf, "\r\n")
    end

    newstate = lastline-firstline  # final line doesn't have `\n`
    if newstate < ncleared && oldstate !== nothing
        # we printed fewer lines than last time. Erase the leftovers.
        for i = newstate+1:ncleared
            print(buf, "\r\n\x1b[2K")
        end
        print(buf, "\x1b[$(ncleared-newstate)A")
    end

    print(out, String(take!(buf)))

    return newstate
end
