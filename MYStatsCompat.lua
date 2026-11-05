--[[
    MYStatsCompat.lua
    ------------------------------------------------------------------
    魔兽世界：无限（World of Warcraft: Forever / 客户端目录 _forever_ /
    产品代号 wowf / 1.60.1 / Interface 16001）兼容层。本文件必须在 toc 最前面加载。

    移植原则（对应「保留原有功能、不做无谓重构」的要求）：
      1. 只在旧式全局确实缺失时才定义它；客户端若仍保留旧 API，本文件完全不会覆盖。
      2. 「仍存在但签名/返回值变了」的 API（GetSpellInfo、GetItemInfo、UnitAura、
         技能线、容器 等）在 shim 内部转发到现代 C_ API，并把返回值还原成旧签名，
         这样调用方（MYStatsUtils / MYStatsCallbacks ...）一行都不用改。
      3. 现代客户端已删除、且无法用旧签名等价表达的能力（10.0+ 天赋标签/层级 API）
         只做能力探测与安全降级，绝不伪造天赋数据（见 MYStatsClassUtils.lua）。
]]

--------------------------------------------------------------------
-- 0) 客户端 / 现代 API 能力探测
--------------------------------------------------------------------
-- 无限客户端 WOW_PROJECT_ID = 18（Classic Era 为 1，Mists 为 6 ...）。
-- 只记录，不用它做功能分支，避免绑定到具体项目号。
MYS_WOW_PROJECT_ID = WOW_PROJECT_ID

-- 10.0 起天赋系统整体改版，GetNumTalentTabs / GetNumTalents / GetTalentInfo
-- （「标签 + 序号」语义）已被移除，无限客户端同样没有。
MYS_TALENT_TAB_API_AVAILABLE = (type(GetNumTalentTabs) == "function"
    and type(GetNumTalents) == "function"
    and type(GetTalentInfo) == "function")

-- 现代天赋/专精系统是否存在，仅用于把「降级原因」写清楚，不参与任何数值计算。
MYS_MODERN_TALENT_API_PRESENT = (type(C_ClassTalents) == "table"
    or type(C_SpecializationInfo) == "table"
    or type(C_Talent) == "table")

--------------------------------------------------------------------
-- 1) secret value 兜底
--------------------------------------------------------------------
-- 12.x 起玩家属性/资源/名字可能是 secret value，不能参与算术、比较或字符串化，
-- 否则会抛 "attempt to perform arithmetic on a secret value" 之类的错误。
-- 统计面板大量对这些值做运算，所以统一走下面两个帮手。
function MYS_IsSecretValue(value)
    if type(issecretvalue) == "function" then
        local ok, isSecret = pcall(issecretvalue, value)
        if ok then
            return isSecret and true or false
        end
    end
    return false
end

-- secret 或 nil 一律按 fallback（默认 0）处理，保证后续算术/格式化安全。
function MYS_Num(value, fallback)
    if MYS_IsSecretValue(value) then
        return fallback or 0
    end
    if type(value) == "number" then
        return value
    end
    return fallback or 0
end

--------------------------------------------------------------------
-- 2) 事件安全注册
--------------------------------------------------------------------
-- 无限客户端没有 SoD 专属事件（例如 RUNE_UPDATED），也没有部分 Classic 事件。
-- 直接 RegisterEvent 一个不存在的事件会抛 "unknown event" 并中断整个文件的执行，
-- 所以统一用 C_EventUtils.IsEventValid（9.0+ 提供的正式接口）过滤。
function MYS_RegisterEvent(frame, event)
    if type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function" then
        local ok, isValid = pcall(C_EventUtils.IsEventValid, event)
        if ok and isValid == false then
            return false
        end
    end
    local ok = pcall(frame.RegisterEvent, frame, event)
    return ok and true or false
end

--------------------------------------------------------------------
-- 3) 法术相关（GetSpellInfo / GetSpellTexture / GetSpellCooldown）
--------------------------------------------------------------------
-- 无限客户端：GetSpellInfo 已删除，C_Spell.GetSpellInfo 返回 SpellInfo 表（可能 nil）。
-- 旧签名：name, rank, icon, castTime, minRange, maxRange, spellID
if type(GetSpellInfo) ~= "function" and type(C_Spell) == "table" and type(C_Spell.GetSpellInfo) == "function" then
    GetSpellInfo = function(spell)
        local info = C_Spell.GetSpellInfo(spell)
        if not info then
            return nil
        end
        -- rank 概念已不存在，保留空串占位以维持旧返回值位置
        return info.name, "", info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID
    end
