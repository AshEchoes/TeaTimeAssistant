local _M = {}

local GAME_DATA_DIR = 'GameData/data/'

local function read_file(name)
    local f = assert(io.open(name, "r"))
    local content = f:read("*a")
    f:close()
    return content
end

function _M.ReadFile(name)
    return read_file(name)
end

local function write_file(name, content)
    local f = assert(io.open(name, "w"))
    f:write(content)
    f:close()
end

function _M.WriteFile(name, content)
    return write_file(name, content)
end

local function load_data_table(name)
    local content = read_file(name)
    local t = assert(load("return " .. content))()
    return t
end

function _M.LoadDataTable(name)
    return load_data_table(GAME_DATA_DIR .. name)
end

return _M
