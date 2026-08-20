--[[
    Util functions that wrap my interface and the Blizzard's WoW Classic lua API code for ease of use
]]
-- for k in pairs(_G) do
-- 	if type(_G[k])=='string' and string.match(_G[k],"所有神圣") then
-- 		print(k,_G[k])
-- 	end
-- end
local MYS_ScanTooltip = CreateFrame("GameTooltip", "MYS_ScanTooltip", nil, "GameTooltipTemplate");
MYS_ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
local MYS_ScanTooltipPrefix = "MYS_ScanTooltip";

local g_lastSeenBaseManaRegen = 0;
local g_lastSeenCastingManaRegen = 0;
g_APFromADItems = 0;

-- GENERAL UTIL FUNCTIONS --
local function MYS_GetAppropriateDamage(unit, category)
	if category == PLAYERSTAT_MELEE_COMBAT then
		return UnitDamage(unit);
	elseif category == PLAYERSTAT_RANGED_COMBAT then
		local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
		return minDamage, maxDamage, nil, nil, bonusPos, bonusNeg, percent;
	end
end

local function MYS_GetAppropriateAttackSpeed(unit, category)
	if category == PLAYERSTAT_MELEE_COMBAT then
		return UnitAttackSpeed(unit);
	elseif category == PLAYERSTAT_RANGED_COMBAT then
		local attackSpeed = select(1, UnitRangedDamage(unit))
		return attackSpeed, 0;
	end
end

local function MYS_GetAppropriateAttackRaiting(unit, category)
	local attackBase = 0;
	local attackModifier = 0;

	if category == PLAYERSTAT_MELEE_COMBAT then
		attackBase, attackModifier = UnitAttackBothHands(unit);
	elseif category == PLAYERSTAT_RANGED_COMBAT then
		attackBase, attackModifier = UnitRangedAttack(unit)
	end

	local attackWithModifier = attackBase + attackModifier;
	return attackWithModifier;
end

local function MYS_PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue, precision)
	if ( isPercentage ) then
		precision = precision or "%.1F%%";
		statFrame.Value:SetText(format(precision, numericValue));
	else
		statFrame.Value:SetText(text);
	end
	statFrame.numericValue = numericValue;
	
	if ( statFrame.Label ) then
		statFrame.Label:SetText(format(STAT_FORMAT, label));
		statFrame.Label:SetWidth(statFrame:GetWidth() - statFrame.Value:GetWidth() - 20);
		statFrame.Label:SetHeight(statFrame:GetHeight());
		statFrame.Label:SetJustifyH("LEFT");
	end
end

local function MYS_PaperDollFormatStat(name, base, posBuff, negBuff)
	local effective = max(0,base + posBuff + negBuff);
	local text = HIGHLIGHT_FONT_COLOR_CODE..name.." "..effective;
	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text = text..FONT_COLOR_CODE_CLOSE;
	else 
		if ( posBuff > 0 or negBuff < 0 ) then
			text = text.." ("..base..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			text = text..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			text = text..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			text = text..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end

		-- if there is a negative buff then show the main number in red, even if there are
		-- positive buffs. Otherwise show the number in green
		if ( negBuff < 0 ) then
			effective = RED_FONT_COLOR_CODE..effective..FONT_COLOR_CODE_CLOSE;
		elseif (posBuff > 0) then
			effective = GREEN_FONT_COLOR_CODE..effective..FONT_COLOR_CODE_CLOSE;
		end
	end
    
    return effective, text;
end

local function MYS_GetMP5FromGear(unit)
	local mp5 = 0;
	for i=1,18 do
		local itemLink = GetInventoryItemLink(unit, i);
		if itemLink then
			local stats = GetItemStats(itemLink);
			if stats then
				-- For some reason this returns (mp5 - 1) so I have to add 1 to the result
				local statMP5 = stats["ITEM_MOD_POWER_REGEN0_SHORT"];
				if (statMP5) then
					mp5 = mp5 + statMP5 + 1;
				end
			end
		end
	end

	local unitClassId = select(3, UnitClass(unit));
	if (unitClassId == MYS_PRIEST_CLASS_ID) then
		local zgEnchantMp5 = MYS_GetMp5FromPriestZGEnchants(unit);
		if (zgEnchantMp5 > 0) then
			mp5 = mp5 + zgEnchantMp5;
		end
	end

	if (MYS_HasEnchant(unit, INVSLOT_WRIST, 2565)) then -- Mana Regen
		mp5 = mp5 + 4;
	end

	if (MYS_HasEnchant(unit, INVSLOT_SHOULDER, 2715)) then -- Resilience of the Scourge
		mp5 = mp5 + 5;
	end

	local tempMHEnchantId = select(4, GetWeaponEnchantInfo());
	if (tempMHEnchantId == 2629) then -- Brilliant Mana Oil
		mp5 = mp5 + 12;
	end

	return mp5;
end

 function MYS_GetSkillRankAndModifier(skillHeader, skillName)
	local numSkills = GetNumSkillLines();
	local skillIndex = 0;
	local currentHeader = nil;

	for i = 1, numSkills do
		local currentSkillName = select(1, GetSkillLineInfo(i));
		local isHeader = select(2, GetSkillLineInfo(i));
		if isHeader ~= nil and isHeader then
			currentHeader = currentSkillName;
		else
			if (currentHeader == skillHeader and currentSkillName == skillName) then
				skillIndex = i;
				break;
			end
		end
	end

	local skillRank = nil;
	local skillModifier = nil;
	if (skillIndex > 0) then
		skillRank = select(4, GetSkillLineInfo(skillIndex));
		skillModifier = select(6, GetSkillLineInfo(skillIndex));
	end

	return skillRank, skillModifier;
end
function MYS_Round(num, decimalPlaces)
    if (not num) then
        return 0
    end
    local mult = 10^(decimalPlaces)
    return math.floor(num * mult + 0.5) / mult
end
function MYS_GetMovementSpeed()
    local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")

    local currentSpeed

   
    if IsSwimming() then
        currentSpeed = swimSpeed
    else
        currentSpeed = runSpeed
    end

    currentSpeed = currentSpeed / 7 * 100
    return MYS_Round(currentSpeed, 0)
end
function MYS_GetPlayerWeaponSkill(unit, weaponSlotId)
	local totalWeaponSkill = nil;

	local unitClassId = select(3, UnitClass(unit));
	-- Druid checks
	local shapeIndex = -1;
	local shapeSpellId=-1;
	if (unitClassId == MYS_DRUID_CLASS_ID) then
		shapeIndex,shapeSpellId = MYS_GetShapeshiftForm();
	end
	if (unitClassId == MYS_DRUID_CLASS_ID) and (shapeIndex > 0) and shapeSpellId ~= 24858 then
		local skillRank, skillModifier = MYS_GetSkillRankAndModifier(MYS_SKILL_LINE_CLASS or "职业技能", MYS_SKILL_LINE_FERAL or "野性战斗");
		
		totalWeaponSkill =skillRank+skillModifier;
	else
		local itemId = GetInventoryItemID(unit, weaponSlotId);
		if (itemId) then
			local itemSubtypeId = select(7, GetItemInfoInstant(itemId));
			if itemSubtypeId then
				local weaponString = g_WeaponStringByWeaponId[itemSubtypeId];
				if weaponString then
					local skillRank, skillModifier = MYS_GetSkillRankAndModifier(MYS_WEAPON_SKILLS_HEADER, weaponString);
					if skillRank and skillModifier then
						-- Weapon skill from racials should be already in skillRank
						totalWeaponSkill = skillRank + skillModifier;
					end
				end
			end
		end
	end

	return totalWeaponSkill;
