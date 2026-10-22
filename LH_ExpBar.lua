local ADDON_NAME = ...
local TEXTURE = "Interface\\AddOns\\LH_ExpBar\\Media\\Smooth.tga"
local HEIGHT, INSET = 20, 3
local bar, experience, rested, gain, label, handle, resizing, moving
local Addon = {}
LH_ExpBar = Addon
local xpValues
local initialized = false
local lastXP, lastMaximum, lastLevel
local animation
local ANIMATION_DURATION = 0.6

local function StopAnimation(current)
    animation = nil
    experience:SetScript("OnUpdate", nil)
    gain:Hide()
    if current then experience:SetValue(current) end
end

local function AnimateExperience(current)
    local displayed = experience:GetValue()
    gain:SetValue(current)
    gain:Show()
    animation = { from = displayed, target = current, elapsed = 0 }
    experience:SetScript("OnUpdate", function(self, elapsed)
        animation.elapsed = animation.elapsed + elapsed
        local progress = math.min(animation.elapsed / ANIMATION_DURATION, 1)
        -- Ease out as the normal gold fill catches the highlighted gain.
        local eased = 1 - (1 - progress) ^ 3
        self:SetValue(animation.from + (animation.target - animation.from) * eased)
        if progress >= 1 then StopAnimation(animation.target) end
    end)
end

local function StandardWidth()
    -- Convert the minimap's physical width into this frame's UI units.
    return Minimap and Minimap:GetWidth() * Minimap:GetEffectiveScale() / bar:GetEffectiveScale() or 140
end

local function UpdateSize()
    if not bar then return end
    bar:SetSize(math.max(70, StandardWidth() * LH_ExpBarDB.widthFactor), HEIGHT * LH_ExpBarDB.heightFactor)
end

local function DefaultAnchor()
    -- The coordinate display may be created after this addon loads; fall back to the minimap.
    local cluster = MinimapCluster
    local container = cluster and cluster.MinimapContainer
    return container and container.PlayerCoords or Minimap or UIParent
end

local function RestorePosition()
    bar:ClearAllPoints()
    local position = LH_ExpBarDB.position
    if type(position) == "table" and type(position.x) == "number" and type(position.y) == "number" then
        bar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", position.x, position.y)
    else
        bar:SetPoint("TOP", DefaultAnchor(), "BOTTOM", 0, -10)
    end
end

local function SavePosition()
    local x, y = bar:GetCenter()
    if not x or not y then return end
    local scale = bar:GetEffectiveScale() / UIParent:GetEffectiveScale()
    x, y = x * scale, y * scale
    LH_ExpBarDB.position = { x = x, y = y }
    bar:ClearAllPoints()
    bar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end

local function StopMoving()
    bar:StopMovingOrSizing()
    if moving then moving = nil; SavePosition() end
end

local function FinishResize()
    if resizing then
        resizing = nil
        SavePosition()
        if Addon.RefreshSettings then Addon:RefreshSettings() end
    end
end

local function HideTooltip()
    if GameTooltip and GameTooltip:IsOwned(bar) then GameTooltip:Hide() end
end

local function ShowTooltip()
    if not LH_ExpBarDB.locked or not xpValues or xpValues.maximum <= 0 then return end
    local function number(value)
        return BreakUpLargeNumbers and BreakUpLargeNumbers(value) or string.format("%.0f", value)
    end
    local current, maximum, bonus = xpValues.current, xpValues.maximum, xpValues.bonus
    GameTooltip:SetOwner(bar, "ANCHOR_TOP")
    GameTooltip:SetText("LH ExpBar")
    GameTooltip:AddLine(string.format("Level: %d", UnitLevel("player")), 1, 1, 1)
    GameTooltip:AddLine(string.format("Current XP: %s / %s (%.2f%%)",
        number(current), number(maximum), current / maximum * 100), 1, 0.82, 0)
    GameTooltip:AddLine(string.format("Rested XP: %s (%.2f%% of a level)",
        number(bonus), bonus / maximum * 100), 0.62, 0.87, 1)
    GameTooltip:AddLine(string.format("XP to next level: %s (%.2f%%)",
        number(maximum - current), (maximum - current) / maximum * 100), 1, 1, 1)
    GameTooltip:Show()
end

