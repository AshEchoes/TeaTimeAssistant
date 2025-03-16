local util = require("util")

local tea_cup_cfg = util.LoadDataTable("tea_cup")
local tea_drink_cfg = util.LoadDataTable("tea_drink")
local tea_condiment_cfg = util.LoadDataTable("tea_condiment")
local tea_drink_relation = util.LoadDataTable("tea_drink_relation")
local tea_favor_cfg = util.LoadDataTable("tea_favor")
local tea_favor_ratio = util.LoadDataTable("tea_favor_ratio")
local tea_achievement = util.LoadDataTable("tea_achievement")
local tea_favor_unlock = util.LoadDataTable("tea_favor_unlock")
local tea_dialog_cfg = util.LoadDataTable("tea_dialog_cfg")

local _M = {}

--- 基础默契值
_M.TEA_BASE_FAVOR_VALUE = 300
--- TeaCategory 枚举
_M.TEA_CATEGORY = {
    CUP = 1,
    DRINK = 2,
    CONDIMENT = 3,
    DECORATION = 4
}

local function GetCupTempl(cup_id)
    return tea_cup_cfg[cup_id]
end

local function GetDrinkTempl(drink_id)
    return tea_drink_cfg[drink_id]
end

local function GetCondimentTempl(condiment_id)
    return tea_condiment_cfg[condiment_id]
end

local function GetDrinkRelationTempl(drink_id)
    return tea_drink_relation[drink_id]
end

local function GetFavorTempl(card_tid)
    return tea_favor_cfg[card_tid]
end

local function GetAchievementTempls(card_tid)
    return tea_achievement[card_tid]
end

local function GetFavorUnlockTempl(card_tid)
    return tea_favor_unlock[card_tid]
end

local function GetDialogTempl(card_tid, dialog_id)
    if not tea_dialog_cfg[card_tid] then
        return
    end

    return tea_dialog_cfg[card_tid][dialog_id]
end

--- 获取角色的饮品菜单
---@param card_tid integer @角色TID
---@return integer[] @饮品列表
function _M.GetDrinkList(card_tid)
    if not card_tid then
        return
    end

    local favor_templ = GetFavorTempl(card_tid)
    if not favor_templ then
        return
    end

    local t = {}
    for drink_id, _ in pairs(favor_templ.drink_map) do
        -- FIX: 特殊角色favor配置修正
        if drink_id > 9999 then
            return table.pack(drink_id)
        end
        table.insert(t, drink_id)
    end
    table.sort(t)

    return t
end

--- 获取饮品支持的小料类型
---@param drink_id integer @饮品ID
---@return integer[] @小料类型列表
function _M.GetCondimentTypes(drink_id)
    if not drink_id then
        return
    end

    local drink_relation = GetDrinkRelationTempl(drink_id)
    if not drink_relation then
        return
    end

    local t = {}
    for condiment_type, _ in pairs(drink_relation) do
        table.insert(t, condiment_type)
    end
    table.sort(t)

    return t
end

--- 获取饮品在小料类型下能够选择的小料
---@param drink_id integer @饮品ID
---@param condiment_type integer @小料类型
---@return integer[] @小料列表
function _M.GetCondimentList(drink_id, condiment_type)
    if not condiment_type then
        return
    end

    local drink_relation = GetDrinkRelationTempl(drink_id)
    if not drink_relation then
        return
    end

    local condiment_map = drink_relation[condiment_type]
    if not condiment_map then
        return
    end

    local t = {}
    for condiment_id, _ in pairs(condiment_map) do
        table.insert(t, condiment_id)
    end
    table.sort(t)

    return t
end

--- 获取饮品好感加成系数
---@param card_tid integer @角色TID
---@param drink_id integer @饮品ID
---@return number @饮品好感加成系数
function _M.GetDrinkFavorRatio(card_tid, drink_id)
    if not drink_id then
        return
    end

    local favor_templ = GetFavorTempl(card_tid)
    if not favor_templ then
        return
    end

    local favor_lv = favor_templ.drink_map[drink_id] or 3

    return tea_favor_ratio[favor_lv].drink_ratio
end