end

function MYS_GetPlayerMissChances(unit, playerHit, totalWeaponSkill)
	local hitChance = playerHit;
	local missChanceVsNPC = 5; -- Level 60 npcs with 300 def
	local missChanceVsBoss = 9;
	local missChanceVsPlayer = 5; -- Level 60 player def is 300 base

	if totalWeaponSkill then
		local bossDefense = 315; -- level 63
		local playerBossDeltaSkill = bossDefense - totalWeaponSkill;
		
		if (playerBossDeltaSkill > 10) then
			if (hitChance >= 1) then
				hitChance = hitChance - 1;
			end

			missChanceVsBoss = 5 + (playerBossDeltaSkill * 0.2);
		else
			missChanceVsBoss = 5 + (playerBossDeltaSkill * 0.1);
		end
	end

	local dwMissChanceVsNpc = math.max(0, (missChanceVsNPC*0.8 + 20) - playerHit);
	local dwMissChanceVsBoss = math.max(0, (missChanceVsBoss*0.8 + 20) - hitChance);
	local dwMissChanceVsPlayer = math.max(0, (missChanceVsPlayer*0.8 + 20) - playerHit);

	missChanceVsNPC = math.max(0, missChanceVsNPC - playerHit);
	missChanceVsBoss = math.max(0, missChanceVsBoss - hitChance);
	missChanceVsPlayer = math.max(0, missChanceVsPlayer - playerHit);

	return missChanceVsNPC, missChanceVsBoss, missChanceVsPlayer, dwMissChanceVsNpc, dwMissChanceVsBoss, dwMissChanceVsPlayer;
end

function MYS_HasEnchant(unit, slotId, enchantId)
	local itemLink = GetInventoryItemLink(unit, slotId);
	if itemLink then
		local itemId, enchant = itemLink:match("item:(%d+):(%d*)");
		if enchant then
			if tonumber(enchant) == enchantId then
				return true;
			end
		end
	end

	return false;
end

function MYS_GetAttackPowerFromArgentDawnItems(unit)
	local chestId = GetInventoryItemID(unit, INVSLOT_CHEST);
	local glovesId = GetInventoryItemID(unit, INVSLOT_HAND);
	local bracerId = GetInventoryItemID(unit, INVSLOT_WRIST);
	local trinketFirst = GetInventoryItemID(unit, INVSLOT_TRINKET1);
	local trinketSecond = GetInventoryItemID(unit, INVSLOT_TRINKET2);

	local apVsUndead = 0;
	
	if (g_ArgentDawnAPItems[chestId] ~= nil) then
		apVsUndead = apVsUndead + g_ArgentDawnAPItems[chestId];
	end

	if (g_ArgentDawnAPItems[glovesId] ~= nil) then
		apVsUndead = apVsUndead + g_ArgentDawnAPItems[glovesId];
	end

	if (g_ArgentDawnAPItems[bracerId] ~= nil) then
		apVsUndead = apVsUndead + g_ArgentDawnAPItems[bracerId];
	end

	if (g_ArgentDawnAPItems[trinketFirst] ~= nil) then
		apVsUndead = apVsUndead + g_ArgentDawnAPItems[trinketFirst];
	end

	if (g_ArgentDawnAPItems[trinketSecond] ~= nil) then
		apVsUndead = apVsUndead + g_ArgentDawnAPItems[trinketSecond];
	end

	local tempMHEnchantId = select(4, GetWeaponEnchantInfo());
	if (tempMHEnchantId == 2684) then -- Consecrated Sharpening Stone
		apVsUndead = apVsUndead + 100;
	end

	local tempOHEnchantId = select(8, GetWeaponEnchantInfo());
	if (tempOHEnchantId == 2684) then -- Consecrated Sharpening Stone
		apVsUndead = apVsUndead + 100;
	end

	return apVsUndead;
end

function MYS_GetSpellkPowerFromArgentDawnItems(unit)
	local chestId = GetInventoryItemID(unit, INVSLOT_CHEST);
	local glovesId = GetInventoryItemID(unit, INVSLOT_HAND);
	local bracerId = GetInventoryItemID(unit, INVSLOT_WRIST);
	local trinketFirst = GetInventoryItemID(unit, INVSLOT_TRINKET1);
	local trinketSecond = GetInventoryItemID(unit, INVSLOT_TRINKET2);

	local spVsUndead = 0;
	
	if (g_ArgentDawnSPItems[chestId] ~= nil) then
		spVsUndead = spVsUndead + g_ArgentDawnSPItems[chestId];
	end

	if (g_ArgentDawnSPItems[glovesId] ~= nil) then
		spVsUndead = spVsUndead + g_ArgentDawnSPItems[glovesId];
	end

	if (g_ArgentDawnSPItems[bracerId] ~= nil) then
		spVsUndead = spVsUndead + g_ArgentDawnSPItems[bracerId];
	end

	if (g_ArgentDawnSPItems[trinketFirst] ~= nil) then
		spVsUndead = spVsUndead + g_ArgentDawnSPItems[trinketFirst];
	end

	if (g_ArgentDawnSPItems[trinketSecond] ~= nil) then
		spVsUndead = spVsUndead + g_ArgentDawnSPItems[trinketSecond];
	end

	local tempMHEnchantId = select(4, GetWeaponEnchantInfo());
	if (tempMHEnchantId == 2685) then -- Blessed Wizard Oil
		spVsUndead = spVsUndead + 60;
	end

	local tempOHEnchantId = select(8, GetWeaponEnchantInfo());
	if (tempOHEnchantId == 2685) then -- Blessed Wizard Oil
		spVsUndead = spVsUndead + 60;
	end

	return spVsUndead;
end

function MYS_CacheAPFromADItems(unit)
	g_APFromADItems = MYS_GetAttackPowerFromArgentDawnItems(unit);
end

function MYS_GetDefense(unit)
	local numSkills = GetNumSkillLines();
	local skillIndex = 0;
	local currentHeader = nil;
	local playerLevel = UnitLevel(unit);

	for i = 1, numSkills do
		local skillName = select(1, GetSkillLineInfo(i));
		local isHeader = select(2, GetSkillLineInfo(i));

		if isHeader ~= nil and isHeader then
			currentHeader = skillName;
		else
			if (currentHeader == MYS_WEAPON_SKILLS_HEADER and skillName == MYS_DEFENSE) then
				skillIndex = i;
				break;
			end
		end
	end

	local skillRank, skillModifier;
	if (skillIndex > 0) then
		skillRank = select(4, GetSkillLineInfo(skillIndex));
		skillModifier = select(6, GetSkillLineInfo(skillIndex));
	else
		-- Use this as a backup, just in case something goes wrong
		skillRank, skillModifier = UnitDefense(unit); --Not working properly
	end

	return skillRank, skillModifier, playerLevel;
