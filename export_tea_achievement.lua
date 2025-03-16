LOCALE = require("modules/locale")
CARD = require("modules/card")
TEA = require("modules/tea")

--- 类型ID到类型名称
---@param type_id integer @类型ID
---@return string @类型名称
function Type2Str(type_id)
    local names = {"完成组合", "对话收集", "饮品收集"}
    return names[type_id]
end

--- START HERE ---

if #arg > 0 then
    LOCALE.LoadLanguageTab(arg[1])
end

local t = {}

local card_list = CARD.AvailableCardList
for card_tid, is_available in pairs(card_list) do
    if is_available then
        ---@type Achievement[]
        local achs = TEA.GetAchievementList(card_tid) or {}
        for _, ach in ipairs(achs) do
            local cup_name = TEA.GetDrinkName(ach.cup_res) or ""
            local drink_name = TEA.GetDrinkName(ach.drink_res) or ""
            local condiment_ids = ach.condiment_res or {}
            local condiment_names = {}
            for _, condiment_id in ipairs(condiment_ids) do
                table.insert(condiment_names, TEA.GetCondimentName(condiment_id))
            end
            local condiment_name = table.concat(condiment_names, ", ")
            local decoration_name = TEA.GetDrinkName(ach.decoration_res) or ""
            local comment = ""
            if ach.type == 1 then
                local req_fav_lv = 1
                local req_fav_item = ""

                local is_unlock, unlock_lv = TEA.GetUnlockInfo(card_tid, TEA.TEA_CATEGORY.CUP, ach.cup_res)
                if is_unlock and unlock_lv > req_fav_lv then
                    req_fav_lv = unlock_lv
                    req_fav_item = TEA.GetDrinkName(ach.cup_res)
                end

                local is_unlock, unlock_lv = TEA.GetUnlockInfo(card_tid, TEA.TEA_CATEGORY.DRINK, ach.drink_res)
                if is_unlock and unlock_lv > req_fav_lv then
                    req_fav_lv = unlock_lv
                    req_fav_item = TEA.GetDrinkName(ach.drink_res)
                end

                for _, condiment_id in ipairs(condiment_ids) do
                    local is_unlock, unlock_lv = TEA.GetUnlockInfo(card_tid, TEA.TEA_CATEGORY.CONDIMENT, condiment_id)
                    if is_unlock and unlock_lv > req_fav_lv then
                        req_fav_lv = unlock_lv
                        req_fav_item = TEA.GetCondimentName(condiment_id)
                    end
                end

                if req_fav_lv > 1 then
                    comment = _LF("默契{1}级解锁", req_fav_lv) .. " - " .. req_fav_item
                end
            elseif ach.type == 2 then
                local titles = {}
                for _, dialog_id in ipairs(ach.dialog_collect_res) do
                    local title = TEA.GetDialogTitle(card_tid, dialog_id)
                    if title then
                        table.insert(titles, _LF("《{1}》", title))
                    end
                end
                comment = _L("解锁对话：") .. table.concat(titles, _L("、"))
            elseif ach.type == 3 then
                local names = {}
                for _, drink_id in ipairs(ach.drink_collect_res) do
                    table.insert(names, TEA.GetDrinkName(drink_id))
                end
                comment = _L("解锁饮品：") .. table.concat(names, _L("、"))
            end
            local info = {
                ["id"] = card_tid * 100 + ach.index,
                ["card_tid"] = card_tid,
                ["name"] = _L(ach.name),
                ["type"] = _L(Type2Str(ach.type)),
                ["desc"] = ach.desc,
                ["cup"] = cup_name,
                ["drink"] = drink_name,
                ["condiment"] = condiment_name,
                ["decoration"] = decoration_name,
                ["comment"] = comment
            }
            table.insert(t, info)
        end
    end
end

table.sort(t, function(a, b)
    return a.id < b.id
end)

print(string.format("%s,%s,%s,%s,%s,%s,%s,%s,%s", "ID", _L("同调者"), _L("名称"), _L("类型"), _L("茶杯"), _L("饮品"), _L("小料"), _L("配饰"), _L("备注")))
for _, v in ipairs(t) do
    print(string.format("%d,%q,%s,%q,%q,%q,%q,%q,%s", v.id, CARD.GetCardName(v.card_tid), LOCALE.QuoteStr(v.name), v.type, v.cup, v.drink, v.condiment, v.decoration, LOCALE.QuoteStr(v.comment)))
end
