local addonName, WQAT = ...

local MinimapButton = CreateFrame("Button", "WQAT_MinimapButton", Minimap)
WQAT.MinimapButton = MinimapButton

function WQAT:InitializeMinimapButton()
    if not WQAT.db or not WQAT.db.minimap then return end
    
    MinimapButton:SetSize(31, 31)
    MinimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    
    MinimapButton.icon = MinimapButton:CreateTexture(nil, "BACKGROUND")
    MinimapButton.icon:SetSize(20, 20)
    MinimapButton.icon:SetPoint("CENTER", 0, 0)
    MinimapButton.icon:SetTexture("Interface\\Icons\\ACHIEVEMENT_GUILD_DOCTORISIN")
    
    MinimapButton.border = MinimapButton:CreateTexture(nil, "OVERLAY")
    MinimapButton.border:SetSize(53, 53)
    MinimapButton.border:SetPoint("TOPLEFT", 0, 0)
    MinimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    MinimapButton:RegisterForDrag("LeftButton")
    
    local function UpdatePosition(angle)
        local radius = 80
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
            
            WQAT.db.minimap.minimapPos = angle
            UpdatePosition(angle)
        end)
    end)
    
    MinimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    
    MinimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cffFFD100World Quest Achievement Tracker|r")
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff00ff00Left-click|r: Open window")
        GameTooltip:AddLine("|cff00ff00Drag|r: Move button")
        GameTooltip:Show()
    end)
    
    MinimapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    MinimapButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            WQAT:ToggleUI()
        end
    end)
    
    UpdatePosition(WQAT.db.minimap.minimapPos or 220)
    if WQAT.db.minimap.hide then
        MinimapButton:Hide()
    else
        MinimapButton:Show()
    end
end

function WQAT:UpdateMinimapButtonVisibility()
    if not WQAT.db or not WQAT.db.minimap then return end
    if WQAT.db.minimap.hide then
        MinimapButton:Hide()
    else
        MinimapButton:Show()
    end
end

local dbHook = WQAT.OnDatabaseLoaded
function WQAT:OnDatabaseLoaded()
    if dbHook then dbHook(self) end
    WQAT:InitializeMinimapButton()
end