--- 获取小料好感加成系数
---@param card_tid integer @角色TID
---@param condiment_id integer @小料ID
---@return number @小料好感加成系数
function _M.GetCondimentFavorRatio(card_tid, condiment_id)
    if not condiment_id then
        return
    end

    local favor_templ = GetFavorTempl(card_tid)
    if not favor_templ then
        return
    end

    local favor_lv = favor_templ.condiment_map[condiment_id] or 3

    return tea_favor_ratio[favor_lv].condiment_ratio
end

--- 获取饮品与小料的适配度加成系数
---@param drink_id integer @饮品ID
---@param condiment_id integer @小料ID
---@return number @适配度加成系数
function _M.GetCondimentRelationRatio(drink_id, condiment_id)
    if not condiment_id then
        return
    end

    local drink_relation = GetDrinkRelationTempl(drink_id)
    if not drink_relation then
        return
    end

    local condiment_templ = GetCondimentTempl(condiment_id)
    if not condiment_templ then
        return
    end

    local relation_lv = drink_relation[condiment_templ.type][condiment_id]

    return tea_favor_ratio[relation_lv].relation_ratio
end

---@class Achievement @茶憩成就
---@field card_id integer @角色TID
---@field index integer @成就索引
---@field name string @成就名称
---@field desc string @成就描述
---@field type integer @成就类型
---@field cup_res integer @杯子ID
---@field drink_res integer @饮品ID
---@field condiment_res integer[] @小料ID
---@field decoration_res integer @装饰ID
---@field dialog_collect_res integer[] @对话收集ID
---@field drink_collect_res integer[] @饮品收集ID

--- 获取角色的茶憩成就列表
---@param card_tid integer @角色TID
---@return Achievement[] @成就列表
function _M.GetAchievementList(card_tid)
    if not card_tid then
        return
    end

    local achievement_templs = GetAchievementTempls(card_tid)
    if not achievement_templs then
        return
    end

    return achievement_templs
end

--- 获取解锁项的解锁信息
---@param card_tid integer @角色TID
---@param category integer @解锁类型
---@param unlock_id integer @解锁项ID
---@return boolean @是否解锁
---@return integer @解锁等级
function _M.GetUnlockInfo(card_tid, category, unlock_id)
    if not unlock_id then
        return false, 0
    end

    local unlock_info = GetFavorUnlockTempl(card_tid)
    if not unlock_info then
        return false, 0
    end

    local cat_info = unlock_info[category]
    if not cat_info then
        return true, 0
    end

    local unlock_lv = cat_info[unlock_id] or 0

    return unlock_lv > 0, unlock_lv
end

--- 获取茶杯名称
---@param drink_id integer @茶杯ID
---@return string @茶杯名称
function _M.GetCupName(cup_id)
    if not cup_id then
        return
    end

    local templ = GetCupTempl(cup_id)
    if not templ then
        return
    end

    return _L(templ.name)
end

--- 获取饮品名称
---@param drink_id integer @饮品ID
---@return string @饮品名称
function _M.GetDrinkName(drink_id)
    if not drink_id then
        return
    end

    local templ = GetDrinkTempl(drink_id)
    if not templ then
        return
    end

    return _L(templ.name)
end

--- 获取小料名称
---@param condiment_id integer @小料ID
---@return string @小料名称
function _M.GetCondimentName(condiment_id)
    if not condiment_id then
        return
    end

    local templ = GetCondimentTempl(condiment_id)
    if not templ then
        return
    end

    return _L(templ.name)
end

--- 获取对话名称
---@param card_tid integer @角色TID
---@param dialog_id integer @对话ID
---@return string @对话名称
function _M.GetDialogTitle(card_tid, dialog_id)
    if not dialog_id then
        return
    end

    local templ = GetDialogTempl(card_tid, dialog_id)
    if not templ then
        return
    end

    return _L(templ.title)
end

--- 计算好感加成系数
---@param drink_ratio integer @饮品好感
---@param condiment_ratios integer[] @所有小料的好感加成系数
---@param relation_ratios integer[] @所有饮品小料适配度加成系数
---@return number @好感加成系数
function _M.CalcFavorRatio(drink_ratio, condiment_ratios, relation_ratios)
    local function mean(x)
        local s = 0
        for _, v in ipairs(x) do
            s = s + v
        end
        return (s / #x)
    end

    return drink_ratio * mean(condiment_ratios) * mean(relation_ratios)
end

return _M
