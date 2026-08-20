-- Namespaces
-- core - table (namespace) shared between every lua file
local addonName, core = ...;
local category, layout
core.UIConfig = {};
-- Defaults
UISettingsGlobal = {
    useBlizzardBlockValue = false,
    useTransparentStatsBackground = true,
    statsPanelHidden = false
}

UISettingsCharacter = {
    selectedLeftStatsCategory = 1,
    selectedRightStatsCategory = 2,
    showStatsFromArgentDawnItems = true
}
PLAYERSTAT_COMBAT_TABLE = "攻击圆桌"
PLAYERSTAT_DEFENCE_TABLE = "防御圆桌"
-- for easier referencing the core config
local UIConfig = core.UIConfig;
local MYS_UIFrame = core.UIConfig;
local MYS_ConfigFrame = {};

local statsDropdownList = {PLAYERSTAT_BASE_STATS, PLAYERSTAT_MELEE_COMBAT, PLAYERSTAT_RANGED_COMBAT,
                           PLAYERSTAT_SPELL_COMBAT, PLAYERSTAT_DEFENSES, PLAYERSTAT_COMBAT_TABLE,
                           PLAYERSTAT_DEFENCE_TABLE}

local NUM_STATS_TO_SHOW = 6;
local LeftStatsTable = {}
local RightStatsTable = {}

local function MYS_ResetStatFrames(statFrames)

    local statFrameDefaultAlpha = 0.3;
    if UISettingsGlobal.useTransparentStatsBackground then
        statFrameDefaultAlpha = 0;
    end

    for i = 1, NUM_STATS_TO_SHOW, 1 do
        if statFrames[i] then
            statFrames[i]:Hide();
            statFrames[i]:SetScript("OnEnter", statFrames[i].OnEnterCallback);
            statFrames[i].tooltip = nil;
            statFrames[i].tooltip2 = nil;
            statFrames[i].tooltip3 = nil;
            statFrames[i].Background:SetAlpha(statFrameDefaultAlpha);
        end 
    end
end

function UIConfig:InitializeStatsFrames(leftParentFrame, rightParentFrame)
    local offsetStepY = 15;
    local accumulatedOffsetY = 0;

    for i = 1, NUM_STATS_TO_SHOW do
        accumulatedOffsetY = accumulatedOffsetY + offsetStepY;
        local actualOffset = accumulatedOffsetY;

        if i == 1 then
            actualOffset = 32;
            accumulatedOffsetY = 32;
        end

        LeftStatsTable[i] = CreateFrame("Frame", nil, leftParentFrame, "CharacterStatFrameTemplate");
        LeftStatsTable[i]:SetPoint("LEFT", leftParentFrame, "TOPLEFT", 10, -actualOffset);
        LeftStatsTable[i]:SetWidth(130);
        LeftStatsTable[i].OnEnterCallback = LeftStatsTable[i]:GetScript("OnEnter");

        RightStatsTable[i] = CreateFrame("Frame", nil, rightParentFrame, "CharacterStatFrameTemplate");
        RightStatsTable[i]:SetPoint("LEFT", rightParentFrame, "TOPLEFT", 10, -actualOffset);
        RightStatsTable[i]:SetWidth(130);
        RightStatsTable[i].OnEnterCallback = RightStatsTable[i]:GetScript("OnEnter");
    end
end