end
-- GENERAL UTIL FUNCTIONS END --

-- PRIMARY STATS --
function MYS_PaperDollFrame_SetPrimaryStats(statFrames, unit)
	
	local statIndexTable = {
		"STRENGTH",
		"AGILITY",
		"STAMINA",
		"INTELLECT",
		"SPIRIT",
	}

	-- Fix for classic (NUM_STATS instead of NUM_STATS-1)
	for i=1, NUM_STATS, 1 do
		local frameText;

		local stat;
		local effectiveStat;
		local posBuff;
		local negBuff;
		stat, effectiveStat, posBuff, negBuff = UnitStat(unit, i);
		
		-- Set the tooltip text
		local tooltipText = HIGHLIGHT_FONT_COLOR_CODE.._G["SPELL_STAT"..i.."_NAME"].." ";

		-- Get class specific tooltip for that stat
		local temp, classFileName = UnitClass(unit);
		local classStatText = _G[strupper(classFileName).."_"..statIndexTable[i].."_".."TOOLTIP"];
		-- If can't find one use the default
		if ( not classStatText ) then
			classStatText = _G["DEFAULT".."_"..statIndexTable[i].."_".."TOOLTIP"];
		end

		if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
			--text:SetText(effectiveStat);
			frameText = effectiveStat;
			statFrames[i].tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
			statFrames[i].tooltip2 = classStatText;
		else 
			tooltipText = tooltipText..effectiveStat;
			if ( posBuff > 0 or negBuff < 0 ) then
				tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
			end
			if ( posBuff > 0 ) then
				tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
			end
			if ( negBuff < 0 ) then
				tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
			end
			if ( posBuff > 0 or negBuff < 0 ) then
				tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
			end
			statFrames[i].tooltip = tooltipText;
			statFrames[i].tooltip2= classStatText;

			-- If there are any negative buffs then show the main number in red even if there are
			-- positive buffs. Otherwise show in green.
			if ( negBuff < 0 ) then
				frameText = RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE;
			else
				frameText = GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE;
			end
		end
		MYS_PaperDollFrame_SetLabelAndText(statFrames[i], _G["SPELL_STAT"..i.."_NAME"], frameText, false, effectiveStat);
		statFrames[i]:Show();
	end
	local speed=MYS_GetMovementSpeed();
	local formats="%d%%"
	if speed>100 then
		formats=GREEN_FONT_COLOR_CODE.."%d%%"..FONT_COLOR_CODE_CLOSE
	elseif speed<100 then
		formats=RED_FONT_COLOR_CODE.."%d%%"..FONT_COLOR_CODE_CLOSE
	end
	MYS_PaperDollFrame_SetLabelAndText(statFrames[6], "移速", "123", true,speed, formats);
	statFrames[6]:Show();
end

-- DAMAGE --
function MYS_PaperDollFrame_SetDamage(statFrame, unit, category)

	if (category == PLAYERSTAT_RANGED_COMBAT) and not IsRangedWeapon() then
		MYS_PaperDollFrame_SetLabelAndText(statFrame, DAMAGE, NOT_APPLICABLE, false, 0);
		statFrame:Show();
		return;
	end

    statFrame:SetScript("OnEnter", MYS_CharacterDamageFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
    end)

    local speed, offhandSpeed = MYS_GetAppropriateAttackSpeed(unit, category);
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percentMod = MYS_GetAppropriateDamage(unit, category);
	
	-- sometimes this is wrongly reported as 0
	if percentMod == nil or percentMod == 0 then
		percentMod = 1;
	end

	if speed == nil or speed == 0 then
		speed = 1;
	end

	if (UISettingsCharacter.showStatsFromArgentDawnItems) then
		local bonusDPS = g_APFromADItems / ATTACK_POWER_MAGIC_NUMBER;
		local bonusDmgMainHand = speed * bonusDPS;
		minDamage = minDamage + bonusDmgMainHand;
		maxDamage = maxDamage + bonusDmgMainHand;
	end
    
    local displayMin = max(floor(minDamage),1);
	local displayMax = max(ceil(maxDamage),1);
    
    minDamage = (minDamage / percentMod) - physicalBonusPos - physicalBonusNeg;
	maxDamage = (maxDamage / percentMod) - physicalBonusPos - physicalBonusNeg;
	
    local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percentMod;
	local totalBonus = (fullDamage - baseDamage);
	local damagePerSecond = (max(fullDamage,1) / speed);
    local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
    
    local colorPos = "|cff20ff20";
    local colorNeg = "|cffff2020";
	
    -- epsilon check
	if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
		totalBonus = 0.0;
    end
    
    local damageText;

    if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText = displayMin.." - "..displayMax;
		else
			damageText = displayMin.."-"..displayMax;
		end
	else
		-- set bonus color and display
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText = color..displayMin.." - "..displayMax.."|r";
		else
			damageText = color..displayMin.."-"..displayMax.."|r";
		end
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percentMod > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percentMod*100+0.5).."%|r";
		elseif ( percentMod < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percentMod*100+0.5).."%|r";
		end
    end
    
    MYS_PaperDollFrame_SetLabelAndText(statFrame, DAMAGE, damageText, false, displayMax);

    statFrame.damage = damageTooltip;
	statFrame.attackSpeed = speed;
    statFrame.dps = damagePerSecond;
	statFrame.attackRating = MYS_GetAppropriateAttackRaiting(unit, category);
	statFrame.TooltipMainTxt = INVTYPE_WEAPONMAINHAND;

	if (category == PLAYERSTAT_RANGED_COMBAT) and IsRangedWeapon() then
		statFrame.TooltipMainTxt = INVTYPE_RANGED;
	end

    -- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed and category == PLAYERSTAT_MELEE_COMBAT) then
		if offhandSpeed == 0 then
			offhandSpeed = 1;
		end

		if (UISettingsCharacter.showStatsFromArgentDawnItems) then
			local bonusDPS = g_APFromADItems / ATTACK_POWER_MAGIC_NUMBER;
			local bonusDmgOffHand = offhandSpeed * bonusDPS;
			minOffHandDamage = minOffHandDamage + bonusDmgOffHand;
			maxOffHandDamage = maxOffHandDamage + bonusDmgOffHand;
		end

		minOffHandDamage = (minOffHandDamage / percentMod) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percentMod) - physicalBonusPos - physicalBonusNeg;

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percentMod;
		local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
		local offhandDamageTooltip = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1);
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percentMod > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percentMod*100+0.5).."%|r";
		elseif ( percentMod < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percentMod*100+0.5).."%|r";
		end
		statFrame.offhandDamage = offhandDamageTooltip;
		statFrame.offhandAttackSpeed = offhandSpeed;
		statFrame.offhandDps = offhandDamagePerSecond;
	else
		statFrame.offhandAttackSpeed = nil;
    end

	statFrame:Show();
