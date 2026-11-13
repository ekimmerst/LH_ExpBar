local addonName = ...
local Addon = LH_ExpBar
local variables = {}

function Addon:RefreshSettings()
    if self.notifying or not Settings or not Settings.NotifyUpdate then return end
    self.notifying = true
    for _, variable in ipairs(variables) do Settings.NotifyUpdate(variable) end
    self.notifying = false
end

local function Command(message) SlashCmdList.LH_EXPBAR(message) end
local function Header(layout, text)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
end
local function Defaults()
    Command("lock")
    Command("reset")
    Addon:ResetQuestOptions()
end

local function ChooseQuestColor()
    if not ColorPickerFrame and C_AddOns and C_AddOns.LoadAddOn then C_AddOns.LoadAddOn("Blizzard_ColorPicker") end
    if not ColorPickerFrame and UIParentLoadAddOn then UIParentLoadAddOn("Blizzard_ColorPicker") end
    if not ColorPickerFrame then return end
    local r, g, b = Addon:GetQuestColor()
    local function Changed()
        Addon:SetQuestColor(ColorPickerFrame:GetColorRGB())
    end
    local function Cancelled()
        Addon:SetQuestColor(r, g, b)
    end
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, hasOpacity = false,
            swatchFunc = Changed, cancelFunc = Cancelled,
        })
    else
        ColorPickerFrame.func = Changed
        ColorPickerFrame.cancelFunc = Cancelled
        ColorPickerFrame.opacityFunc = nil
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.previousValues = { r = r, g = g, b = b }
        if ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker and ColorPickerFrame.Content.ColorPicker.SetColorRGB then
            ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
        elseif ColorPickerFrame.ColorPicker and ColorPickerFrame.ColorPicker.SetColorRGB then
            ColorPickerFrame.ColorPicker:SetColorRGB(r, g, b)
        elseif ColorPickerFrame.SetColorRGB then
            ColorPickerFrame:SetColorRGB(r, g, b)
        end
        ColorPickerFrame:Show()
    end
end

local function Build(category, layout)
    LH_LayoutProfiles:AddSetting(category, layout, addonName)
    Header(layout, "Quest experience")
    local showQuestXP = Settings.RegisterProxySetting(category, "LH_ExpBar_showQuestXP", "boolean", "Show completed quest XP", false,
        function() return Addon:IsQuestXPShown() end,
        function(value) Addon:SetQuestXPShown(value) end)
    variables[#variables + 1] = "LH_ExpBar_showQuestXP"
    Settings.CreateCheckbox(category, showQuestXP,
        "Show the XP from completed quests still in your quest log as a colored segment after current XP. Saved per character.")
    local questColor = Settings.RegisterProxySetting(category, "LH_ExpBar_questColor", "string", "Completed quest XP color", "ff8ce673",
        function()
            local r, g, b = Addon:GetQuestColor()
            return CreateColor(r, g, b, 1):GenerateHexColor()
        end,
        function(value)
            local color = CreateColorFromHexString(value)
            Addon:SetQuestColor(color:GetRGB())
        end)
    variables[#variables + 1] = "LH_ExpBar_questColor"
    Settings.CreateColorSwatch(category, questColor,
        "Color of the completed quest XP segment. Saved per character.")
    layout:AddInitializer(CreateSettingsButtonInitializer("Choose the completed quest XP color", "Choose color",
        ChooseQuestColor, "Open the color picker for the completed quest XP segment.", true))
    Header(layout, "Positioning")
    local variable = "LH_ExpBar_locked"
    variables[#variables + 1] = variable
    local locked = Settings.RegisterProxySetting(category, variable, "boolean", "Lock experience bar", true,
        function() return not Addon:IsUnlocked() end,
        function(value) Command(value and "lock" or "unlock") end)
    Settings.CreateCheckbox(category, locked,
        "Disable to drag the bar or resize it with the circle below its right edge. Enable to lock it and show the XP tooltip on hover. A preview remains available at maximum level while unlocked. Saved per character.")
    for _, option in ipairs({{key = "widthFactor", label = "Bar width"}, {key = "heightFactor", label = "Bar height"}}) do
        local key = option.key
        local name = "LH_ExpBar_" .. key
        variables[#variables + 1] = name
        local setting = Settings.RegisterProxySetting(category, name, "number", option.label, 100,
            function() return Addon:GetSizeFactor(key) * 100 end,
            function(value) Addon:SetSizeFactor(key, value / 100) end)
        local options = Settings.CreateSliderOptions(50, 200, 5)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return string.format("%.0f%%", value) end)
        Settings.CreateSlider(category, setting, options,
            (key == "widthFactor" and "Width relative to the minimap; minimum width is 70 UI units." or "Height relative to the default 20 UI units.") .. " Font size stays at 12 points. Saved per character.")
    end
    layout:AddInitializer(CreateSettingsButtonInitializer("Restore the default size and position", "Reset layout",
        function() Command("reset") end,
        "Restore minimap width, 20 UI units of height and the position below the minimap coordinates. Keep the current lock setting.", true))
    EventRegistry:RegisterCallback("Settings.CategoryDefaulted", function(_, selected)
        if selected == category then Defaults() end
    end, Addon)
    EventRegistry:RegisterCallback("Settings.Defaulted", Defaults, Addon)
end

LH_Tweaks:RegisterModule(addonName, "LH ExpBar", Build)
