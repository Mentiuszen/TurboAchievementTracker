local addonName, TAT = ...

local MinimapButton = CreateFrame("Button", "TAT_MinimapButton", Minimap)
TAT.MinimapButton = MinimapButton

function TAT:InitializeMinimapButton()
    if not TAT.db or not TAT.db.minimap then return end
    
    MinimapButton:SetSize(31, 31)
    MinimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    
    -- Icon
    MinimapButton.icon = MinimapButton:CreateTexture(nil, "BACKGROUND")
    MinimapButton.icon:SetSize(20, 20)
    MinimapButton.icon:SetPoint("CENTER", 0, 0)
    MinimapButton.icon:SetTexture("Interface\\Icons\\ACHIEVEMENT_GUILD_DOCTORISIN")
    
    -- Round border matching standard minimap buttons
    MinimapButton.border = MinimapButton:CreateTexture(nil, "OVERLAY")
    MinimapButton.border:SetSize(53, 53)
    MinimapButton.border:SetPoint("TOPLEFT", 0, 0)
    MinimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    -- Dragging logic
    MinimapButton:RegisterForDrag("LeftButton")
    
    local function UpdatePosition(angle)
        local radius = 80 -- Standard distance from minimap center
        local x = radius * math.cos(math.rad(angle))
        local y = radius * math.sin(math.rad(angle))
        MinimapButton:ClearAllPoints()
        MinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
    
    MinimapButton:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            
            local angle = math.deg(math.atan2(cy - my, cx - mx))
            if angle < 0 then angle = angle + 360 end
            
            TAT.db.minimap.minimapPos = angle
            UpdatePosition(angle)
        end)
    end)
    
    MinimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    
    -- Tooltip
    MinimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cffFFD100Turbo Achievement Tracker|r")
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff00ff00Left-click|r: Open window")
        GameTooltip:AddLine("|cff00ff00Drag|r: Move button")
        GameTooltip:Show()
    end)
    
    MinimapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- OnClick
    MinimapButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            TAT:ToggleUI()
        end
    end)
    
    -- Initialize position and visibility
    UpdatePosition(TAT.db.minimap.minimapPos or 220)
    if TAT.db.minimap.hide then
        MinimapButton:Hide()
    else
        MinimapButton:Show()
    end
end

-- Refresh visibility
function TAT:UpdateMinimapButtonVisibility()
    if not TAT.db or not TAT.db.minimap then return end
    if TAT.db.minimap.hide then
        MinimapButton:Hide()
    else
        MinimapButton:Show()
    end
end

-- Hook database loaded
local dbHook = TAT.OnDatabaseLoaded
function TAT:OnDatabaseLoaded()
    if dbHook then dbHook(self) end
    TAT:InitializeMinimapButton()
end
