_L = tostring
_LF = function(str, ...)
    local args = {}
    for i = 1, select("#", ...) do
        args[tostring(i)] = select(i, ...)
    end
    local s = string.gsub(str, "{(%d+)}", args)
    return s
end

local util = require("util")

local _M = {}

_M._quotes = {
    ["\t"] = "\\t",
    ["\r"] = "\\r",
    ["\n"] = "\\n",
    ["\""] = "\"\"",
    ["\\"] = "\\\\"
}

_M.EnableLocaleSystem = false
_M.CustomLocaleTab = {
    ["en"] = {
        ["、"] = ", ",
        ["完成组合"] = "Complete The Set",
        ["对话收集"] = "Tea Talks Collection",
        ["饮品收集"] = "Beverages Collection",
        ["解锁对话："] = "Unlock Dialogue: ",
        ["解锁饮品："] = "Unlock Beverages: "
    },
    ["ja"] = {
        ["完成组合"] = "Complete The Set",
        ["对话收集"] = "Tea Talks Collection",
        ["饮品收集"] = "Beverages Collection",
        ["解锁对话："] = "会話解放：",
        ["解锁饮品："] = "飲み物解放："
    }
}

function _M.LoadLanguageTab(language)
    local custom_locale_tab = _M.CustomLocaleTab[language] or {}
    local ok, locale_tab = pcall(util.LoadLocaleTable, language)
    if ok then
        _M.EnableLocaleSystem = true
        _L = function(str)
            if custom_locale_tab[str] then
                return custom_locale_tab[str]
            end
            return locale_tab[str] or str
        end
        _LF = function(str, ...)
            local args = {}
            for i = 1, select("#", ...) do
                args[tostring(i)] = select(i, ...)
            end
            local s = string.gsub(locale_tab[str] or str, "{(%d+)}", args)
            return s
        end
    end
end

function _M.QuoteStr(str)
    str = string.gsub(str, "[%c\\\"]", _M._quotes)
    return "\"" .. str .. "\""
end

function _M.TrimNewLine(str)
    str = string.gsub(str, "\n", "")
    return str
end

return _M