function UIConfig:SetCharacterStats(statsTable, category)

    MYS_ResetStatFrames(statsTable);

    if category == PLAYERSTAT_BASE_STATS then
        -- str, agility, stamina, intelect, spirit
        MYS_PaperDollFrame_SetPrimaryStats(statsTable, "player");
    elseif category == PLAYERSTAT_DEFENSES then
        -- armor, defense, dodge, parry, block
        MYS_PaperDollFrame_SetArmor(statsTable[1], "player");
        MYS_PaperDollFrame_SetDefense(statsTable[2], "player");
        MYS_PaperDollFrame_SetDodge(statsTable[3], "player");
        MYS_PaperDollFrame_SetParry(statsTable[4], "player");
        MYS_PaperDollFrame_SetBlock(statsTable[5], "player");
        MYS_PaperDollFrame_SetBlockValue(statsTable[6], "player");
    elseif category == PLAYERSTAT_MELEE_COMBAT then
        if (UISettingsCharacter.showStatsFromArgentDawnItems) then
            MYS_CacheAPFromADItems("player");
        end
        -- damage, Att Power, speed, hit raiting, crit chance
        MYS_PaperDollFrame_SetDamage(statsTable[1], "player", category);
        MYS_PaperDollFrame_SetMeleeAttackPower(statsTable[2], "player");
        MYS_PaperDollFrame_SetAttackSpeed(statsTable[3], "player");
        MYS_PaperDollFrame_SetCritChance(statsTable[4], "player");
        MYS_PaperDollFrame_SetHitChance(statsTable[5], "player");
        MYS_PaperDollFrame_SetExperties(statsTable[6], "player");
    elseif category == PLAYERSTAT_RANGED_COMBAT then
        if (UISettingsCharacter.showStatsFromArgentDawnItems) then
            MYS_CacheAPFromADItems("player");
        end

        MYS_PaperDollFrame_SetDamage(statsTable[1], "player", category);
        MYS_PaperDollFrame_SetRangedAttackPower(statsTable[2], "player");
        MYS_PaperDollFrame_SetRangeHaste(statsTable[3], "player");
        MYS_PaperDollFrame_SetRangedAttackSpeed(statsTable[4], "player");
        MYS_PaperDollFrame_SetRangedCritChance(statsTable[5], "player");
        MYS_PaperDollFrame_SetRangedHitChance(statsTable[6], "player");
    elseif category == PLAYERSTAT_SPELL_COMBAT then
        -- bonus dmg, bonus healing, crit chance, mana regen, hit
        MYS_PaperDollFrame_SetSpellPower(statsTable[1], "player");
        MYS_PaperDollFrame_SetHealing(statsTable[2], "player");
        MYS_PaperDollFrame_SetManaRegen(statsTable[3], "player");
        MYS_PaperDollFrame_SetSpellCritChance(statsTable[4], "player");
        MYS_PaperDollFrame_SetSpellHitChance(statsTable[5], "player");
        MYS_PaperDollFrame_SetSpellHaste(statsTable[6], "player");
    elseif category == PLAYERSTAT_COMBAT_TABLE then
        local p;
        local sum = MYS_PaperDollFrame_SetCombatMissHit(statsTable[1], "player");
        sum = MYS_PaperDollFrame_SetCombatDodge(statsTable[2], "player", sum);
        sum, p = MYS_PaperDollFrame_SetCombatParry(statsTable[3], "player", sum);
        sum = MYS_PaperDollFrame_SetCombatGlancing(statsTable[4], "player", sum, p);
        sum = MYS_PaperDollFrame_SetCombatCrited(statsTable[5], "player", sum, p);
        sum = MYS_PaperDollFrame_SetCombatHit(statsTable[6], "player", sum, p);

    elseif category == PLAYERSTAT_DEFENCE_TABLE then
        MYS_PaperDollFrame_SetDefenceAvoid(statsTable[1], "player");

        MYS_PaperDollFrame_SetDefenceBlock(statsTable[2], "player");
        MYS_PaperDollFrame_SetDefenceCrited(statsTable[3], "player");
        MYS_PaperDollFrame_SetDefenceCrushed(statsTable[4], "player");
        MYS_PaperDollFrame_SetDefenceHitted(statsTable[5], "player");
    end
end

function UIConfig:CreateMenu()
    -- Hide the default stats
    CharacterAttributesFrame:Hide();

    MYS_UIFrame.CharacterStatsPanel = CreateFrame("Frame", nil, CharacterFrame); -- CharacterFrameInsetRight
    MYS_UIFrame.CharacterStatsPanel:SetPoint("LEFT", CharacterFrame, "BOTTOMLEFT", 50, 85); -- 85 for 6 stats
    MYS_UIFrame.CharacterStatsPanel:SetHeight(320);
    MYS_UIFrame.CharacterStatsPanel:SetWidth(200);

    UIConfig:SetupDropdown();
    UIConfig:SetupConfigInterface();

    UIConfig:InitializeStatsFrames(MYS_UIFrame.CharacterStatsPanel.leftStatsDropDown,
        MYS_UIFrame.CharacterStatsPanel.rightStatsDropDown);
    UIConfig:UpdateStats();
