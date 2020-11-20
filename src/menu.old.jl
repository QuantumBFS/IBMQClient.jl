mutable struct DeviceMenu{D} <: TerminalMenus.AbstractMenu
    options::Vector{D}
    pagesize::Int
    indent::Int
    pageoffset::Int
    selected::Int
end

function DeviceMenu(devices::Vector; pagesize::Int=5, warn::Bool=true)
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
    return DeviceMenu(devices, pagesize, indent, pageoffset, selected)
end

function TerminalMenus.options(m::DeviceMenu)
    return m.options
end

TerminalMenus.cancel(m::DeviceMenu) = m.selected = -1

function TerminalMenus.pick(m::DeviceMenu, cursor::Int)
    m.selected = cursor
    return true #break out of the menu
end

function TerminalMenus.writeLine(buf::IOBuffer, menu::DeviceMenu, idx::Int, cursor::Bool)
    # print a ">" on the selected entry
    cursor ? print(buf, TerminalMenus.CONFIG[:cursor] ," ") : print(buf, "  ")

    print(buf, menu.options[idx].name)
end
