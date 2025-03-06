local util = require("util")

local card_cfg = util.LoadDataTable("card")

local _M = {}

---@type table<integer, boolean>
_M.AvailableCardList = {
    [101] = true, -- 老板
    [102] = true, -- Sweeper-EX
    [201] = true, -- 豹富
    [301] = true, -- 田偌
    [302] = true, -- 艾摩诃
    [303] = true, -- 元桃桃
    [304] = true, -- 霍冉
    [306] = true, -- 狄砚
    [401] = true, -- 刘兄
    [402] = true, -- 马尔斯
    [403] = true, -- 长谣
    [404] = true, -- 唐路遥
    [405] = true, -- 焰响
    [406] = true, -- 赫九逸
    [407] = true, -- 莉缇亚
    [409] = true, -- 吉娜
    [410] = true, -- 岚岚
    [501] = true, -- 襄铃
    [502] = true, -- 罗咤
    [503] = true, -- 阳铃
    [504] = true, -- 禺期
    [505] = true, -- 尚非乐
    [506] = true, -- 修
    [507] = true, -- 凤无梦
    [508] = true, -- 苏筱
    [510] = true, -- 芙蕖
    [511] = true, -- 司危
    [512] = true, -- 白鸟梓
    [513] = true, -- 无咎
    [514] = true, -- 瓦卡莎
    [515] = true, -- 卡洛琳
    [516] = true, -- 阿棘
    [518] = true, -- 雪长夏
    [525] = true, -- 比戈尼娅
    [601] = true, -- 卯绒绒
    [602] = true, -- 岑缨
    [603] = true, -- 伊琅相思
    [605] = true, -- 龙晴
    [607] = true, -- 瞳
    [608] = true, -- 昊苍
    [610] = true, -- 乐无异
    [611] = true, -- 晴雪
    [612] = true, -- 米达斯
    [613] = true, -- 云无月
    [614] = true, -- 北洛
    [615] = true, -- 紫都
    [616] = true, -- 崔远之
    [617] = true, -- 莫红袖
    [618] = true, -- 红玉
    [621] = true, -- 耶芙娜
    [622] = true, -- 言雀
    [623] = true, -- 言御
    [624] = true, -- 风晴雪
    [626] = true, -- 百里屠苏
    [628] = true, -- 鸢
    [630] = true, -- 尤尼
    [631] = true, -- 提提亚
    [632] = true, -- 景
    [633] = true, -- 缇诗
    [634] = true, -- 明月尘
    [638] = true, -- 林
    [642] = true, -- 珑
    [643] = true, -- 十手卫
    [645] = true, -- 玄戈
    [646] = true, -- 余音
    [647] = true, -- 龙和
    [648] = true, -- 温留
    [649] = true, -- 拉波
    [650] = true, -- 茜茜
    [651] = true, -- 司旸
    [652] = true, -- 谛卡
    [653] = true, -- 红珠小姐
}

local function GetCardTempl(card_tid)
    return card_cfg[card_tid]
end

--- 获取角色名称
---@param card_tid integer @角色TID
---@return string @角色名称
function _M.GetCardName(card_tid)
    if not card_tid then
        return
    end

    local card_templ = GetCardTempl(card_tid)
    if not card_templ then
        return
    end

    return card_templ.name
end

return _M
