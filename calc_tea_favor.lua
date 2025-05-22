LOCALE = require("modules/locale")
CARD = require("modules/card")
TEA = require("modules/tea")

local function combine(elements)
    local combos = {}

    local function dfs(idx, prev)
        local is_last = idx == #elements
        local items = elements[idx]
        for _, combo in ipairs(items) do
            local head = {table.unpack(prev)}
            table.insert(head, combo)
            if is_last then
                table.insert(combos, head)
            else
                dfs(idx + 1, head)
            end
        end
    end

    dfs(1, {})

    return combos
end

---@class Recipe @饮品配方
---@field drink integer @饮品ID
---@field condiment integer[] @小料ID
---@field favor_ratio number @好感加成系数

--- 获取角色在饮品下的所有配方
---@param card_tid integer @角色TID
---@param drink_id integer @饮品ID
---@return Recipe[] @配方
function GetAllRecipeByDrink(card_tid, drink_id)
    local t = {}

    local drink_fav_ratio = TEA.GetDrinkFavorRatio(card_tid, drink_id)

    local condiment_types = TEA.GetCondimentTypes(drink_id)
    local condiments = {}
    for i, type_id in ipairs(condiment_types) do
        local condiment = TEA.GetCondimentList(drink_id, type_id)
        condiments[i] = condiment
    end

    local recipes = combine(condiments)
    for _, recipe in ipairs(recipes) do
        local fav_ratios, rel_ratios = {}, {}

        for _, condiment_id in ipairs(recipe) do
            local fav_ratio = TEA.GetCondimentFavorRatio(card_tid, condiment_id)
            local rel_ratio = TEA.GetCondimentRelationRatio(drink_id, condiment_id)
            table.insert(fav_ratios, fav_ratio)
            table.insert(rel_ratios, rel_ratio)
        end

        local favor_ratio = TEA.CalcFavorRatio(drink_fav_ratio, fav_ratios, rel_ratios)

        local info = {
            ["drink"] = drink_id,
            ["condiment"] = recipe,
            ["favor_ratio"] = favor_ratio
        }
        table.insert(t, info)
    end

    return t
end

--- 获取角色对饮品的最高默契值配方
---@param card_tid integer 角色TID
---@param drink_id integer 饮品ID
---@return Recipe[] 配方
function GetHighestFavorRecipeByDrink(card_tid, drink_id)
    local recipes = GetAllRecipeByDrink(card_tid, drink_id)

    table.sort(recipes, function(a, b)
        return a.favor_ratio > b.favor_ratio
    end)

    -- FIX: 特殊饮品返回所有配方
    local is_special_drink = TEA.TEA_SPECIAL_DRINK[drink_id] or false
    if is_special_drink then
        return recipes
    end

    return table.pack(recipes[1])
end

--- START HERE ---

local args = {}
for i = 1, select("#", ...) do
    args[i] = select(i, ...)
end

if #args > 0 then
    LOCALE.LoadLanguageTab(args[1])
end

local t = {}

local card_list = CARD.AvailableCardList
for card_tid, is_available in pairs(card_list) do
    if is_available then
        local drinks = TEA.GetDrinkList(card_tid) or {}
        for _, drink_id in ipairs(drinks) do
            local recipes = GetHighestFavorRecipeByDrink(card_tid, drink_id)
            for _, recipe in ipairs(recipes) do
                local drink_name = TEA.GetDrinkName(recipe.drink)
                local condiment_names = {}
                for _, condiment_id in ipairs(recipe.condiment) do
                    table.insert(condiment_names, TEA.GetCondimentName(condiment_id))
                end
                local condiment_name = table.concat(condiment_names, ", ")
                local recipe_id = recipe.drink
                if recipe_id > 9999 then
                    local is_special_drink = TEA.TEA_SPECIAL_DRINK[drink_id] or false
                    if is_special_drink then
                        recipe_id = recipe.condiment[1]
                    else
                        -- FIX: 茜茜无酒精特调
                        recipe_id = recipe_id - 9999 + 90
                    end
                end
                local info = {
                    ["id"] = card_tid * 100 + recipe_id,
                    ["card_tid"] = card_tid,
                    ["drink"] = drink_name,
                    ["condiment"] = condiment_name,
                    ["favor"] = math.floor(TEA.TEA_BASE_FAVOR_VALUE * recipe.favor_ratio * TEA.TEA_FAVOR_BONUS_COZINESS * TEA.TEA_FAVOR_BONUS_EXTRA)
                }
                table.insert(t, info)
            end
        end
    end
end

table.sort(t, function(a, b)
    if a.card_tid ~= b.card_tid then
        return a.card_tid < b.card_tid
    else
        if a.favor ~= b.favor then
            return a.favor > b.favor
        else
            return a.id < b.id
        end
    end
end)

print(string.format("%s,%s,%s,%s,%s", "ID", _L("同调者"), _L("饮品"), _L("小料"), _L("默契值")))
for _, v in ipairs(t) do
    print(string.format("%d,%q,%q,%q,%d", v.id, CARD.GetCardName(v.card_tid), v.drink, LOCALE.TrimNewLine(v.condiment), v.favor))
end