end

-- Note: while this function was historically named "BothHands",
-- it looks like it only ever displayed attack rating for the main hand.
function MYS_PaperDollFrame_SetAttackBothHands(statFrame, unit)

	local mainHandAttackBase, mainHandAttackMod = UnitAttackBothHands(unit);
	local attackWithModifier = mainHandAttackBase + mainHandAttackMod;
	local attackText;

	if( mainHandAttackMod == 0 ) then
		attackText = mainHandAttackBase;
	else
		local color = RED_FONT_COLOR_CODE;
		if( mainHandAttackMod > 0 ) then
			color = GREEN_FONT_COLOR_CODE;
		end
		attackText = color..attackWithModifier..FONT_COLOR_CODE_CLOSE;
	end

	MYS_PaperDollFrame_SetLabelAndText(statFrame, DAMAGE, attackText, false, attackWithModifier);

	statFrame.tooltip = ATTACK_TOOLTIP;
	statFrame.tooltip2 = ATTACK_TOOLTIP_SUBTEXT;
	statFrame:Show();
end

function MYS_PaperDollFrame_SetMeleeAttackPower(statFrame, unit)
    
	local base, posBuff, negBuff = UnitAttackPower(unit);

	if (UISettingsCharacter.showStatsFromArgentDawnItems) then
		posBuff = posBuff + g_APFromADItems;
	end
    
    local valueText, tooltipText = MYS_PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff);
    local valueNum = max(0, base + posBuff + negBuff);
    MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_ATTACK_POWER, valueText, false, valueNum);
    statFrame.tooltip = tooltipText;
	statFrame.tooltip2 = format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);
	statFrame:Show();
end

function MYS_PaperDollFrame_SetRangedAttackPower(statFrame, unit)
	
	if not IsRangedWeapon() then
		MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_ATTACK_POWER, NOT_APPLICABLE, false, 0);
		statFrame:Show();
		return;
	end

	if ( HasWandEquipped() ) then
		MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_ATTACK_POWER, NOT_APPLICABLE, false, 0);
		statFrame.tooltip = nil;
		statFrame:Show();
		return;
	end

	local base, posBuff, negBuff = UnitRangedAttackPower(unit);

	if (UISettingsCharacter.showStatsFromArgentDawnItems) then
		posBuff = posBuff + g_APFromADItems;
	end
	
    local valueText, tooltipText = MYS_PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff);
    local valueNum = max(0, base + posBuff + negBuff);
    MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_ATTACK_POWER, valueText, false, valueNum);
	statFrame.tooltip = tooltipText;
    statFrame.tooltip2 = format(RANGED_ATTACK_POWER_TOOLTIP, valueNum/ATTACK_POWER_MAGIC_NUMBER);
    statFrame:Show();
end

-- SECONDARY STATS --
function MYS_PaperDollFrame_SetCritChance(statFrame, unit)
	
	statFrame:SetScript("OnEnter", MYS_CharacterMeleeCritFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
    end)
	
	local critChance = GetCritChance();

    MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, critChance, true, critChance);
	statFrame.criticalStrikeTxt = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.2F%%", critChance);
    statFrame:Show();
end

function MYS_PaperDollFrame_SetRangedCritChance(statFrame, unit)

	if not IsRangedWeapon() then
		MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, NOT_APPLICABLE, false, 0);
		statFrame:Show();
		return;
	end

	local critChance = GetRangedCritChance();

    MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, critChance, true, critChance);
	statFrame.tooltip = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.2F%%", critChance);
    statFrame:Show();
end
function MYS_CalcMaxSpellCrit()
	local MAX_SPELL_SCHOOLS = 7;
	local holySchool = 2;

	-- Start at 2 to skip physical damage
	local maxSpellCrit = GetSpellCritChance(holySchool);
	for i=holySchool, MAX_SPELL_SCHOOLS do
		local bonusCrit = GetSpellCritChance(i);
		maxSpellCrit = max(maxSpellCrit, bonusCrit);
	end
	return maxSpellCrit;
end
function MYS_PaperDollFrame_SetSpellCritChance(statFrame, unit)

	statFrame:SetScript("OnEnter", MYS_CharacterSpellCritFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
    end)
	
	local maxSpellCrit=MYS_CalcMaxSpellCrit()

	statFrame.holyCrit = GetSpellCritChance(2);
	statFrame.fireCrit = GetSpellCritChance(3);
	statFrame.natureCrit = GetSpellCritChance(4);
	statFrame.frostCrit = GetSpellCritChance(5);
	statFrame.shadowCrit = GetSpellCritChance(6);
	statFrame.arcaneCrit = GetSpellCritChance(7);

	local unitClassId = select(3, UnitClass(unit));
	if (unitClassId == MYS_MAGE_CLASS_ID) then
		local arcaneInstabilityCrit, criticalMassCrit = MYS_GetMageCritStatsFromTalents();
		if (arcaneInstabilityCrit > 0) then
			-- increases the crit of all spell schools
			statFrame.holyCrit = statFrame.holyCrit + arcaneInstabilityCrit;
			statFrame.fireCrit = statFrame.fireCrit + arcaneInstabilityCrit;
			statFrame.natureCrit = statFrame.natureCrit + arcaneInstabilityCrit;
			statFrame.frostCrit = statFrame.frostCrit + arcaneInstabilityCrit;
			statFrame.shadowCrit = statFrame.shadowCrit + arcaneInstabilityCrit;
			statFrame.arcaneCrit = statFrame.arcaneCrit + arcaneInstabilityCrit;
			-- set the new maximum
			maxSpellCrit = maxSpellCrit + arcaneInstabilityCrit;
		end
		if (criticalMassCrit > 0) then
			statFrame.fireCrit = statFrame.fireCrit + criticalMassCrit;
			-- set the new maximum
			maxSpellCrit = max(maxSpellCrit, statFrame.fireCrit);
		end
	elseif (unitClassId == MYS_PRIEST_CLASS_ID) then
		local priestHolyCrit = MYS_GetPriestCritStatsFromTalents();
		priestHolyCrit = priestHolyCrit + MYS_GetHolyCritFromBenediction(unit);
		
		if (priestHolyCrit > 0) then
			statFrame.holyCrit = statFrame.holyCrit + priestHolyCrit;
			-- set the new maximum
			maxSpellCrit = max(maxSpellCrit, statFrame.holyCrit);
		end
	elseif (unitClassId == MYS_WARLOCK_CLASS_ID) then
		local destructionCrit = MYS_GetWarlockCritStatsFromTalents();
		if (destructionCrit > 0) then
			statFrame.shadowCrit = statFrame.shadowCrit + destructionCrit;
			statFrame.fireCrit = statFrame.fireCrit + destructionCrit;
			local tmpMax = max(statFrame.shadowCrit, statFrame.fireCrit);
			-- set the new maximum
			maxSpellCrit = max(maxSpellCrit, tmpMax);
		end
	elseif (unitClassId == MYS_SHAMAN_CLASS_ID) then
		statFrame.lightningCrit = statFrame.natureCrit;
		
		local callOfThunderCrit = MYS_GetShamanCallOfThunderCrit();
		if callOfThunderCrit > 0 then
			statFrame.lightningCrit = statFrame.lightningCrit + callOfThunderCrit;
		end

		local tidalMastery = MYS_GetShamanTidalMasteryCrit();
		if tidalMastery > 0 then
			statFrame.lightningCrit = statFrame.lightningCrit + tidalMastery;
			statFrame.natureCrit = statFrame.natureCrit + tidalMastery;
		end

		local tmpMax = max(statFrame.lightningCrit, statFrame.natureCrit);
		-- set the new maximum
		maxSpellCrit = max(maxSpellCrit, tmpMax);
	end
	statFrame.unitClassId = unitClassId;

	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, maxSpellCrit, true, maxSpellCrit);

    statFrame:Show();