end

function UIConfig:UpdateStats()
    MYS_CalcDefenceTable();
    UIConfig:SetCharacterStats(LeftStatsTable, statsDropdownList[UISettingsCharacter.selectedLeftStatsCategory]);
    UIConfig:SetCharacterStats(RightStatsTable, statsDropdownList[UISettingsCharacter.selectedRightStatsCategory]);
end

local function OnClickLeftStatsDropdown(self)
    UISettingsCharacter.selectedLeftStatsCategory = self:GetID();
    UIDropDownMenu_SetSelectedID(MYS_UIFrame.CharacterStatsPanel.leftStatsDropDown,
        UISettingsCharacter.selectedLeftStatsCategory);
    UIConfig:SetCharacterStats(LeftStatsTable, statsDropdownList[UISettingsCharacter.selectedLeftStatsCategory]);
end

local function OnClickRightStatsDropdown(self)
    UISettingsCharacter.selectedRightStatsCategory = self:GetID();
    UIDropDownMenu_SetSelectedID(MYS_UIFrame.CharacterStatsPanel.rightStatsDropDown,
        UISettingsCharacter.selectedRightStatsCategory);
    UIConfig:SetCharacterStats(RightStatsTable, statsDropdownList[UISettingsCharacter.selectedRightStatsCategory]);
end

function UIConfig:InitializeLeftStatsDropdown(self, level)
    local info = UIDropDownMenu_CreateInfo();
    for k, v in pairs(statsDropdownList) do
        info.text = v;
        info.func = OnClickLeftStatsDropdown;
        info.checked = false;
        UIDropDownMenu_AddButton(info, level);
    end
end

function UIConfig:InitializeRightStatsDropdown(self, level)
    local info = UIDropDownMenu_CreateInfo();
    for k, v in pairs(statsDropdownList) do
        info.text = v;
        info.func = OnClickRightStatsDropdown;
        info.checked = false;
        UIDropDownMenu_AddButton(info, level);
    end
end

function UIConfig:SetupDropdown()

    MYS_UIFrame.CharacterStatsPanel.leftStatsDropDown = CreateFrame("Frame", nil, MYS_UIFrame.CharacterStatsPanel,
        "UIDropDownMenuTemplate");
    MYS_UIFrame.CharacterStatsPanel.leftStatsDropDown:SetPoint("TOPLEFT", MYS_UIFrame.CharacterStatsPanel, "TOPLEFT", 0,
        0);

    MYS_UIFrame.CharacterStatsPanel.rightStatsDropDown = CreateFrame("Frame", nil, MYS_UIFrame.CharacterStatsPanel,
        "UIDropDownMenuTemplate");
    MYS_UIFrame.CharacterStatsPanel.rightStatsDropDown:SetPoint("TOPLEFT", MYS_UIFrame.CharacterStatsPanel, "TOPLEFT",
        115, 0);

    UIDropDownMenu_Initialize(MYS_UIFrame.CharacterStatsPanel.leftStatsDropDown, UIConfig.InitializeLeftStatsDropdown);
    UIDropDownMenu_SetSelectedID(MYS_UIFrame.CharacterStatsPanel.leftStatsDropDown,
        UISettingsCharacter.selectedLeftStatsCategory);
    UIDropDownMenu_SetWidth(MYS_UIFrame.CharacterStatsPanel.leftStatsDropDown, 99);
    UIDropDownMenu_JustifyText(MYS_UIFrame.CharacterStatsPanel.leftStatsDropDown, "LEFT");

    UIDropDownMenu_Initialize(MYS_UIFrame.CharacterStatsPanel.rightStatsDropDown, UIConfig.InitializeRightStatsDropdown);
    UIDropDownMenu_SetSelectedID(MYS_UIFrame.CharacterStatsPanel.rightStatsDropDown,
        UISettingsCharacter.selectedRightStatsCategory);
    UIDropDownMenu_SetWidth(MYS_UIFrame.CharacterStatsPanel.rightStatsDropDown, 99);
    UIDropDownMenu_JustifyText(MYS_UIFrame.CharacterStatsPanel.rightStatsDropDown, "LEFT");
