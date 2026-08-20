
-- local frame = CreateFrame("Frame", "HelloWorldFrame", UIParent,"BackdropTemplate")
-- frame:SetSize(200, 100)
-- frame:SetPoint("CENTER")
-- frame:SetMovable(true)
-- frame:EnableMouse(true)
-- frame:RegisterForDrag("LeftButton")
-- frame:SetScript("OnDragStart", frame.StartMoving)
-- frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- -- 背景设置

-- frame:SetBackdropColor(0, 0, 0, 0)

-- -- 文字显示
-- local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- text:SetPoint("LEFT")
-- text:SetText("Hello World!")

-- local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
-- closeBtn:SetPoint("TOPRIGHT", -5, -5)
-- closeBtn:SetSize(32, 32)
-- closeBtn:Hide()
-- closeBtn:SetScript("OnClick", function() frame:Hide() end)

-- -- 解决闪烁问题的关键修改
-- closeBtn:SetScript("OnEnter", function() 
--     frame.isOverCloseButton = true
--     closeBtn:Show()
-- end)
-- closeBtn:SetScript("OnLeave", function() 
--     frame.isOverCloseButton = false
--     closeBtn:Hide()
-- end)

-- frame:SetScript("OnEnter", function() 
--     closeBtn:Show() 
--     frame:SetBackdropColor(0.1, 0.1, 0.1, 0.2)
--     frame:SetBackdrop({
--     bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
--     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
--     tile = true, tileSize = 16, edgeSize = 16,
--     insets = { left = 4, right = 4, top = 4, bottom = 4 }
-- })
-- end)
-- frame:SetScript("OnLeave", function() 
--     if not frame.isOverCloseButton then
--         closeBtn:Hide() 
--         frame:SetBackdropColor(0, 0, 0)
--         frame:SetBackdrop(nil)
--     end
-- end)

-- -- 保存位置（可选）
-- frame:SetScript("OnHide", function()
--     local point, _, relPoint, x, y = frame:GetPoint()
--     HelloWorldFrame_Saved = {point = point, relPoint = relPoint, x = x, y = y}
-- end)

-- -- 加载保存的位置（可选）
-- if HelloWorldFrame_Saved then
--     frame:ClearAllPoints()
--     frame:SetPoint(HelloWorldFrame_Saved.point, UIParent, 
--                   HelloWorldFrame_Saved.relPoint, 
--                   HelloWorldFrame_Saved.x, 
--                   HelloWorldFrame_Saved.y)
-- end