end

function MYS_PaperDollFrame_SetHitChance(statFrame, unit)
	
	statFrame:SetScript("OnEnter", MYS_CharacterHitChanceFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	local hitChance = GetHitModifier();
	
	if not hitChance then
		hitChance = 0;
	end

	local hitChanceText = hitChance;
	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_HIT_CHANCE, hitChanceText, true, hitChance);
	statFrame.hitChance = hitChance;
	statFrame:Show();
end
function MYS_PaperDollFrame_SetExperties(statFrame,unit)
	statFrame:SetScript("OnEnter", MYS_CharacterSpellExpertiseChanceFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	local expertise = MYS_GetGearStats(MYS_EXPERTISE);
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "精准", 1, true, expertise);
	statFrame.expertise=expertise
	statFrame:Show();
end
local function MYS_GetHitFromBiznicksAccurascope(unit)
	MYS_ScanTooltip:ClearLines();

	local hitFromScope = 0;
	local rangedIndex = 18;

	local itemLink = GetInventoryItemLink(unit, rangedIndex);
	if itemLink then
		local itemId, enchantId = itemLink:match("item:(%d+):(%d*)");
		if enchantId then
			if tonumber(enchantId) == 2523 then
				hitFromScope = 3;
			end
		end
	end

	return hitFromScope;
end

function MYS_PaperDollFrame_SetRangedHitChance(statFrame, unit)
	
	if not IsRangedWeapon() then
		MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_HIT_CHANCE, NOT_APPLICABLE, false, 0);
		statFrame:Show();
		return;
	end

	statFrame:SetScript("OnEnter", MYS_CharacterRangedHitChanceFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	local hitChance = GetHitModifier();
	
	if not hitChance then
		hitChance = 0;
	end

	local hitFromScope = MYS_GetHitFromBiznicksAccurascope(unit);
	if (hitFromScope > 0) then
		hitChance = hitChance + hitFromScope;
	end

	local hitChanceText = hitChance;
	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_HIT_CHANCE, hitChanceText, true, hitChance);
	statFrame.hitChance = hitChance;
	statFrame:Show();
end

function MYS_PaperDollFrame_SetSpellHitChance(statFrame, unit)
	
	statFrame:SetScript("OnEnter", MYS_CharacterSpellHitChanceFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local hitChance = GetSpellHitModifier();
	
	if not hitChance then
		hitChance = 0;
	end

	local unitClassId = select(3, UnitClass(unit));

	if unitClassId == MYS_MAGE_CLASS_ID then
		local arcaneHit, frostFireHit = MYS_GetMageSpellHitFromTalents();
		statFrame.arcaneHit = arcaneHit;
		statFrame.frostHit = frostFireHit;
		statFrame.fireHit = frostFireHit;
	elseif unitClassId == MYS_WARLOCK_CLASS_ID then
		statFrame.afflictionHit = MYS_GetWarlockSpellHitFromTalents();
	end

	local hitChanceText = hitChance;
	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_HIT_CHANCE, hitChanceText, true, hitChance);
	statFrame.hitChance = hitChance;
	statFrame.unitClassId = unitClassId;
	statFrame:Show();
end
function MYS_PaperDollFrame_SetSpellHaste(statFrame,unit)
	statFrame:SetScript("OnEnter", MYS_CharacterSpellHasteChanceFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	local unitClassId = select(3, UnitClass(unit))

	
	local _,_,_,castTime=GetSpellInfo(8690)
	local haste=10000/castTime;

	if unitClassId == MYS_MAGE_CLASS_ID then
	-- else if unitClassId ==MYS_WARRIOR_CLASS_ID then

	-- else if unitClassId ==MYS_PALADIN_CLASS_ID then

	-- else if unitClassId ==MYS_HUNTER_CLASS_ID then

	-- else if unitClassId ==MYS_ROGUE_CLASS_ID then

	-- else if unitClassId ==MYS_PRIEST_CLASS_ID then

	-- else if unitClassId ==MYS_SHAMAN_CLASS_ID then

	-- else if unitClassId ==MYS_WARLOCK_CLASS_ID then

	-- else if unitClassId ==MYS_DRUID_CLASS_ID then

	-- else

	end 
	local hastRate=haste*100
	statFrame.haste = haste;
	statFrame.hasteRate=hastRate;
	statFrame.hastePoint=MYS_GetGearStats(MYS_SPELLHASTE);
	statFrame.unitClassId = unitClassId;
	statFrame:Show();
	
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "急速", '1', true, hastRate-100);
end
function MYS_PaperDollFrame_SetAttackSpeed(statFrame, unit)

	statFrame:SetScript("OnEnter", MYS_CharacterAttackSpeedFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	local speed, offhandSpeed = UnitAttackSpeed(unit);
	local speedLabel = WEAPON_SPEED;

	local displaySpeed = format("%.2F", speed);
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2F", offhandSpeed);
	end
	if ( offhandSpeed ) then
		displaySpeed =  displaySpeed.." / ".. offhandSpeed;
	else
		displaySpeed =  displaySpeed;
	end
	MYS_PaperDollFrame_SetLabelAndText(statFrame, speedLabel, displaySpeed, false, speed);
	statFrame.tooltip = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed;
	statFrame:Show();
end

function MYS_PaperDollFrame_SetRangedAttackSpeed(statFrame, unit)
	
	if not IsRangedWeapon() then
		MYS_PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, NOT_APPLICABLE, false, 0);
		statFrame:Show();
		return;
	end

	local attackSpeed, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
	local displaySpeed = format("%.2F", attackSpeed);

	MYS_PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, attackSpeed);
	statFrame.tooltip = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed;
	statFrame:Show();
