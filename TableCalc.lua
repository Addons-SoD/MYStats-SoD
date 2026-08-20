local defenceTable = {}
local attackTable = {}
function MYS_TableCap(v, sum)
    if v < 0 then
        return 0
    elseif v > 100 - sum then
        return 100 - sum
    else
        return v
    end
end
function MYS_CalcDefenceTable(unit)
    unit = unit or "player"
    local sum = 0
    local skillRank, skillModifier, playerLevel = MYS_GetDefense(unit);
    defenceTable.unhitted = MYS_TableCap(5 + (skillRank + skillModifier - 315) * 0.04, sum)

    sum = defenceTable.unhitted

    defenceTable.parry = MYS_TableCap(GetParryChance() - (315-playerLevel*5) * 0.04, sum)
    sum = sum + defenceTable.parry;
    defenceTable.dodge = MYS_TableCap(GetDodgeChance() - (315-playerLevel*5)* 0.04, sum)
    sum = sum + defenceTable.dodge;

    defenceTable.blockChance = MYS_TableCap(GetBlockChance() - (315-playerLevel*5), sum)
    sum = sum + defenceTable.blockChance;
    defenceTable.critHitted = 5 - (skillRank + skillModifier - 315) * 0.04

    if (C_Engraving.IsRuneEquipped(48143) or C_Engraving.IsRuneEquipped(48685) or C_Engraving.IsRuneEquipped(48343) or
        C_Engraving.IsRuneEquipped(48820)) then
        defenceTable.critHitted = defenceTable.critHitted - 6
    end
    defenceTable.critHitted = MYS_TableCap(defenceTable.critHitted, sum)
    sum = sum + defenceTable.critHitted;
    defenceTable.crushed = MYS_TableCap(15, sum)
    sum = sum + defenceTable.crushed
    defenceTable.hitted = 100 - sum;
    return defenceTable
end
function MYS_GetDefenceTable()
    return defenceTable
end

function MYS_GetWAOutput()
    local ap, apa, apd = UnitAttackPower("player")
    local rap, rapa, rapd = UnitRangedAttackPower("player");
    local _, _, _, castTime = GetSpellInfo(8690)
    local speed = MYS_GetWeaponSpeed("player", 16) or 2
    local rangedHaste = 0
    if unitClassId == MYS_HUNTER_CLASS_ID then
        speed = MYS_GetWeaponSpeed("player", 18) or 2
        local realSpeed, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage("player");
        rangedHaste = ((speed / (realSpeed or speed)) - 1) * 100
        if rangedHaste < 0 then
            rangedHaste = 0
        end
    end

    local realSpeed, offSpeed = UnitAttackSpeed("player");
    local meleeHaste = (speed / (realSpeed or speed) - 1) * 100
    if meleeHaste < 0 then
        meleeHaste = 0
    end
    local spellHaste = (10000 / castTime - 1) * 100;
    return string.format("物理规避：%.2F%%", defenceTable.unhitted + defenceTable.dodge + defenceTable.parry),
        string.format("未被命中：%.2F%%", defenceTable.unhitted),
        string.format("躲闪几率：%.2F%%", defenceTable.dodge),
        string.format("招架几率：%.2F%%", defenceTable.parry), 
        string.format("近战攻强：%d", ap + apa - apd),
        string.format("远程攻强：%d", rap + rapa - rapd),
        string.format("法术伤害：%d", MYS_CalcMaxSpellPower()),
        string.format("近战暴击：%.2F%%", GetCritChance()),
        string.format("远程暴击：%.2F%%", GetRangedCritChance()),
        string.format("法术暴击：%.2F%%", MYS_CalcMaxSpellCrit()),
        string.format("近战急速：%.2F%%", meleeHaste), 
        string.format("远程急速：%.2F%%", rangedHaste),
        string.format("法系急速：%.2F%%", spellHaste),
        string.format("格挡几率：%.2F%%", defenceTable.blockChance),
        string.format("格挡值  ：%d", GetShieldBlock())

