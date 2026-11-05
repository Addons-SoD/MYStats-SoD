-- Access the namespace
local _, core = ...;
local hideCSC=false
-- wow-forever: 统一走 MYS_RegisterEvent（见 MYStatsCompat.lua）。
-- 无限客户端没有 RUNE_UPDATED 等 SoD/Classic 专属事件，直接 RegisterEvent
-- 会抛 "unknown event" 并中断本文件后续代码，所以先按 C_EventUtils.IsEventValid 过滤。
local characterStatsClassicEventFrame = CreateFrame("Frame");
MYS_RegisterEvent(characterStatsClassicEventFrame, "PLAYER_ENTERING_WORLD");
MYS_RegisterEvent(characterStatsClassicEventFrame, "PLAYER_EQUIPMENT_CHANGED");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_AURA");
MYS_RegisterEvent(characterStatsClassicEventFrame, "PLAYER_DAMAGE_DONE_MODS");
MYS_RegisterEvent(characterStatsClassicEventFrame, "SKILL_LINES_CHANGED");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UPDATE_SHAPESHIFT_FORM");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_DAMAGE");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_ATTACK_SPEED");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_RANGEDDAMAGE");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_ATTACK");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_RESISTANCES");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_STATS");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_MAXHEALTH");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_ATTACK_POWER");
MYS_RegisterEvent(characterStatsClassicEventFrame, "UNIT_RANGED_ATTACK_POWER");
MYS_RegisterEvent(characterStatsClassicEventFrame, "COMBAT_RATING_UPDATE");
MYS_RegisterEvent(characterStatsClassicEventFrame, "VARIABLES_LOADED");
MYS_RegisterEvent(characterStatsClassicEventFrame, "RUNE_UPDATED");



characterStatsClassicEventFrame:SetScript("OnEvent",
    function(self, event, ...)
       
        if (event == "PLAYER_ENTERING_WORLD") then
            MYS_GenerateTalentsIndexMap();                
        end

        if (not core.UIConfig.CharacterStatsPanel:IsVisible() and not UISettingsGlobal.MYS_Config_RealtimeUpdate) then
            return;
        end

        local args = {...};
        if event == "VARIABLES_LOADED" then
            core.UIConfig:UpdateStats();
        end
        if (event == "RUNE_UPDATED" or
            event=="PLAYER_EQUIPMENT_CHANGED" ) then
                MYS_GearStats=MYS_ScanGearStats("player")
                MYS_clearWeaponSpeedCache()
                self:SetScript("OnUpdate", MYS_QueuedUpdate);
                return

        end
       
        if args[1] == "player" then
            if ( event == "UNIT_DAMAGE" or
                event == "PLAYER_DAMAGE_DONE_MODS" or
                event == "UNIT_ATTACK_SPEED" or
                event == "UNIT_RANGEDDAMAGE" or
                event == "UNIT_ATTACK" or
                event == "UNIT_RESISTANCES" or
                event == "UNIT_STATS" or
                event == "UNIT_AURA" or
                event == "UNIT_MAXHEALTH" or
                event == "UNIT_ATTACK_POWER" or
                event == "UNIT_RANGED_ATTACK_POWER" or
                event == "SKILL_LINES_CHANGED" or
                event == "COMBAT_RATING_UPDATE") then
                
                self:SetScript("OnUpdate", MYS_QueuedUpdate);
            end
        end
    end)

function MYS_QueuedUpdate(self)
    self:SetScript("OnUpdate", nil);
    
    core.UIConfig:UpdateStats();
end

-- Exposing global functions for showing/hiding the stats panel. For compatibility with other addons
function MYS_HideStatsPanel()
    core.UIConfig.CharacterStatsPanel:Hide();
    core.UIConfig:SetStatsPanelVisibile(false);
end

function MYS_ShowStatsPanel()
    core.UIConfig.CharacterStatsPanel:Show();
    core.UIConfig:UpdateStats();
    core.UIConfig:SetStatsPanelVisibile(true);
end