end
function MYS_PaperDollFrame_SetRangeHaste(statFrame, unit)
    local speed, haste, quiver
    local attackspeed = MYS_GetGearStats(MYS_ATTACKSPEED)
    local unitClassId = select(3, UnitClass("player"));
    if unitClassId == MYS_HUNTER_CLASS_ID then
        speed = MYS_GetWeaponSpeed("player", 18) or 2
        local realSpeed, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
        haste = ((speed / (realSpeed or speed)) -1)* 100
		if haste<0 then
			haste =0
		end
        quiver = MYS_GetRangeQuiverSpeed();
    else
        haste = 0
        quiver = 0
    end
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "攻速提高", "haste", true, haste, "%.0f%%");
    statFrame.tooltip = format("攻速提高（装备）: %d%%\n攻速提高（箭袋）: %d%%", attackspeed, quiver)

    statFrame:Show();
end

-- DEFENSES --
function MYS_PaperDollFrame_SetArmor(statFrame, unit)

	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit);
	--negBuff = 0; -- Remove for Classic

	if (unit ~= "player") then
		--[[ In 1.12.0, UnitArmor didn't report positive / negative buffs for units that weren't the active player.
			 This hack replicates that behavior for the UI. ]]
		base = effectiveArmor;
		armor = effectiveArmor;
		posBuff = 0;
		negBuff = 0;
	end

	local playerLevel = UnitLevel(unit);
	local armorReduction = effectiveArmor/((85 * playerLevel) + 400);
	armorReduction = 100 * (armorReduction/(armorReduction + 1));

	local valueText, tooltipText = MYS_PaperDollFormatStat(ARMOR, base, posBuff, negBuff);
	local valueNum = max(0, base + posBuff + negBuff);
	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_ARMOR, valueText, false, valueNum);
	statFrame.tooltip = tooltipText;
    statFrame.tooltip2 = format(ARMOR_TOOLTIP, playerLevel, armorReduction);
	statFrame:Show();
end

function MYS_PaperDollFrame_SetDefense(statFrame, unit)

	statFrame:SetScript("OnEnter", MYS_CharacterDefenseFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local  skillRank, skillModifier, playerLevel = MYS_GetDefense(unit);

	local posBuff = 0;
	local negBuff = 0;
	if ( skillModifier > 0 ) then
		posBuff = skillModifier;
	elseif ( skillModifier < 0 ) then
		negBuff = skillModifier;
	end
	local valueText, defenseText = MYS_PaperDollFormatStat(DEFENSE_COLON, skillRank, posBuff, negBuff);
	local valueNum = max(0, skillRank + posBuff + negBuff);
	MYS_PaperDollFrame_SetLabelAndText(statFrame, MYS_DEFENSE, valueText, false, valueNum);
	statFrame.defense = defenseText;
	statFrame:Show();
end

function MYS_PaperDollFrame_SetDodge(statFrame, unit)
	local chance = GetDodgeChance();
	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, chance, true, chance, "%.2F%%");
	statFrame.tooltip = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2F", chance).."%";
	--statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
	statFrame:Show();
end

function MYS_PaperDollFrame_SetParry(statFrame, unit)
	local chance = GetParryChance();
	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, chance, true, chance, "%.2F%%");
	statFrame.tooltip = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2F", chance).."%";
	--statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
	statFrame:Show();
end

_weaponSpeedCache=nil
function MYS_clearWeaponSpeedCache()
	_weaponSpeedCache=nil
end
function MYS_GetWeaponSpeed(unit,slotId)
	if _weaponSpeedCache and _weaponSpeedCache[slotId] then
		return _weaponSpeedCache[slotId]
	end 
	MYS_ScanTooltip:ClearLines();
	local hasItem = MYS_ScanTooltip:SetInventoryItem(unit, slotId);
	
	if hasItem then
			local itemId = GetInventoryItemID(unit, slotId);
			local maxLines = MYS_ScanTooltip:NumLines();
				for line=1, maxLines do
					local leftText = getglobal(MYS_ScanTooltipPrefix.."TextRight"..line);
					
					local text=leftText:GetText()
								
					if text and string.match(text,"速度 %d+.%d+") then
						local value=string.match(text,"%d+.%d+");
						local speed=tonumber(value)
						if not _weaponSpeedCache then
							_weaponSpeedCache={}
						end
						_weaponSpeedCache[slotId]=speed;
						return speed;
					end
					
				end
	end
end
function MYS_GetRangeQuiverSpeed()
	MYS_ScanTooltip:ClearLines();
	for slotId=31,34 do
		local hasItem = MYS_ScanTooltip:SetInventoryItem("player", slotId);
		if hasItem then
			local itemId = GetInventoryItemID("player", slotId);
			local maxLines = MYS_ScanTooltip:NumLines();
				for line=1, maxLines do
					local leftText = getglobal(MYS_ScanTooltipPrefix.."TextLeft"..line);
					local text=leftText:GetText()
					if text and string.match(text,ITEM_MOD_RANGED_ATTACKSPEED) then
						local value=tonumber(string.match(text,"%d+"))
						return value;
					end
					
				end
		end
	end
end
function MYS_ShowItemInfo(unit,slotId)
	MYS_ScanTooltip:ClearLines();
	local hasItem = MYS_ScanTooltip:SetInventoryItem(unit, slotId);
	if hasItem then
			local itemId = GetInventoryItemID(unit, slotId);
			local maxLines = MYS_ScanTooltip:NumLines();
				for line=1, maxLines do
					local leftText = getglobal(MYS_ScanTooltipPrefix.."TextLeft"..line);
					local rightText = getglobal(MYS_ScanTooltipPrefix.."TextRight"..line);
					local text=leftText:GetText()
					
					print(text,rightText:GetText())
					
				end
	end
end


function MYS_GetBlockValue(unit)
	MYS_ScanTooltip:ClearLines();

	local blockValueFromItems = 0;
	local firstItemslotIndex = 1;
	local lastItemslotIndex = 18;

	local blockValueIDs = { ITEM_MOD_BLOCK_RATING_SHORT, ITEM_MOD_BLOCK_RATING, ITEM_MOD_BLOCK_VALUE };
	local equippedMightSetItems = 0;

	for itemslot=firstItemslotIndex, lastItemslotIndex do
		local hasItem = MYS_ScanTooltip:SetInventoryItem(unit, itemslot);
		if hasItem then
			local itemId = GetInventoryItemID(unit, itemslot);
			if (itemId == g_BattlegearOfMightIds[itemId]) then
				equippedMightSetItems = equippedMightSetItems + 1;
			else
				local maxLines = MYS_ScanTooltip:NumLines();
				for line=1, maxLines do
					local leftText = getglobal(MYS_ScanTooltipPrefix.."TextLeft"..line);
					if leftText:GetText() then
						for blockValueID=1, 3 do
							local valueTxt = string.match(leftText:GetText(), "%d+ "..blockValueIDs[blockValueID]);
							if not valueTxt then
								valueTxt = string.match(leftText:GetText(), string.sub( blockValueIDs[blockValueID], 1, -5).." %d+");
							end
							if valueTxt then
								valueTxt = string.match(valueTxt, "%d+");
								if valueTxt then
									local numValue = tonumber(valueTxt);
									if numValue then
										blockValueFromItems = blockValueFromItems + numValue;
									end
								end
							end
						end
					end
				end
			end
		end
	end

	local strStatIndex = 1;
	local strength = select(2, UnitStat(unit, strStatIndex));
	local blockValue = blockValueFromItems + (strength / 20);
	
	local requiredMightSetItems = 3;
	if (equippedMightSetItems >= requiredMightSetItems) then
		blockValue = blockValue + 30; -- Set bonus reached
	end

	return blockValue;