end

function UIConfig:SetupConfigInterface()

    MYS_ConfigFrame = CreateFrame("Frame", "MYS_InterfaceOptionsPanel", UIParent);
    MYS_ConfigFrame.name = "喵影三围属性";

    category, layout =
        Settings.RegisterCanvasLayoutCategory(MYS_ConfigFrame, MYS_ConfigFrame.name, MYS_ConfigFrame.name);
    category.ID = MYS_ConfigFrame.name
    Settings.RegisterAddOnCategory(category);

    -- Title and font
    MYS_ConfigFrame.title = CreateFrame("Frame", "喵影三围属性", MYS_ConfigFrame);
    MYS_ConfigFrame.title:SetPoint("TOPLEFT", MYS_ConfigFrame, "TOPLEFT", 10, -10);
    MYS_ConfigFrame.title:SetWidth(300);
    MYS_ConfigFrame.titleString = MYS_ConfigFrame.title:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    MYS_ConfigFrame.titleString:SetPoint("TOPLEFT", MYS_ConfigFrame, "TOPLEFT", 10, -10);
    MYS_ConfigFrame.titleString:SetText('|cff00c0ff喵影三围属性|r');
    MYS_ConfigFrame.titleString:SetFont("Fonts\\FRIZQT__.tff", 20, "OUTLINE");
    -- Stats frames alpha checkbox
    MYS_ConfigFrame.chkBtnStatsFramesAlpha = CreateFrame("CheckButton","MYS_REALTIME_UPDATE",MYS_ConfigFrame, "UICheckButtonTemplate");
    MYS_ConfigFrame.chkBtnStatsFramesAlpha:SetPoint("TOPLEFT", 20, -40);
    MYS_ConfigFrame.chkBtnStatsFramesAlpha.Text:SetText("实时更新（使用WA监控时请务必勾选）");
    MYS_ConfigFrame.chkBtnStatsFramesAlpha:SetChecked(UISettingsGlobal.MYS_Config_RealtimeUpdate);
    MYS_ConfigFrame.chkBtnStatsFramesAlpha:SetScript("OnClick", 
    function()
        UISettingsGlobal.MYS_Config_RealtimeUpdate = not UISettingsGlobal.MYS_Config_RealtimeUpdate;
    end);
    
    local button = CreateFrame("Button", "ImportWAButton", MYS_ConfigFrame, "UIPanelButtonTemplate")
    button:SetSize(120, 30)
    button:SetPoint("TOPLEFT", MYS_ConfigFrame, 0, -100)
    button:SetText("导入监控WA")
    local text = MYS_ConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", MYS_ConfigFrame, "TOPLEFT", 0, -200)
    text:SetText(
        "该WA可以监控15个属性 您可以自行去wa里该插件的图示->文本设置里 去增删显示内容\n\n%c1代表第一个内容 依次类推\n\n%c1~%c15分别为:\n\n%c1 = 物理规避\n%c2 = 未被命中\n%c3 = 躲闪几率\n%c4 = 招架几率\n%c5 = 近战攻强\n%c6 = 远程攻强\n%c7 = 法术伤害\n%c8 = 近战暴击\n%c9 = 远程暴击\n%c10 = 法术暴击\n%c11 = 近战急速\n%c12 = 远程急速\n%c13 = 法系急速\n%c14 = 格挡几率\n%c15 = 格挡值")
    text:SetJustifyH("LEFT");
    text:SetTextColor(1, 1, 1) -- 白色文字
    -- 点击事件处理
    button:SetScript("OnClick", function()
        MYS_ImportWA()
    end)
    -- Checkboxes

end

function UIConfig:SetStatsPanelVisibile(isVisible)
    UISettingsGlobal.statsPanelHidden = not isVisible;