local function UpdateExperience()
    if not initialized then return end
    local maximum = UnitXPMax("player") or 0
    local current = UnitXP("player") or 0
    local bonus = GetXPExhaustion() or 0
    local level = UnitLevel("player")
    local capped = GetMaxPlayerLevel and UnitLevel("player") >= GetMaxPlayerLevel()
    if maximum <= 0 or capped then
        StopAnimation()
        lastXP, lastMaximum, lastLevel = nil, nil, nil
        xpValues = nil
        HideTooltip()
        if LH_ExpBarDB.locked then bar:Hide()
        else
            experience:SetMinMaxValues(0, 1)
            experience:SetValue(1)
            rested:Hide()
            label:SetText("LH ExpBar")
            bar:Show()
        end
        return
    end
    current = math.min(math.max(current, 0), maximum)
    bonus = math.max(bonus, 0)
    xpValues = {current = current, maximum = maximum, bonus = bonus}
    experience:SetMinMaxValues(0, maximum)
    gain:SetMinMaxValues(0, maximum)
    if lastXP and lastMaximum == maximum and lastLevel == level and current > lastXP then
        AnimateExperience(current)
    elseif not lastXP or lastMaximum ~= maximum or lastLevel ~= level or current < lastXP then
        StopAnimation(current)
    elseif not animation then
        experience:SetValue(current)
    end
    lastXP, lastMaximum, lastLevel = current, maximum, level
    -- Gold covers the rested fill up to current XP, leaving just the bonus segment.
    rested:SetMinMaxValues(0, maximum)
    rested:SetValue(math.min(current + bonus, maximum))
    rested:SetShown(bonus > 0)
    local text = string.format("%.0f%%", current / maximum * 100)
    if bonus > 0 then
        text = text .. string.format(" |cff9edfff(+ %.0f%%)|r", bonus / maximum * 100)
    end
    label:SetText(text)
    bar:Show()
    if GameTooltip and GameTooltip:IsOwned(bar) then ShowTooltip() end
end

local function CreateBar()
    LH_ExpBarDB = type(LH_ExpBarDB) == "table" and LH_ExpBarDB or {}
    LH_ExpBarDB.locked = LH_ExpBarDB.locked ~= false
    for _, key in ipairs({"widthFactor", "heightFactor"}) do
        local value = LH_ExpBarDB[key]
        LH_ExpBarDB[key] = type(value) == "number" and math.max(0.5, math.min(2, value)) or 1
    end
    bar = CreateFrame("Frame", "LH_ExpBarFrame", UIParent, "BackdropTemplate")
    bar:SetSize(140, HEIGHT)
    bar:SetFrameStrata("MEDIUM")
    bar:SetMovable(true)
    bar:SetClampedToScreen(true)
    bar:EnableMouse(true)
    bar:RegisterForDrag("LeftButton")
    bar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    bar:SetBackdropColor(0, 0, 0, 1)
    bar:SetBackdropBorderColor(0.65, 0.59, 0.45, 1)

    rested = CreateFrame("StatusBar", nil, bar)
    rested:SetPoint("TOPLEFT", INSET, -INSET)
    rested:SetPoint("BOTTOMRIGHT", -INSET, INSET)
    rested:SetStatusBarTexture(TEXTURE)
    rested:SetStatusBarColor(0.55, 0.82, 1, 1)
    rested:SetFrameLevel(bar:GetFrameLevel() + 1)
    rested:EnableMouse(false)

    gain = CreateFrame("StatusBar", nil, bar)
    gain:SetAllPoints(rested)
    gain:SetStatusBarTexture(TEXTURE)
    gain:SetStatusBarColor(1, 0.95, 0.55, 1)
    gain:SetFrameLevel(bar:GetFrameLevel() + 2)
    gain:EnableMouse(false)
    gain:Hide()

    experience = CreateFrame("StatusBar", nil, bar)
    experience:SetAllPoints(rested)
    experience:SetStatusBarTexture(TEXTURE)
    experience:SetStatusBarColor(1, 0.75, 0.15, 1)
    experience:SetFrameLevel(bar:GetFrameLevel() + 3)
    experience:EnableMouse(false)

    local textFrame = CreateFrame("Frame", nil, bar)
    textFrame:SetAllPoints(bar)
    textFrame:SetFrameLevel(bar:GetFrameLevel() + 4)
    textFrame:EnableMouse(false)
    label = textFrame:CreateFontString(nil, "OVERLAY")
    label:SetPoint("CENTER")
    label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    label:SetTextColor(1, 1, 1, 1)
    label:SetShadowColor(0, 0, 0, 1)
    label:SetShadowOffset(1, -1)

    bar:SetScript("OnDragStart", function(self)
        if not LH_ExpBarDB.locked and not resizing then moving = true; self:StartMoving() end
    end)
    bar:SetScript("OnDragStop", StopMoving)
    bar:SetScript("OnEnter", ShowTooltip)
    bar:SetScript("OnLeave", HideTooltip)
    bar:SetScript("OnHide", function()
        StopMoving()
        FinishResize()
        HideTooltip()
        StopAnimation(lastXP)
    end)
    handle = CreateFrame("Button", "LH_ExpBarResizeHandle", bar)
    handle:SetSize(16, 16)
    handle:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -4)
    handle:SetFrameLevel(bar:GetFrameLevel() + 10)
    handle:EnableMouse(true)
    local circle = handle:CreateTexture(nil, "ARTWORK")
    circle:SetAllPoints()
    circle:SetTexture("Interface\\Buttons\\UI-RadioButton")
    circle:SetTexCoord(0.25, 0.5, 0, 1)
    handle:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or LH_ExpBarDB.locked then return end
        StopMoving()
        local x, y = GetCursorPosition()
        local scale = bar:GetEffectiveScale()
        local parentScale = UIParent:GetEffectiveScale()
        local left, top = bar:GetLeft(), bar:GetTop()
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left * scale / parentScale, top * scale / parentScale)
        resizing = {x = x / scale, y = y / scale, width = LH_ExpBarDB.widthFactor,
            height = LH_ExpBarDB.heightFactor, base = StandardWidth()}
    end)
    handle:SetScript("OnMouseUp", function(_, button) if button == "LeftButton" then FinishResize() end end)
    handle:SetScript("OnHide", FinishResize)
    handle:SetShown(not LH_ExpBarDB.locked)
    initialized = true
    UpdateSize()
    RestorePosition()
    UpdateExperience()
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_XP_UPDATE")
events:RegisterEvent("UPDATE_EXHAUSTION")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("PLAYER_UPDATE_RESTING")
events:RegisterEvent("UI_SCALE_CHANGED")
events:RegisterEvent("DISPLAY_SIZE_CHANGED")
events:SetScript("OnEvent", function(_, event, unit)
    if event == "ADDON_LOADED" then
        if unit == ADDON_NAME and not initialized then CreateBar() end
        return
    end
    if not initialized or (event == "PLAYER_XP_UPDATE" and unit and unit ~= "player") then return end
    if event == "PLAYER_ENTERING_WORLD" and type(LH_ExpBarDB.position) ~= "table" then RestorePosition() end
    UpdateSize()
    UpdateExperience()
    -- XP can update after the level-up event itself.
    if event == "PLAYER_LEVEL_UP" then C_Timer.After(0, UpdateExperience) end
end)

