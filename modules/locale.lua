_L = function(str)
    return tostring(str)
end

local util = require("util")

local _M = {}

_M.quotes = {
    ["\t"] = "\\t",
    ["\r"] = "\\r",
    ["\n"] = "\\n",
    ["\""] = "\\\"",
    ["\\"] = "\\\\"
}

function _M.LoadLanguageTab(language)
    local ok, locale_tab = pcall(util.LoadLocaleTable, language)
    if ok then
        _L = function(str)
            return locale_tab[str] or str
        end
    end
end

function _M.QuoteStr(str)
    str = string.gsub(str, "[%c\\\"]", _M.quotes)
    return "\"" .. str .. "\""
end

return _M
