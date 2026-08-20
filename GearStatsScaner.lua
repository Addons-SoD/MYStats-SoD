local MYS_ScanTooltip = CreateFrame("GameTooltip", "MYS_ScanTooltip", nil, "GameTooltipTemplate");
MYS_ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
local MYS_ScanTooltipPrefix = "MYS_ScanTooltip";
MYS_EXPERTISE ="expertise"
MYS_HOLYHIT="holyhit"
MYS_ATTACKSPEED="attackspeed"
MYS_SPELLHASTE="spellhaste"
function getEnchantId(unit, slotId)
	local itemLink = GetInventoryItemLink(unit, slotId);
	if itemLink then
		local itemId, enchant = itemLink:match("item:(%d+):(%d*)");
		return enchant
	end

	return nil;
end
MYS_GearStats=nil
local attrsExtractor={
    {ITEM_MOD_MYS_EXPERTISE,MYS_EXPERTISE},
    {ITEM_MOD_MYS_HOLYHIT,MYS_HOLYHIT},
    {ITEM_MOD_MYS_ATTACKSPEED,MYS_ATTACKSPEED},
    {ITEM_MOD_MYS_SPELLHASTE,MYS_SPELLHASTE}
}
local _enchants={
	[931]={MYS_ATTACKSPEED=1},
	[2543]={MYS_ATTACKSPEED=1},
	[1883]={MYS_ATTACKSPEED=1}
}
function MYS_GetGearStats(type)
	if not MYS_GearStats then
		MYS_GearStats=MYS_ScanGearStats("player")
	end
	return MYS_GearStats[type] or 0
end
function testx(n)
	 MYS_ScanTooltip:ClearLines();
	 local hasItem = MYS_ScanTooltip:SetUnitBuff("player", n);
	 print(hasItem);
	
	
				local maxLines = MYS_ScanTooltip:NumLines();
				print(maxLines)
				for line=1, maxLines do
					local leftText = getglobal(MYS_ScanTooltipPrefix.."TextLeft"..line);
					local rightText = getglobal(MYS_ScanTooltipPrefix.."TextRight"..line);
					print(leftText:GetText(),rightText:GetText())
				end
		
end
function MYS_ScanGearStats(unit)
    MYS_ScanTooltip:ClearLines();
	local firstItemslotIndex = 1;
	local lastItemslotIndex = 18;
	local itemset=ItemsetCollector:New()
    local stats={}
	local expertise=0;
    local attackSpeed=0;
    local holyHit=0;
    local spellHaste=0;
	for itemslot=firstItemslotIndex, lastItemslotIndex do
		local hasItem = MYS_ScanTooltip:SetInventoryItem(unit, itemslot);
		if hasItem then
			local itemId = GetInventoryItemID(unit, itemslot);
			itemset:collectItemID(itemId)
				local maxLines = MYS_ScanTooltip:NumLines();
				for line=1, maxLines do
					local leftText = getglobal(MYS_ScanTooltipPrefix.."TextLeft"..line);
					local text=leftText:GetText()
                    for idx=1,#attrsExtractor do
						
                        if text and  string.match(text,attrsExtractor[idx][1]) then
                            local valueTxt = string.match(text, "%d+");
                            local numValue=tonumber(valueTxt)
                            if numValue then
                                stats[attrsExtractor[idx][2]]=(stats[attrsExtractor[idx][2]] or 0)+numValue
                               
                            end
                        end
                    end
					if text and string.match(text,MYS_DRUID_SHOULDER_ENCHANT_EXPERTISE) then
						stats.expertise=(stats.expertise or 0) +5
					end	
					local enchantId=getEnchantId(unit,itemslot)
					if _enchants[enchantId] then
						for k,v in pairs(_enchants[enchantId]) do
							stats[k]=(stats[k] or 0)+_enchants[enchantId][k]
						end					
					end
					
				end
			
		end
	end
	for k,v in pairs(itemset.bonus) do
		stats[k]=(stats[k] or 0)+itemset.bonus[k]
	end
	MYS_ScanTooltip:ClearLines();
	return stats;
end