end

-- Hook a custom function in order to extend the functionality of the default ToggleCharacter function
local function MYS_ToggleCharacterPostHook(tab, onlyShow)

    if (tab == "PaperDollFrame") then

        MYS_UIFrame.CharacterStatsPanel:Show();
        if CSC_HideStatsPanel then
            CSC_HideStatsPanel()
        end
        CharacterAttributesFrame:Hide();
        MYS_GearStats = MYS_ScanGearStats("player")
        MYS_UIFrame:UpdateStats();
    else
        MYS_HideStatsPanel()
    end

end
hooksecurefunc("ToggleCharacter", MYS_ToggleCharacterPostHook);

-- Serializing the DB
local function SerializeGlobalDatabase()
    if (MYStatsDB == nil) then
        MYStatsDB = UISettingsGlobal;
    end

    if (MYStatsDB.MYS_Config_RealtimeUpdate == nil) then
        MYStatsDB.MYS_Config_RealtimeUpdate = UISettingsGlobal.MYS_Config_RealtimeUpdate;
    else
        UISettingsGlobal.MYS_Config_RealtimeUpdate = MYStatsDB.MYS_Config_RealtimeUpdate;
    end

    if (MYStatsDB.useTransparentStatsBackground == nil) then
        MYStatsDB.useTransparentStatsBackground = UISettingsGlobal.useTransparentStatsBackground;
    else
        UISettingsGlobal.useTransparentStatsBackground = MYStatsDB.useTransparentStatsBackground;
    end

    -- Stats frame visibility
    if (MYStatsDB.statsPanelHidden == nil) then
        MYStatsDB.statsPanelHidden = UISettingsGlobal.statsPanelHidden;
    else
        UISettingsGlobal.statsPanelHidden = MYStatsDB.statsPanelHidden;
    end
end

local function SerializeCharacterDatabase()
    if (MYStatsCharacterDB == nil) then
        MYStatsCharacterDB = UISettingsCharacter;
    end

    -- Left dropdown category
    if (MYStatsCharacterDB.selectedLeftStatsCategory == nil) then
        MYStatsCharacterDB.selectedLeftStatsCategory = UISettingsCharacter.selectedLeftStatsCategory;
    else
        UISettingsCharacter.selectedLeftStatsCategory = MYStatsCharacterDB.selectedLeftStatsCategory;
    end

    -- Right dropdown category
    if (MYStatsCharacterDB.selectedRightStatsCategory == nil) then
        MYStatsCharacterDB.selectedRightStatsCategory = UISettingsCharacter.selectedRightStatsCategory;
    else
        UISettingsCharacter.selectedRightStatsCategory = MYStatsCharacterDB.selectedRightStatsCategory;
    end

    -- Stats from AD items checkbox
    if (MYStatsCharacterDB.showStatsFromArgentDawnItems == nil) then
        MYStatsCharacterDB.showStatsFromArgentDawnItems = UISettingsCharacter.showStatsFromArgentDawnItems;
    else
        UISettingsCharacter.showStatsFromArgentDawnItems = MYStatsCharacterDB.showStatsFromArgentDawnItems;
    end
end

local dbLoader = CreateFrame("Frame");
dbLoader:RegisterEvent("ADDON_LOADED");
dbLoader:RegisterEvent("PLAYER_LOGOUT");

-- ADDON_LOADED is called after the code of the addon is being executed
-- Therefore I have to call any setup-functions dependent on the DB after the event (UIConfig:SetupDropdown())
function dbLoader:OnEvent(event, arg1)
    if (event == "ADDON_LOADED" and arg1 == "MYStats") then

        if CSC_HideStatsPanel then

            CSC_HideStatsPanel()
        end

        SerializeGlobalDatabase();
        SerializeCharacterDatabase();
        UIConfig:CreateMenu();
    elseif (event == "PLAYER_LOGOUT") then
        MYStatsDB = UISettingsGlobal;
        MYStatsCharacterDB = UISettingsCharacter;
    end
end

dbLoader:SetScript("OnEvent", dbLoader.OnEvent);
-- Serializing the DB