end

function MYS_PaperDollFrame_SetBlock(statFrame, unit)

	statFrame:SetScript("OnEnter", MYS_CharacterBlock_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	local blockChance = GetBlockChance();
	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, blockChance, true, blockChance, "%.2F%%");

	statFrame.blockChance = string.format("%.2F", blockChance).."%";
	statFrame:Show();
end
function MYS_PaperDollFrame_SetBlockValue(statFrame, unit)

	
	
	local blockValue = GetShieldBlock();
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "格挡值", blockValue, false, blockValue, "%d");

	statFrame:Show();
end
function MYS_ClacUnhitted(unit)
	local  skillRank, skillModifier, playerLevel = MYS_GetDefense(unit or "player");
	return 5+(skillRank+skillModifier-315)*0.04
end

function MYS_PaperDollFrame_SetDefenceAvoid(statFrame, unit) 
	local defenceTable=MYS_GetDefenceTable()
	local sum=defenceTable.unhitted+defenceTable.parry+defenceTable.dodge;
	local format="%.2F%%"
	if sum>=10 then
		format="%.1F%%"
	end
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "物理规避", "", true, sum,format);
	statFrame.tooltip=string.format("面对63级boss时\n未被命中：%.2f%%\n躲闪       ：%.2f%%\n招架       ：%.2f%%\n共计       ：%.2f%%",defenceTable.unhitted,defenceTable.dodge,defenceTable.parry,sum)
	statFrame:Show();
end
function MYS_PaperDollFrame_SetDefenceBlock(statFrame, unit) 
	local defenceTable=MYS_GetDefenceTable()
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "格挡", "", true, defenceTable.blockChance,"%.2F%%");
	statFrame.tooltip=string.format("面对63级boss的格挡几率为%.2f%%\n格挡值：%d",defenceTable.blockChance,GetShieldBlock())
	statFrame:Show();
	
end
function MYS_PaperDollFrame_SetDefenceCrited(statFrame, unit) 
	local defenceTable=MYS_GetDefenceTable()
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "被暴击", "", true, defenceTable.critHitted,"%.2F%%");
	
	statFrame.tooltip=string.format("被63级boss暴击的几率为%.2f%%\n63级boss暴击基础值为6%%,防等每超过300一点 被暴击-0.04%%",defenceTable.critHitted);
	statFrame:Show();
end
function MYS_PaperDollFrame_SetDefenceCrushed(statFrame, unit) 
	local defenceTable=MYS_GetDefenceTable()
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "被碾压", "", true, defenceTable.crushed,"%.2F%%");
	statFrame.tooltip=string.format("被63级boss碾压几率为%.2f%%\n碾压固定为15%%几率，但可以被上面的几个挤出圆桌",defenceTable.crushed);
	statFrame:Show();
end
function MYS_PaperDollFrame_SetDefenceHitted(statFrame, unit) 
	local defenceTable=MYS_GetDefenceTable()
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "被命中", "", true, defenceTable.hitted,"%.2F%%");
	statFrame.tooltip=string.format("被63级boss普通攻击的几率为%.2f%%",defenceTable.hitted);
	statFrame:Show();
end
function MYS_PaperDollFrame_SetCombatMissHit(statFrame,unit,targetDefence) 
	
	local  skill = MYS_GetPlayerWeaponSkill(unit,16) or 300;
	
	local offhand,_=GetInventoryItemID(unit,17)
	local hitChance = GetHitModifier() or 0;
	if not targetDefence then
		targetDefence=315
	end
	if targetDefence-skill>10 and hitChance>0 then
		hitChance=hitChance-1
	end
	local dual=false
	if offhand then
		local type=select(6,GetItemInfo(offhand))
		if type =="武器" then
			dual=true
		end

	end
	local baseMiss=5;
	if targetDefence-skill>10 then
		baseMiss=baseMiss+1+(targetDefence-10-skill)*0.2
	elseif targetDefence-skill>=0 then
		baseMiss=baseMiss+(targetDefence-skill)*0.1
	elseif skill-targetDefence>10 then
		baseMiss=baseMiss-1-(skill-10-targetDefence)*0.2
	end

	if dual then
		baseMiss=baseMiss+19
		
	end
	local value=baseMiss-hitChance;

	if value <0 then
		value =0
	end
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "未命中", "", true, value,"%.2F%%");
	statFrame.tooltip=string.format("攻击63级boss未命中几率为%.2f%%",value);
	statFrame:Show();
	return value
end
function MYS_PaperDollFrame_SetCombatDodge(statFrame,unit,sum,targetDefence) 
	local  skill = MYS_GetPlayerWeaponSkill(unit,16) or 300;
	if not targetDefence then
		targetDefence=315
	end
	local expertise=MYS_GetGearStats(MYS_EXPERTISE)
	local baseDodge=5
	baseDodge=baseDodge+(targetDefence-skill)*0.1
	local value=baseDodge-expertise
	if value <0 then
		value =0
	end
	if value>100-sum then
		value=100-sum
	end
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "被闪躲", "", true, value,"%.2F%%");
	statFrame:Show();
	statFrame.tooltip=string.format("攻击63级boss被躲闪几率为%.2f%%",value);
	return sum+value
end
function MYS_PaperDollFrame_SetCombatParry(statFrame,unit,sum,targetDefence) 
	statFrame:SetScript("OnEnter", MYS_CharacterCombatParry_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	local  skill = MYS_GetPlayerWeaponSkill(unit,16) or 300;
	if not targetDefence then
		targetDefence=315
	end
	local expertise=MYS_GetGearStats(MYS_EXPERTISE)
	local baseParry=13.4
	baseParry=baseParry+(targetDefence-skill)*0.04
	local value=baseParry-expertise
	if value <0 then
		value =0
	end
	if value>100-sum then
		value=100-sum
	end
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "被招架", "0%", false, 0,"0");
	statFrame:Show();
	statFrame.parry=value;
	return sum,value
end
function MYS_PaperDollFrame_SetCombatGlancing(statFrame, unit,sum,p,targetDefence) 
	statFrame:SetScript("OnEnter", MYS_CharacterCombatGlancing_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	local  skill = MYS_GetPlayerWeaponSkill(unit,16) or 300;
	if not targetDefence then
		targetDefence=315
	end
	local v1=40;
	local v2=40
	
	if v1>100-sum then
		v1=100-sum
	end
	if v2>100-sum-p then
		v2=100-sum-p
	end
	statFrame.v2=v2
	local delta=targetDefence-skill;
	if delta<=7 then
		statFrame.glancingA=91
		statFrame.glancingB=99
	else
		statFrame.glancingA=90-5*(delta-8)
		statFrame.glancingB=96-3*(delta-8)
	end
	
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "偏斜", format("%d%%",v1), false, 0,"%.2F%%");
	statFrame:Show();
	
	return sum+40;