end

-- 旧签名：texture, originalTexture, ...（C_Spell.GetSpellTexture 返回 iconID, originalIconID）
if type(GetSpellTexture) ~= "function" and type(C_Spell) == "table" and type(C_Spell.GetSpellTexture) == "function" then
    GetSpellTexture = function(spell)
        return C_Spell.GetSpellTexture(spell)
    end
end

-- 旧签名：start, duration, enabled, modRate（C_Spell.GetSpellCooldown 返回 SpellCooldownInfo 表）
if type(GetSpellCooldown) ~= "function" and type(C_Spell) == "table" and type(C_Spell.GetSpellCooldown) == "function" then
    GetSpellCooldown = function(spell)
        local cooldown = C_Spell.GetSpellCooldown(spell)
        if not cooldown then
            return 0, 0, 0
        end
        local enabled = 0
        if cooldown.isEnabled then
            enabled = 1
        end
        return cooldown.startTime or 0, cooldown.duration or 0, enabled, cooldown.modRate
    end
end

-- 旧签名：name, rank（C_SpellBook.GetSpellBookItemName 返回 name, subName）
if type(GetSpellBookItemName) ~= "function" and type(C_SpellBook) == "table" and type(C_SpellBook.GetSpellBookItemName) == "function" then
    GetSpellBookItemName = function(slot, bank)
        return C_SpellBook.GetSpellBookItemName(slot, bank)
    end
end

--------------------------------------------------------------------
-- 4) 物品相关（GetItemInfo / GetItemCount / GetItemStats / 附魔）
--------------------------------------------------------------------
-- 无限客户端：GetItemInfo 已删除，C_Item.GetItemInfo 的 18 个返回值顺序与旧 API 一致
-- （第 6 位 itemType / 第 7 位 itemSubType 正是调用方依赖的位置）。
if type(GetItemInfo) ~= "function" and type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function" then
    GetItemInfo = function(itemInfo)
        return C_Item.GetItemInfo(itemInfo)
    end
end

if type(GetItemCount) ~= "function" and type(C_Item) == "table" and type(C_Item.GetItemCount) == "function" then
    GetItemCount = function(itemInfo, includeBank, includeUses, includeReagentBank)
        return C_Item.GetItemCount(itemInfo, includeBank, includeUses, includeReagentBank)
    end
end

if type(GetItemStats) ~= "function" and type(C_Item) == "table" and type(C_Item.GetItemStats) == "function" then
    GetItemStats = function(itemInfo)
        return C_Item.GetItemStats(itemInfo)
    end
end

if type(GetItemInfoInstant) ~= "function" and type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function" then
    GetItemInfoInstant = function(itemInfo)
        return C_Item.GetItemInfoInstant(itemInfo)
    end
end

-- 旧签名：hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, ...
if type(GetWeaponEnchantInfo) ~= "function" and type(C_Item) == "table" and type(C_Item.GetWeaponEnchantInfo) == "function" then
    GetWeaponEnchantInfo = function()
        return C_Item.GetWeaponEnchantInfo()
    end
end

-- 魔杖概念在 10.0 后已被移除（远程栏不再有 wand 判定），拿不到就按「不是魔杖」处理。
if type(HasWandEquipped) ~= "function" then
    HasWandEquipped = function()
        return false
    end
end

-- GetInventoryItemID 在无限客户端仍由 Blizzard 保留（插件全程依赖它读装备）。
-- 万一缺失，就从 GetInventoryItemLink 返回的链接里解析 itemID，语义与旧 API 一致。
if type(GetInventoryItemID) ~= "function" and type(GetInventoryItemLink) == "function" then
    GetInventoryItemID = function(unit, slot)
        local itemLink = GetInventoryItemLink(unit, slot)
        if not itemLink then
            return nil
        end
        local itemId = string.match(itemLink, "item:(%d+)")
        return tonumber(itemId)
    end
end

--------------------------------------------------------------------
-- 5) 容器相关（GetContainerNumSlots / GetContainerItemInfo）
--------------------------------------------------------------------
if type(GetContainerNumSlots) ~= "function" and type(C_Container) == "table" and type(C_Container.GetContainerNumSlots) == "function" then
    GetContainerNumSlots = function(bag)
        return C_Container.GetContainerNumSlots(bag)
    end