end
local wa='!WA:2!fw1ZRTXXxCz8bx2gc1(GH8RIBsDcLgcr2Xko3QxxPMylB5UsU2(0Qz3z2DNMD3zyMzTTYPGOh(MlfAoviqHkkKdTuOIEOLEOqo898IP)feAsBU6(pqFZQfPK0vocpEFZmV5nVF859zMO2mrZGNb))wtCydppjrD7p6WT39(LkvQpMk5HOoTihQ4lpVBzJ5DxaglcJBaJLGrfyCtySmmUfmkFD9)0AwwRA5fn4x6LmJThteHu2ULT9DX2bumX(Eeblq0j)Y)95kL9Rpk2nGj2IrJvoRwDZwvT4xTylPOreBCNyue11wfiiYawiUdF(IvpIft6yZfexQKYINIpxb6Xhy1bZMqGCvGQYkwsfsOmmPXuLHJh8rgyWV44nqedBlqksB(5lYBwoxYmgCQIvPCUu6083V49roocY(u4wSJqh(28luOAJSJPhdYPV43(6)(h)oZqgcxZusVhzwROKqf1WuYjUZMEgdl3qKuQLCuOqsSslwStERro5LoHI0WSXrYaeMDWUdk6tYpxXhYLfYePNBmrugecgThxIj7ohwONSNI5UprOLFRR(poUSypQ)SomUU2g0ZJEibVdfRc(ItjyjQqAmr0y7w1VZMv5xP4BWH6BhNe5qe5lYNDLHvJ6iHpzZSDLwzHYAtc)65MivSiTLoEJ9AA)je1oR0irXH)km5EZrj35EtiG283zK53MJHLCsY(8uucSmsrDZIrZvGPDvcQVp4EN(YICX)VPQdNyHseOfEQmXHSpu4BM4bzN(2RUsZw2nBTIvl(0jsITpbsru3MbSdAe32kt3U1zUiDg1mbAsC0Elr0vRTEE7Ua6km8oyPXrVYPFQm7ZQmO1LDq8t0hGQirBIIiTTGEBI0yO)SLGa(JvZTQwVEpmeHEETaVwC7Q13Q221FysCE0yWNw36UpP1G5BWWKFOuHWnEUGLg1GpgODiIyu4NnaW89JbdU4WAZdrX0OSaVs6PQLwjD6NqqsstLGe7RcM6imKs1BBRtWcjbWFyzxToAFhAlJq04SdMU1uPFAQvAtq80V(kfJrwyeg5kNqZqiXh52X2lKXebf31nYqfhXJUPJaefqr3iR)rEwV0kokMVFirafVpMiDdw4UKoPZBQREDFX9FWl(2FDUYcmXdbenbwhOXHt2vZg1e4F(GIJSB8gr)cckmYwFjwXa8qmo6cocRjiVq)bKpRM1roXetm5cjuC)f3lA9nxB9139gTEOKe6n4LhZgTA1yd(7Dc5083i6ji(qEqxlnv6xmF3XtA5IKQGXPqMBc4ulaYgOoEW7G1eq4PTTtZvTQwDZXvLXazxek8Ly9kKqM)6CJDpGjW7iq8U7KlW)WXFU)7JT5e67nGq)8LeFoWcr96ywVATw8Zm2inOWhph(kDoP60JivZ5tVifZN5p)Lh8Sh9Zp7N(MNF)h)xp6RE(x(4(E68e0ZHuOjlgpnQJT49xA0(xE8zGxTrQya31hAPEaXLvg8qE2ztRCem1b5ExF4zMyCXUrLrhwtuqZ6Xm6tJhSmmZyCOYmewakoMegmJuS01kFRRv(6ZS)FS7)c'
local updateFrame = CreateFrame("Frame")
updateFrame.timeElapsed = 0
updateFrame:SetScript("OnUpdate", func)
local function CanSend()
    if IsAddOnLoaded("WeakAuras") then
        if not IsAddOnLoaded("WeakAurasOptions") then
            if not LoadAddOn("WeakAurasOptions") then
                print("你没有启用WeakAurasOptions插件。")
                return
            end
        end
        return true
    else
        print("你没有安装WeakAuras插件。")
    end
end
function MYS_ImportWA()
    if not CanSend() then
        return
    end
    if not WeakAurasOptions then
        WeakAuras.OpenOptions()
        updateFrame:SetScript("OnUpdate", function(self)
            if not WeakAurasOptions.loadProgress:IsShown() then
                updateFrame:SetScript("OnUpdate", nil)
                updateFrame:Hide()
                WeakAuras.Import(wa)
            end
        end)
    else
        WeakAuras.Import(wa)
    end
end