end
function MYS_PaperDollFrame_SetCombatCrited(statFrame, unit,sum,p,targetDefence) 
	statFrame:SetScript("OnEnter", MYS_CharacterCombatCritical_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	local  skill = MYS_GetPlayerWeaponSkill(unit,16) or 300;
	if not targetDefence then
		targetDefence=315
	end
	local value=GetCritChance()
	value=value-(targetDefence-skill)*0.04
	if value <0 then
		value =0
	end
	local v1=value;
	local v2=value;
	if v1>100-sum then
		v1=100-sum
	end
	if v2>100-sum-p then
		v2=100-sum-p
	end
	if v1<0 then
		v1=0
	end
	if v2<0 then
		v2=0
	end
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "暴击", "", true, v1,"%.2F%%");
	statFrame.v2=v2
	statFrame:Show();
	return sum+value
end
function MYS_PaperDollFrame_SetCombatHit(statFrame, unit,sum,p,targetDefence) 
	statFrame:SetScript("OnEnter", MYS_CharacterCombatHit_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	local v1=100-sum
	local v2=100-sum-p
	if v1<0 then
		v1=0
	end
	if v2<0 then
		v2=0
	end
	MYS_PaperDollFrame_SetLabelAndText(statFrame, "命中", "", true, v1,"%.2F%%");
	statFrame.v2=v2;
	statFrame:Show();
	return 0
end
function MYS_CalcMaxSpellPower()
	local MAX_SPELL_SCHOOLS = 7;
	local holySchool = 2;

	-- Start at 2 to skip physical damage
	local maxSpellDmg = GetSpellBonusDamage(holySchool);
	for i=holySchool, MAX_SPELL_SCHOOLS do
		local bonusDamage = GetSpellBonusDamage(i);
		maxSpellDmg = max(maxSpellDmg, bonusDamage);
	end
	return maxSpellDmg
end
-- SPELL --
function MYS_PaperDollFrame_SetSpellPower(statFrame, unit)

	statFrame:SetScript("OnEnter", MYS_CharacterSpellDamageFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
    end)

	local MAX_SPELL_SCHOOLS = 7;
	local holySchool = 2;

	-- Start at 2 to skip physical damage
	local maxSpellDmg=MYS_CalcMaxSpellPower()

	if (UISettingsCharacter.showStatsFromArgentDawnItems) then
		local spFromAD = MYS_GetSpellkPowerFromArgentDawnItems(unit);
		maxSpellDmg = maxSpellDmg + spFromAD;
		statFrame.spVsUndead = maxSpellDmg;
	end

	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_SPELLPOWER, BreakUpLargeNumbers(maxSpellDmg), false, maxSpellDmg);
	statFrame:Show();
end

local function MYS_GetMP5FromAuras()
	local mp5FromAuras = 0;
	local mp5CombatModifier = 0;

	for i = 0, 40 do
		--local name = select(1, UnitAura("player", i, "HELPFUL", "PLAYER"));
		local spellId = select(10, UnitAura("player", i, "HELPFUL", "PLAYER"));
		if spellId then
			if g_AuraIdToMp5[spellId] then
				local auraMp5 = g_AuraIdToMp5[spellId];
				
				local unitClassId = select(3, UnitClass("player"));
				if (unitClassId == MYS_PALADIN_CLASS_ID and MYS_IsBoWSpellId(spellId)) then
					local improvedBoWModifier = MYS_GetPaladinImprovedBoWModifier();
					
					if (improvedBoWModifier > 0) then
						auraMp5 = auraMp5 + auraMp5 * improvedBoWModifier;
					end
				end

				mp5FromAuras = mp5FromAuras + auraMp5;
			elseif g_CombatManaRegenSpellIdToModifier[spellId] then
				mp5CombatModifier = mp5CombatModifier + g_CombatManaRegenSpellIdToModifier[spellId];
			end

		end
	end

	return mp5FromAuras, mp5CombatModifier;
end

function MYS_PaperDollFrame_SetManaRegen(statFrame, unit)

	if ( not UnitHasMana(unit) ) then
		MYS_PaperDollFrame_SetLabelAndText(statFrame, MANA_REGEN, NOT_APPLICABLE, false, 0);
		statFrame.tooltip = nil;
		statFrame:Show();
		return;
	end

	statFrame:SetScript("OnEnter", MYS_CharacterManaRegenFrame_OnEnter)
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
    end)

	-- There is a bug in GetManaRegen() so I have to manually calculate mp5
	-- base == casting always and this is wrong
	local base, casting = GetManaRegen();
	
	-- to avoid the wrongly reported "0" regen after an update
	if base < 1 then base = g_lastSeenBaseManaRegen end
	if casting < 1 then casting = g_lastSeenBaseManaRegen end
	g_lastSeenBaseManaRegen = base;
	g_lastSeenCastingManaRegen = casting;

	local mp5FromGear = MYS_GetMP5FromGear(unit);
	local mp5ModifierCasting = MYS_GetMP5ModifierFromTalents(unit);
	mp5ModifierCasting = mp5ModifierCasting + MYS_GetMP5ModifierFromSetBonus(unit);

	local mp5FromAuras, mp5CombatModifier = MYS_GetMP5FromAuras();
	if mp5CombatModifier > 0 then
		mp5ModifierCasting = mp5ModifierCasting + mp5CombatModifier;
	end
	
	-- All mana regen stats are displayed as mana/5 sec.
	local regenWhenNotCasting = (base * 5.0) + mp5FromGear + mp5FromAuras;
	casting = mp5FromGear + mp5FromAuras; -- if GetManaRegen() gets fixed ever, this should be changed

	if mp5ModifierCasting > 0 then
		casting = casting + base * mp5ModifierCasting * 5.0;
	end

	local regenWhenNotCastingText = BreakUpLargeNumbers(regenWhenNotCasting);
	local castingText = BreakUpLargeNumbers(casting);
	-- While Casting mana regen is most important to the player, so we display it as the main value
	MYS_PaperDollFrame_SetLabelAndText(statFrame, MANA_REGEN, castingText, false, casting);
	statFrame.mp5FromGear = BreakUpLargeNumbers(mp5FromGear);
	statFrame.mp5Casting = castingText;
	statFrame.mp5NotCasting = regenWhenNotCastingText;
	statFrame:Show();
end

function MYS_PaperDollFrame_SetHealing(statFrame, unit)
	local unitClassId = select(3, UnitClass(unit));
	local healing = GetSpellBonusHealing();

	local healingText = healing;
	MYS_PaperDollFrame_SetLabelAndText(statFrame, STAT_SPELLHEALING, healingText, false, healing);
	statFrame.tooltip = STAT_SPELLHEALING.." "..healing;
	statFrame.tooltip2 = STAT_SPELLHEALING_TOOLTIP;
	statFrame:Show();
end