end

-- 旧签名：icon, itemCount, locked, quality, readable, lootable, itemLink,
--         isFiltered, noValue, itemID, isBound（C_Container 返回 ContainerItemInfo 表）
if type(GetContainerItemInfo) ~= "function" and type(C_Container) == "table" and type(C_Container.GetContainerItemInfo) == "function" then
    GetContainerItemInfo = function(bag, slot)
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if not info then
            return nil
        end
        return info.iconFileID, info.stackCount, info.isLocked, info.quality, info.isReadable,
            info.hasLoot, info.hyperlink, info.isFiltered, info.hasNoValue, info.itemID, info.isBound
    end
end

--------------------------------------------------------------------
-- 6) 光环相关（UnitAura / UnitBuff / UnitDebuff）
--------------------------------------------------------------------
-- 无限客户端：三个全局都被 C_UnitAuras.GetAuraDataByIndex 取代（返回 AuraData 表）。
-- 这里还原成旧的多返回值顺序，第 10 位仍然是 spellId（MYS_GetMP5FromAuras 依赖它）。
local function MYS_LegacyAuraAt(unit, index, filter)
    if type(C_UnitAuras) ~= "table" or type(C_UnitAuras.GetAuraDataByIndex) ~= "function" then
        return nil
    end
    -- 旧 API 索引从 1 开始，index 0 表示「首领光环」，C_ API 不认 → 直接返回 nil
    if type(index) ~= "number" or index < 1 then
        return nil
    end
    local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
    if not aura then
        return nil
    end
    return aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration,
        aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal,
        aura.spellId or aura.spellID, aura.canApplyAura, aura.isBossAura,
        aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod
end

if type(UnitAura) ~= "function" then
    UnitAura = function(unit, index, filter)
        return MYS_LegacyAuraAt(unit, index, filter)
    end
end

if type(UnitBuff) ~= "function" then
    UnitBuff = function(unit, index, filter)
        return MYS_LegacyAuraAt(unit, index, filter or "HELPFUL")
    end
end

if type(UnitDebuff) ~= "function" then
    UnitDebuff = function(unit, index, filter)
        return MYS_LegacyAuraAt(unit, index, filter or "HARMFUL")
    end
end

--------------------------------------------------------------------
-- 7) 技能线相关（GetNumSkillLines / GetSkillLineInfo）
--------------------------------------------------------------------
-- 无限客户端：技能线已迁移到 C_SkillInfo，且 GetSkillLineInfo 返回 SkillLineAttributes 表。
-- 旧签名：name, isHeader, isExpanded, rank, tempPoints, modifier, maxRank, ...
local function MYS_LegacySkillLineInfo(index)
    if type(C_SkillInfo) ~= "table" or type(C_SkillInfo.GetSkillLineInfo) ~= "function" then
        return nil
    end
    local info = C_SkillInfo.GetSkillLineInfo(index)
    if not info then
        return nil
    end
    local isHeader = info.isHeader and 1 or nil
    local isExpanded = nil
    if info.isHeader and not info.isCollapsed then
        isExpanded = 1
    end
    return info.name, isHeader, isExpanded, info.rank, info.tempPoints, info.modifier,
        info.maxRank, info.isAbandonable and 1 or nil, info.stepCost, info.rankCost,
        info.minLevel, info.costType, info.description
end

if type(GetNumSkillLines) ~= "function" then
    GetNumSkillLines = function()
        if type(C_SkillInfo) == "table" and type(C_SkillInfo.GetNumSkillLines) == "function" then
            return C_SkillInfo.GetNumSkillLines()
        end
        -- 拿不到技能线时返回 0，调用方的循环自然空转，不会崩
        return 0
    end
end

if type(GetSkillLineInfo) ~= "function" then
    GetSkillLineInfo = function(index)
        return MYS_LegacySkillLineInfo(index)
    end
end

--------------------------------------------------------------------
-- 8) 单位属性兜底（无限客户端保留 Unit 系统，但少数旧全局已删除）
--------------------------------------------------------------------
-- UnitAttackBothHands 已删除：用 UnitAttackPower 的 base + posBuff 还原旧签名。
if type(UnitAttackBothHands) ~= "function" then
    UnitAttackBothHands = function(unit)
        local base, posBuff = UnitAttackPower(unit)
        return MYS_Num(base), MYS_Num(posBuff)
    end
end

