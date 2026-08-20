-- Class ids
MYS_WARRIOR_CLASS_ID 		= 1;
MYS_PALADIN_CLASS_ID 		= 2;
MYS_HUNTER_CLASS_ID 		= 3;
MYS_ROGUE_CLASS_ID 			= 4;
MYS_PRIEST_CLASS_ID 		= 5;
MYS_DEATHKNIGHT_CLASS_ID 	= 6;
MYS_SHAMAN_CLASS_ID 		= 7;
MYS_MAGE_CLASS_ID 			= 8;
MYS_WARLOCK_CLASS_ID 		= 9;
MYS_MONK_CLASS_ID 			= 10;
MYS_DRUID_CLASS_ID 			= 11;
MYS_DEMONHUNTER_CLASS_ID 	= 12;

-- Weapon subclass names. Classic Era does not provide the LE_ITEM_WEAPON_*
-- enumerations, so each key falls back to the standard numeric subclass id.
g_WeaponStringByWeaponId = {
	[LE_ITEM_WEAPON_AXE1H or 0] 		= MYS_WEAPON_AXE1H_TXT,
	[LE_ITEM_WEAPON_AXE2H or 1] 		= MYS_WEAPON_AXE2H_TXT,
	[LE_ITEM_WEAPON_MACE1H or 4] 	= MYS_WEAPON_MACE1H_TXT,
	[LE_ITEM_WEAPON_MACE2H or 5] 	= MYS_WEAPON_MACE2H_TXT,
	[LE_ITEM_WEAPON_POLEARM or 6] 	= MYS_WEAPON_POLEARM_TXT,
	[LE_ITEM_WEAPON_SWORD1H or 7] 	= MYS_WEAPON_SWORD1H_TXT,
	[LE_ITEM_WEAPON_SWORD2H or 8] 	= MYS_WEAPON_SWORD2H_TXT,
	[LE_ITEM_WEAPON_STAFF or 9] 		= MYS_WEAPON_STAFF_TXT,
    [LE_ITEM_WEAPON_UNARMED or 10] 	= MYS_WEAPON_UNARMED_TXT,
    [LE_ITEM_WEAPON_DAGGER or 13] 	= MYS_WEAPON_DAGGER_TXT,
    [LE_ITEM_WEAPON_BOWS or LE_ITEM_WEAPON_BOW or 2]       = MYS_WEAPON_BOW_TXT,
    [LE_ITEM_WEAPON_CROSSBOW or 15] 	= MYS_WEAPON_CROSSBOW_TXT,
    [LE_ITEM_WEAPON_GUNS or LE_ITEM_WEAPON_GUN or 3]       = MYS_WEAPON_GUN_TXT
};

-- Class set items IDs
g_BattlegearOfMightIds = { 
    [16861] = 16861, 
    [16862] = 16862, 
    [16863] = 16863, 
    [16864] = 16864, 
    [16865] = 16865, 
    [16866] = 16866, 
    [16867] = 16867, 
    [16868] = 16868
};

g_VestmentsOfTranscendenceIds = {
    [16925] = 16925, 
    [16926] = 16926, 
    [16919] = 16919, 
    [16921] = 16921, 
    [16920] = 16920, 
    [16922] = 16922, 
    [16924] = 16924, 
    [16923] = 16923,
};

g_StormrageRaimentIds = {
    [16897] = 16897, 
    [16898] = 16898, 
    [16899] = 16899, 
    [16900] = 16900, 
    [16901] = 16901, 
    [16902] = 16902, 
    [16903] = 16903, 
    [16904] = 16904,
};

g_TheTenStormsIds = {
    [16943] = 16943, 
    [16944] = 16944, 
    [16945] = 16945, 
    [16946] = 16946, 
    [16947] = 16947, 
    [16948] = 16948, 
    [16949] = 16949, 
    [16950] = 16950
};

g_AuraIdToMp5 = {
	-- BOW
	[19742] = 10,
	[19850] = 15,
	[19852] = 20,
	[19853] = 25,
	[19854] = 30,
	[25290] = 33,
	-- GBOW
	[25894] = 30,
	[25918] = 33,
	-- Mana Spring Totem
	[5675] = 10,
	[10495] = 15,
	[10496] = 20,
	[10497] = 25,
	-- Mageblood potion
	[24363] = 12,
	--Nightfin Soup
	[18194] = 8
};
  
g_CombatManaRegenSpellIdToModifier = {
    -- Mage Armor
    [6117] = 0.3,
    [22782] = 0.3,
    [22783] = 0.3
};

g_ArgentDawnAPItems = {
    -- Chests
    [23087] = 81, -- Plate
    [23088] = 81, -- Mail
    [23089] = 81, -- Leather
    -- Gloves
    [23078] = 60, -- Plate
    [23082] = 60, -- Mail
    [23081] = 60, -- Leather
    -- Bracers
    [23090] = 45, -- Plate
    [23092] = 45, -- Mail
    [23093] = 45, -- Leather
    -- Trinkets
    [13209] = 81, -- Seal of the Dawn
    [23206] = 150 -- Mark of the Champion AP
}

g_ArgentDawnSPItems = {
    -- SP cloth set
    [23085] = 48, -- Chest
    [23091] = 26, -- Bracers
    [23084] = 35, -- Gloves
    -- Trinkets
    [19812] = 48, -- Rune of the Dawn 
    [23207] = 85 -- Mark of the Champion SP
}

MYS_SYMBOL_TAB   = "    "; -- for some reason "\t" doesn't work
MYS_SYMBOL_SPACE = " ";
                                