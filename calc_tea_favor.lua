CARD = require("modules/card")
TEA = require("modules/tea")

local function combine(elements)
    local combos = {}

    local function dfs(idx, prev)
        local isLast = idx == #elements
        local items = elements[idx]
        for _, combo in ipairs(items) do
            local head = {table.unpack(prev)}
            table.insert(head, combo)
            if isLast then
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
    if drink_id > 9999 then
        return recipes
    end

    return table.pack(recipes[1])
end

--- START HERE ---

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
                local info = {
                    ["id"] = card_tid * 100 + (recipe.drink > 9999 and recipe.condiment[1] or recipe.drink),
                    ["card_tid"] = card_tid,
                    ["drink"] = drink_name,
                    ["condiment"] = condiment_name,
                    ["favor"] = math.floor(TEA.TEA_BASE_FAVOR_VALUE * recipe.favor_ratio * 1.12 * 1.09)
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

print(string.format("%s,%s,%s,%s,%s", "ID", "同调者", "饮品", "小料", "默契值"))
for _, v in ipairs(t) do
    print(string.format("%d,%s,%s,%q,%d", v.id, CARD.GetCardName(v.card_tid), v.drink, v.condiment, v.favor))
end