-- UnitRangedAttack 已删除：用 UnitRangedAttackPower 还原旧签名。
if type(UnitRangedAttack) ~= "function" then
    UnitRangedAttack = function(unit)
        local base, posBuff = UnitRangedAttackPower(unit)
        return MYS_Num(base), MYS_Num(posBuff)
    end
end

-- UnitHasMana 已删除：用 UnitPowerType 判断（0 = Enum.PowerType.Mana）。
if type(UnitHasMana) ~= "function" then
    UnitHasMana = function(unit)
        if type(UnitPowerType) == "function" then
            return UnitPowerType(unit) == 0
        end
        return false
    end
end

-- 数字缩写函数在新客户端可能不存在，退化成正整数文本，避免 UI 报错。
if type(BreakUpLargeNumbers) ~= "function" then
    BreakUpLargeNumbers = function(value)
        if type(value) ~= "number" then
            return tostring(value)
        end
        return tostring(math.floor(value))
    end
end

-- 变形形态：新客户端以 C_ShapeshiftForm 提供，旧的 GetNumShapeshiftForms /
-- GetShapeshiftFormInfo 已删除。取不到就返回 0 / nil，让德鲁伊逻辑走非变形分支。
if type(GetNumShapeshiftForms) ~= "function" or type(GetShapeshiftFormInfo) ~= "function" then
    if type(GetNumShapeshiftForms) ~= "function" then
        GetNumShapeshiftForms = function()
            if type(C_ShapeshiftForm) == "table" and type(C_ShapeshiftForm.GetNumShapeshiftForms) == "function" then
                return C_ShapeshiftForm.GetNumShapeshiftForms()
            end
            return 0
        end
    end
    if type(GetShapeshiftFormInfo) ~= "function" then
        GetShapeshiftFormInfo = function(index)
            if type(C_ShapeshiftForm) == "table" and type(C_ShapeshiftForm.GetShapeshiftFormInfo) == "function" then
                local info = C_ShapeshiftForm.GetShapeshiftFormInfo(index)
                if info then
                    -- 旧签名：icon, active, name, castable, spellID
                    return info.icon, info.isActive, info.name, info.isCastable, info.spellID
                end
            end
            return nil
        end
    end
end

--------------------------------------------------------------------
-- 8b) 旧下拉菜单 API 兜底
--------------------------------------------------------------------
-- 面板用 UIDropDownMenu* 这套 legacy 接口做分类切换（模板在 MYStatsUI 里也做了探测）。
-- 若客户端已整体移除，这里补空实现，让 SetupDropdown 不会因「调用 nil」而中断面板创建。
local MYS_DropdownStubs = {
    UIDropDownMenu_CreateInfo = function() return {} end,
    UIDropDownMenu_AddButton = function() end,
    UIDropDownMenu_Initialize = function() end,
    UIDropDownMenu_SetSelectedID = function() end,
    UIDropDownMenu_SetWidth = function() end,
    UIDropDownMenu_JustifyText = function() end,
}
for stubName, stubFunc in pairs(MYS_DropdownStubs) do
    if type(_G[stubName]) ~= "function" then
        _G[stubName] = stubFunc
    end
end

--------------------------------------------------------------------
-- 9) SoD 专属系统兜底
---------------------------------------------------------------------- C_Engraving（符文雕刻）是 Season of Discovery 独有系统，无限客户端没有。
-- TableCalc.lua 里直接调用 C_Engraving.IsRuneEquipped，这里补一个空实现防止索引 nil。
if type(C_Engraving) ~= "table" then
    C_Engraving = {
        IsRuneEquipped = function()
            return false
        end,
    }
elseif type(C_Engraving.IsRuneEquipped) ~= "function" then
    C_Engraving.IsRuneEquipped = function()
        return false
    end
end

