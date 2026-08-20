-- OnEnter Tooltip functions
function MYS_CharacterDamageFrame_OnEnter(self)
	-- Main hand weapon
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.TooltipMainTxt, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2F", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_COLON, self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1F", self.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(ATTACK_TOOLTIP..":", self.attackRating, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	-- Check for offhand weapon
	if ( self.offhandAttackSpeed ) then
		GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
		GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2F", self.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(DAMAGE_COLON, self.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1F", self.offhandDps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	GameTooltip:Show();
end

function MYS_CharacterSpellDamageFrame_OnEnter(self)
	
	self.holyDmg = GetSpellBonusDamage(2);
	self.fireDmg = GetSpellBonusDamage(3);
	self.natureDmg = GetSpellBonusDamage(4);
	self.frostDmg = GetSpellBonusDamage(5);
	self.shadowDmg = GetSpellBonusDamage(6);
	self.arcaneDmg = GetSpellBonusDamage(7);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(STAT_SPELLPOWER, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(STAT_SPELLPOWER_TOOLTIP);
	GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
	GameTooltip:AddDoubleLine(SPELL_SCHOOL1_CAP.." "..DAMAGE..": ", format("%.2F", self.holyDmg), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL2_CAP.." "..DAMAGE..": ", format("%.2F", self.fireDmg), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL4_CAP.." "..DAMAGE..": ", format("%.2F", self.frostDmg), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL6_CAP.." "..DAMAGE..": ", format("%.2F", self.arcaneDmg), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL5_CAP.." "..DAMAGE..": ", format("%.2F", self.shadowDmg), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL3_CAP.." "..DAMAGE..": ", format("%.2F", self.natureDmg), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	if (self.spVsUndead ~= nil and UISettingsCharacter.showStatsFromArgentDawnItems) then
		GameTooltip:AddDoubleLine(DAMAGE.." vs Undead: ", format("%.2F", self.spVsUndead), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	GameTooltip:Show();
end

function MYS_CharacterSpellCritFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(STAT_CRITICAL_STRIKE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
	GameTooltip:AddDoubleLine(SPELL_SCHOOL1_CAP.." "..CRIT_ABBR..": ", format("%.2F", self.holyCrit).."%", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL2_CAP.." "..CRIT_ABBR..": ", format("%.2F", self.fireCrit).."%", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL4_CAP.." "..CRIT_ABBR..": ", format("%.2F", self.frostCrit).."%", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL6_CAP.." "..CRIT_ABBR..": ", format("%.2F", self.arcaneCrit).."%", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL5_CAP.." "..CRIT_ABBR..": ", format("%.2F", self.shadowCrit).."%", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(SPELL_SCHOOL3_CAP.." "..CRIT_ABBR..": ", format("%.2F", self.natureCrit).."%", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	if self.unitClassId == MYS_SHAMAN_CLASS_ID then
		GameTooltip:AddDoubleLine(MYS_LIGHTNING_TXT.." "..CRIT_ABBR..": ", format("%.2F", self.lightningCrit).."%", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end

	GameTooltip:Show();
end

function MYS_CharacterManaRegenFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(MANA_REGEN_TOOLTIP, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(MANA_REGEN.." (From Gear):", self.mp5FromGear);
	GameTooltip:AddDoubleLine(MANA_REGEN.." (While Casting):", self.mp5Casting);
	GameTooltip:AddDoubleLine(MANA_REGEN.." (While Not Casting):", self.mp5NotCasting);
	GameTooltip:Show();
end

function MYS_CharacterBlock_OnEnter(self)
	
	if true then
		self.blockValue = GetShieldBlock();
	else
		self.blockValue = MYS_GetBlockValue("player");
		
		local unitClassId = select(3, UnitClass("player"));
		if (unitClassId == MYS_WARRIOR_CLASS_ID) then
			local blockFromZGEnchants = MYS_GetBlockValueFromWarriorZGEnchants("player");
			if (blockFromZGEnchants > 0) then
				self.blockValue = self.blockValue + blockFromZGEnchants;
			end
		end
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(" ", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(BLOCK_CHANCE..": ", self.blockChance);
	GameTooltip:AddDoubleLine(ITEM_MOD_BLOCK_VALUE_SHORT..": ", self.blockValue);
	GameTooltip:Show();
end

function MYS_CharacterHitChanceFrame_OnEnter(self)
	local hitChance = self.hitChance;

	local totalWeaponSkill = MYS_GetPlayerWeaponSkill("player", INVSLOT_MAINHAND);
	local missChanceVsNPC, missChanceVsBoss, missChanceVsPlayer, dwMissChanceVsNpc, dwMissChanceVsBoss, dwMissChanceVsPlayer = MYS_GetPlayerMissChances("player", hitChance, totalWeaponSkill);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(STAT_HIT_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine("Reduces your chance to miss.");

	GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
	GameTooltip:AddLine("Miss Chance vs.");
	GameTooltip:AddDoubleLine(format(MYS_SYMBOL_TAB.."Level 60 NPC: %.2F%%", missChanceVsNPC), format("(Dual wield: %.2F%%)", dwMissChanceVsNpc));
	GameTooltip:AddDoubleLine(format(MYS_SYMBOL_TAB.."Level 60 Player: %.2F%%", missChanceVsPlayer), format("(Dual wield: %.2F%%)", dwMissChanceVsPlayer));
	GameTooltip:AddDoubleLine(format(MYS_SYMBOL_TAB.."Level 63 NPC/Boss: %.2F%%", missChanceVsBoss), format("(Dual wield: %.2F%%)", dwMissChanceVsBoss));
	GameTooltip:Show();
end

function MYS_CharacterRangedHitChanceFrame_OnEnter(self)
	local hitChance = self.hitChance;

	local totalWeaponSkill = MYS_GetPlayerWeaponSkill("player", INVSLOT_RANGED);
	local missChanceVsNPC, missChanceVsBoss, missChanceVsPlayer, _, _, _ = MYS_GetPlayerMissChances("player", hitChance, totalWeaponSkill);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(STAT_HIT_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine("Reduces your chance to miss.");

	GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
	GameTooltip:AddLine("Miss Chance vs.");
	GameTooltip:AddLine(format(MYS_SYMBOL_TAB.."Level 60 NPC: %.2F%%", missChanceVsNPC));
	GameTooltip:AddLine(format(MYS_SYMBOL_TAB.."Level 60 Player: %.2F%%", missChanceVsPlayer));
	GameTooltip:AddLine(format(MYS_SYMBOL_TAB.."Level 63 NPC/Boss: %.2F%%", missChanceVsBoss));
	GameTooltip:Show();
end

function MYS_CharacterSpellHasteChanceFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	
	GameTooltip:SetText(format(MYS_SPELL_HASTE_TOOLTIP_TXT, self.hastePoint,self.hasteRate-100 ), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	
	GameTooltip:AddLine(MYS_SYMBOL_SPACE);

	GameTooltip:AddLine("法术急速对施法时间影响的计算公式为：");
	GameTooltip:AddLine(MYS_SYMBOL_TAB.."施法时间÷(1+急速值%)");
	
	GameTooltip:AddLine(MYS_SYMBOL_SPACE);
	GameTooltip:AddLine("以1.5s施法时间的技能为例:");
	GameTooltip:AddLine(MYS_SYMBOL_TAB..format("你当前施法加速为:%.2F%%",self.hasteRate));
	GameTooltip:AddLine(MYS_SYMBOL_TAB..format("实际施法时间=1.5÷%.3F=%.2F",self.haste,1.5/self.haste));
	GameTooltip:Show();
end
function MYS_CharacterSpellExpertiseChanceFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	
	GameTooltip:SetText(format("精准（装备）: %d%%", self.expertise), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	
	GameTooltip:AddLine(MYS_SYMBOL_SPACE);
	local skill=(MYS_GetPlayerWeaponSkill("player",INVSLOT_MAINHAND) or 300)-300
	local parry=14-skill*0.04-self.expertise;
	local dogde=6.5-skill*0.1-self.expertise;
	if parry<0 then
		parry=0
	end
	if dogde<0 then
		dogde=0
	end
	GameTooltip:AddLine("面对63级Boss：");
	       GameTooltip:AddLine("              打脸"..MYS_SYMBOL_TAB.." 打背");
	
	GameTooltip:AddLine(format("被招架： %.1f%%"..MYS_SYMBOL_TAB.."  %.1f%%",parry,0));
	GameTooltip:AddLine(format("被闪躲： %.1f%%"..MYS_SYMBOL_TAB.."  %.1f%%",dogde,dogde));
	GameTooltip:Show();
end
function MYS_CharacterSpellHitChanceFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(format(MYS_SPELL_HIT_TOOLTIP_TXT, self.hitChance), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	if self.unitClassId == MYS_MAGE_CLASS_ID then
		GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
		GameTooltip:AddLine(MYS_SPELL_HIT_SUBTOOLTIP_TXT);
		GameTooltip:AddDoubleLine(MYS_SYMBOL_TAB..MYS_ARCANE_SPELL_HIT_TXT, (self.arcaneHit + self.hitChance).."%");
		GameTooltip:AddDoubleLine(MYS_SYMBOL_TAB..MYS_FIRE_SPELL_HIT_TXT, (self.fireHit + self.hitChance).."%");
		GameTooltip:AddDoubleLine(MYS_SYMBOL_TAB..MYS_FROST_SPELL_HIT_TXT, (self.frostHit + self.hitChance).."%");
	elseif self.unitClassId == MYS_WARLOCK_CLASS_ID then
		GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
		GameTooltip:AddLine(MYS_SPELL_HIT_SUBTOOLTIP_TXT);
		GameTooltip:AddDoubleLine(MYS_SYMBOL_TAB..MYS_DESTRUCTION_SPELL_HIT_TXT, self.hitChance.."%");
		GameTooltip:AddDoubleLine(MYS_SYMBOL_TAB..MYS_AFFLICTION_SPELL_HIT_TXT, (self.afflictionHit + self.hitChance).."%");
	elseif self.unitClassId == MYS_SHAMAN_CLASS_ID then
		GameTooltip:SetText(format(MYS_SPELL_HIT_TOOLTIP_2_TXT, self.hitChance), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	elseif self.unitClassId == MYS_PALADIN_CLASS_ID then
		local holyHit=MYS_GearStats[MYS_HOLYHIT] or 0
		GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
		GameTooltip:AddLine(format("神圣法术命中：%d%%",holyHit));
	end
	GameTooltip:Show();
end
function MYS_CharacterCombatParry_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(format("处于Boss正前时：%.2f%%几率被招架",self.parry), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:Show();
end
function MYS_CharacterAttackSpeedFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local speed=MYS_GetWeaponSpeed("player",16) or 2
	local realSpeed,offSpeed=UnitAttackSpeed("player");
	local haste=(speed/(realSpeed or speed)-1)*100

	GameTooltip:SetText(format(MYS_ATTACK_SPEED_TOOLTIP_TXT, MYS_GetGearStats(MYS_ATTACKSPEED),haste), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine(MYS_SYMBOL_SPACE);
	GameTooltip:AddLine(string.format("您的主手武器攻速为:%.1f",speed));
	GameTooltip:AddLine(string.format("实际攻速为 %.1f ÷ %.3f = %.2f",speed,haste/100+1,realSpeed));
	
	GameTooltip:AddLine(MYS_SYMBOL_SPACE);

	
	GameTooltip:Show();
end
function MYS_CharacterCombatGlancing_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(format("处于Boss正前时：%.2f%%几率偏斜",self.v2), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
	GameTooltip:AddLine(format("偏斜伤害：%d%% - %d%% 平均%d%%",self.glancingA,self.glancingB,(self.glancingA+self.glancingB)/2)); -- Blank line.
	GameTooltip:Show();
end
function MYS_CharacterCombatCritical_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(format("处于Boss正前时：%.2f%%几率暴击",self.v2), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:Show();
end
function MYS_CharacterCombatHit_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(format("处于Boss正前时：%.2f%%几率命中",self.v2), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:Show();
end
function MYS_CharacterMeleeCritFrame_OnEnter(self)
	local hitChance = GetHitModifier();
	local totalWeaponSkill = MYS_GetPlayerWeaponSkill("player", INVSLOT_MAINHAND) or 300;
	local missChanceVsNPC, missChanceVsBoss, missChanceVsPlayer, dwMissChanceVsNpc, dwMissChanceVsBoss, dwMissChanceVsPlayer = MYS_GetPlayerMissChances("player", hitChance, totalWeaponSkill);

	-- no weapon equipped, not supported localization or something else went wrong
	if not totalWeaponSkill then totalWeaponSkill = 300 end

	local critSuppression = 4.8;
	local glancingChance = 40;

	local extraWeaponSkill = totalWeaponSkill - 300;
	local bossDefense = 315; -- level 63
	local skillBossDelta = bossDefense - totalWeaponSkill;
	local dodgeChance = 5 + (skillBossDelta * 0.1);	
	local critCap = 100 - missChanceVsBoss - dodgeChance - glancingChance + critSuppression + (extraWeaponSkill * 0.04);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.criticalStrikeTxt, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
	GameTooltip:AddLine("Crit cap vs.");
	
	local critChance = GetCritChance();
	local CRITCAP_COLOR_CODE = GREEN_FONT_COLOR_CODE;
	if critChance > critCap then CRITCAP_COLOR_CODE = ORANGE_FONT_COLOR_CODE end
	local critCapTxt = CRITCAP_COLOR_CODE..format("%.2F%%", critCap)..FONT_COLOR_CODE_CLOSE;

	local offhandItemId = GetInventoryItemID("player", INVSLOT_OFFHAND);
	if offhandItemId then
		local critCapDw = 100 - dwMissChanceVsBoss - dodgeChance - glancingChance + critSuppression + (extraWeaponSkill * 0.04);
		
		local DWCRITCAP_COLOR_CODE = GREEN_FONT_COLOR_CODE;
		if critChance > critCapDw then DWCRITCAP_COLOR_CODE = ORANGE_FONT_COLOR_CODE end

		local critCapDwTxt = DWCRITCAP_COLOR_CODE..format("%.2F%%", critCapDw)..FONT_COLOR_CODE_CLOSE;
		GameTooltip:AddDoubleLine(MYS_SYMBOL_TAB.."Level 63 NPC/Boss: "..critCapTxt, "(Dual wield: "..critCapDwTxt..")");
	else
		GameTooltip:AddDoubleLine(MYS_SYMBOL_TAB.."Level 63 NPC/Boss: "..critCapTxt);
	end

	GameTooltip:Show();
end

function MYS_CharacterDefenseFrame_OnEnter(self)
	local defenseValue, defenseModifier, playerLevel = MYS_GetDefense("player");
	local npcWeaponskill = playerLevel*5; -- same level as player
	local bossWeaponskill = 315; -- level 63

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(MYS_DEFENSE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine("Increases chance to Dodge, Block and Parry.\nDecreases chance to be hit and critically hit.");
	GameTooltip:AddLine(MYS_SYMBOL_SPACE); -- Blank line.
	GameTooltip:AddLine("Effect vs.");
	GameTooltip:AddLine(format(MYS_SYMBOL_TAB.."Level "..playerLevel.." NPC: %.2F%%", math.max(0, defenseValue+defenseModifier-npcWeaponskill)*0.04));
	GameTooltip:AddLine(format(MYS_SYMBOL_TAB.."Level 63 NPC/Boss: %.2F%%", math.max(0, defenseValue+defenseModifier-bossWeaponskill)*0.04));
	GameTooltip:Show();
end
-- OnEnter Tooltip functions END