-- Detect minimap size/scale changes made by other addons after login.
local elapsedSinceCheck = 0
events:SetScript("OnUpdate", function(_, elapsed)
    if not initialized then return end
    if resizing then
        if not IsMouseButtonDown("LeftButton") then FinishResize()
        else
            local x, y = GetCursorPosition()
            local scale = bar:GetEffectiveScale()
            LH_ExpBarDB.widthFactor = math.max(0.5, math.min(2, resizing.width + (x / scale - resizing.x) / resizing.base))
            LH_ExpBarDB.heightFactor = math.max(0.5, math.min(2, resizing.height + (resizing.y - y / scale) / HEIGHT))
            UpdateSize()
        end
    end
    elapsedSinceCheck = elapsedSinceCheck + elapsed
    if elapsedSinceCheck >= 0.5 then
        elapsedSinceCheck = 0
        UpdateSize()
    end
end)

SLASH_LH_EXPBAR1 = "/lh_expbar"
function Addon:IsUnlocked() return LH_ExpBarDB and LH_ExpBarDB.locked == false or false end
function Addon:GetSizeFactor(key) return LH_ExpBarDB and LH_ExpBarDB[key] or 1 end
function Addon:SetSizeFactor(key, value)
    if not initialized or (key ~= "widthFactor" and key ~= "heightFactor") or type(value) ~= "number" then return end
    FinishResize()
    LH_ExpBarDB[key] = math.max(0.5, math.min(2, value))
    UpdateSize()
    if self.RefreshSettings then self:RefreshSettings() end
end
SlashCmdList.LH_EXPBAR = function(message)
    if not initialized then return end
    local command = (message or ""):lower():match("^%s*(.-)%s*$")
    if command == "lock" or command == "unlock" then
        StopMoving()
        FinishResize()
        HideTooltip()
        LH_ExpBarDB.locked = command == "lock"
        handle:SetShown(not LH_ExpBarDB.locked)
        UpdateExperience()
        print(LH_ExpBarDB.locked and "LH_ExpBar: Position locked." or "LH_ExpBar: Drag the bar to move; drag the circle to resize.")
    elseif command == "reset" then
        StopMoving()
        FinishResize()
        LH_ExpBarDB.position = nil
        LH_ExpBarDB.widthFactor, LH_ExpBarDB.heightFactor = 1, 1
        RestorePosition()
        UpdateSize()
        UpdateExperience()
    else
        print("LH_ExpBar: /lh_expbar unlock | lock | reset")
    end
    if Addon.RefreshSettings then Addon:RefreshSettings() end
end
