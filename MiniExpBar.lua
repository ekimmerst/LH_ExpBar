local ADDON_NAME = ...
local TEXTURE = "Interface\\AddOns\\MiniExpBar\\Media\\Smooth.tga"
local HEIGHT, INSET = 20, 3
local bar, experience, rested, gain, label
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

local function UpdateWidth()
    if not bar or not Minimap then return end
    -- Convert the minimap's physical width into this frame's UI units.
    local width = Minimap:GetWidth() * Minimap:GetEffectiveScale() / bar:GetEffectiveScale()
    if width > INSET * 2 then bar:SetWidth(width) end
end

local function RestorePosition()
    bar:ClearAllPoints()
    local position = MiniExpBarDB.position
    if type(position) == "table" and type(position.x) == "number" and type(position.y) == "number" then
        bar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", position.x, position.y)
    else
        bar:SetPoint("TOP", Minimap or UIParent, "BOTTOM", 0, -8)
    end
end

local function SavePosition()
    local x, y = bar:GetCenter()
    if not x or not y then return end
    local scale = bar:GetEffectiveScale() / UIParent:GetEffectiveScale()
    x, y = x * scale, y * scale
    MiniExpBarDB.position = { x = x, y = y }
    bar:ClearAllPoints()
    bar:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
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
        bar:Hide()
        return
    end
    current = math.min(math.max(current, 0), maximum)
    bonus = math.max(bonus, 0)
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
end

local function CreateBar()
    MiniExpBarDB = type(MiniExpBarDB) == "table" and MiniExpBarDB or {}
    bar = CreateFrame("Frame", "MiniExpBarFrame", UIParent, "BackdropTemplate")
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

    bar:SetScript("OnDragStart", function(self) self:StartMoving() end)
    bar:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    bar:SetScript("OnHide", function(self)
        self:StopMovingOrSizing()
        StopAnimation(lastXP)
    end)
    initialized = true
    UpdateWidth()
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
    UpdateWidth()
    UpdateExperience()
    -- XP can update after the level-up event itself.
    if event == "PLAYER_LEVEL_UP" then C_Timer.After(0, UpdateExperience) end
end)

-- Detect minimap size/scale changes made by other addons after login.
local elapsedSinceCheck = 0
events:SetScript("OnUpdate", function(_, elapsed)
    elapsedSinceCheck = elapsedSinceCheck + elapsed
    if elapsedSinceCheck >= 0.5 then
        elapsedSinceCheck = 0
        if initialized then UpdateWidth() end
    end
end)

SLASH_MINIEXPBAR1 = "/miniexpbar"
SlashCmdList.MINIEXPBAR = function(message)
    if not initialized then return end
    if (message or ""):lower():match("^%s*reset%s*$") then
        MiniExpBarDB.position = nil
        RestorePosition()
        UpdateWidth()
        UpdateExperience()
    else
        print("MiniExpBar: /miniexpbar reset - Restore the position below the minimap. Hold the left mouse button and drag to move the bar.")
    end
end