--------------------------------------------------------------------
-- 10) 面板依赖的全局字符串兜底
--------------------------------------------------------------------
-- 这些 GlobalString 会被 format()/string.match() 直接当格式串使用，
-- 一旦缺失就是硬错误（而不是显示为空）。只在缺失时填英文默认值。
local MYS_FallbackStrings = {
    -- 颜色码：缺失时字符串拼接会直接报 "attempt to concatenate a nil value"
    HIGHLIGHT_FONT_COLOR_CODE = "|cffffffff",
    NORMAL_FONT_COLOR_CODE = "|cffc7c7cf",
    FONT_COLOR_CODE_CLOSE = "|r",
    GREEN_FONT_COLOR_CODE = "|cff20ff20",
    RED_FONT_COLOR_CODE = "|cffff2020",
    ORANGE_FONT_COLOR_CODE = "|cffff8040",
    DEFENSE = "Defense",
    HIT = "Hit",
    STAT_FORMAT = "|cffffffff%s:|r",
    PAPERDOLLFRAME_TOOLTIP_FORMAT = "%s",
    NOT_APPLICABLE = "N/A",
    NUM_STATS = 5,
    STAT_ARMOR = "Armor",
    STAT_STRENGTH = "Strength",
    STAT_AGILITY = "Agility",
    STAT_STAMINA = "Stamina",
    STAT_INTELLECT = "Intellect",
    STAT_SPIRIT = "Spirit",
    -- 主属性行的标题由 MYStatsUtils 通过 _G["SPELL_STAT"..i.."_NAME"] 取
    SPELL_STAT1_NAME = "Strength",
    SPELL_STAT2_NAME = "Agility",
    SPELL_STAT3_NAME = "Stamina",
    SPELL_STAT4_NAME = "Intellect",
    SPELL_STAT5_NAME = "Spirit",
    STAT_CRITICAL_STRIKE = "Critical Strike",
    STAT_HIT_CHANCE = "Hit Chance",
    STAT_DODGE = "Dodge",
    STAT_PARRY = "Parry",
    STAT_BLOCK = "Block",
    STAT_SPELLPOWER = "Spell Power",
    STAT_SPELLPOWER_TOOLTIP = "Spell Power",
    STAT_SPELLHEALING = "Spell Healing",
    STAT_SPELLHEALING_TOOLTIP = "Spell Healing",
    STAT_ATTACK_POWER = "Attack Power",
    DEFENSE_COLON = "Defense:",
    DODGE_CHANCE = "Dodge Chance",
    PARRY_CHANCE = "Parry Chance",
    BLOCK_CHANCE = "Block Chance",
    MANA_REGEN = "Mana Regen",
    MANA_REGEN_TOOLTIP = "Mana Regen",
    CRIT_ABBR = "Crit",
    SPELL_SCHOOL1_CAP = "Holy",
    SPELL_SCHOOL2_CAP = "Fire",
    SPELL_SCHOOL3_CAP = "Nature",
    SPELL_SCHOOL4_CAP = "Frost",
    SPELL_SCHOOL5_CAP = "Shadow",
    SPELL_SCHOOL6_CAP = "Arcane",
    SPELL_SCHOOL7_CAP = "Physical",
    ATTACK_SPEED_COLON = "Speed:",
    DAMAGE_COLON = "Damage:",
    DAMAGE_PER_SECOND = "DPS",
    DAMAGE = "Damage",
    WEAPON_SPEED = "Speed",
    ATTACK_SPEED = "Attack Speed",
    ATTACK_TOOLTIP = "Attack Power",
    ATTACK_TOOLTIP_SUBTEXT = "Attack Power",
    MELEE_ATTACK_POWER = "Melee Attack Power",
    MELEE_ATTACK_POWER_TOOLTIP = "Melee Attack Power",
    RANGED_ATTACK_POWER = "Ranged Attack Power",
    RANGED_ATTACK_POWER_TOOLTIP = "Ranged Attack Power",
    ARMOR = "Armor",
    ARMOR_TOOLTIP = "Armor",
    ATTACK_POWER_MAGIC_NUMBER = 14,
    INVTYPE_WEAPONMAINHAND = "Main Hand",
    INVTYPE_WEAPONOFFHAND = "Off Hand",
    INVTYPE_RANGED = "Ranged",
    ITEM_MOD_BLOCK_RATING_SHORT = "Block",
    ITEM_MOD_BLOCK_RATING = "Block Rating",
    ITEM_MOD_BLOCK_VALUE = "Block Value",
    ITEM_MOD_BLOCK_VALUE_SHORT = "Block Value",
    PLAYERSTAT_BASE_STATS = "Base Stats",
    PLAYERSTAT_MELEE_COMBAT = "Melee",
    PLAYERSTAT_RANGED_COMBAT = "Ranged",
    PLAYERSTAT_SPELL_COMBAT = "Spell",
    PLAYERSTAT_DEFENSES = "Defenses",
}
for key, defaultValue in pairs(MYS_FallbackStrings) do
    if _G[key] == nil then
        _G[key] = defaultValue
    end
end
