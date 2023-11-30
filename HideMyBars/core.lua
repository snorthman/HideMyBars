local bars = {
    MainMenuBar,
	_G["MultiBarLeft"], 
	_G["MultiBarRight"], 
	_G["MultiBarBottomLeft"],
	_G["MultiBarBottomRight"],
	_G["MultiBar5"],
	_G["MultiBar6"],
	_G["MultiBar7"],
}
local modifiers = { 
	{"CTRL", IsControlKeyDown},
	{"SHIFT", IsShiftKeyDown},
	{"ALT", IsAltKeyDown}
}
local panels = {
	{"Character Info", CharacterFrame},
	{"Specialization & Talents", ClassTalentFrame},
	{"Spell Book & Professions", SpellBookFrame}
}
local optionsEnabled = {}
local optionsBarsEnabled = {}
local optionsModifiersEnabled = {}
local optionsPanelsEnabled = {}

local function onAddonLoaded()
    if not HideMyBarsSavedSettings then
        HideMyBarsSavedSettings = {
			disabled = false,
			barsEnabled = {true, true, true, true, true, true, true, true},
			modifiersEnabled = {true, false, false},
			panelsEnabled = {true, true, true}
		}  
    end
end

local addonLoadedFrame = CreateFrame("Frame")
addonLoadedFrame:RegisterEvent("ADDON_LOADED")
addonLoadedFrame:SetScript("OnEvent", onAddonLoaded)


local function updateBarSettings() 
	for i = 1, #bars do
		local enabled = HideMyBarsSavedSettings.barsEnabled[i]
		
		optionsBarsEnabled[i]:SetChecked(enabled)
		if not enabled or HideMyBarsSavedSettings.disabled then
			bars[i]:Show()
		else
			bars[i]:Hide()
		end
	end
end


local optionsPanel = CreateFrame("Frame", "HideMyBarsOptionsPanel", InterfaceOptionsFramePanelContainer)
optionsPanel.name = "HideMyBars"
InterfaceOptions_AddCategory(optionsPanel)
optionsPanel:SetScript("OnShow", function(self)
	optionsEnabled:SetChecked(HideMyBarsSavedSettings.disabled)
	updateBarSettings()
	
	for i = 1, #modifiers do
		optionsModifiersEnabled[i]:SetChecked(HideMyBarsSavedSettings.modifiersEnabled[i])
	end
	for i = 1, #panels do
		optionsPanelsEnabled[i]:SetChecked(HideMyBarsSavedSettings.panelsEnabled[i])
	end
end)


local function createCheckOption(label, x, y, text, func)
    local checkButton = CreateFrame("CheckButton", label, optionsPanel, "UICheckButtonTemplate")
    checkButton:SetPoint("TOPLEFT", x, y)
    checkButton.text:SetText(text)
	if func then 
		checkButton:SetScript("OnClick", func)
	else
		checkButton:Disable()
	end
    return checkButton
end


local barSpacing = 0
optionsEnabled = createCheckOption("EnableCheckbox", 10, -20 + barSpacing, "Disable HideMyBars", function(self) 
	HideMyBarsSavedSettings.disabled = self:GetChecked() 
	updateBarSettings()
end)
barSpacing = barSpacing - 24


for i = 1, #bars do
	optionsBarsEnabled[i] = createCheckOption("EnableMultiBarCheckbox" .. i, 10, -40 + barSpacing, "Action Bar " .. i, function(self)
		if self:GetChecked() then
			HideMyBarsSavedSettings.barsEnabled[i] = true
			if not HideMyBarsSavedSettings.disabled then
				bars[i]:Hide()
			end
		else
			HideMyBarsSavedSettings.barsEnabled[i] = false
			bars[i]:Show()
		end
	end)
	barSpacing = barSpacing - 24
end

for i = 1, #modifiers do
	local modifier = modifiers[i][1]
	local func = function(self) HideMyBarsSavedSettings.modifiersEnabled[i] = self:GetChecked() end
	optionsModifiersEnabled[i] = createCheckOption("Enable" .. modifier, 10, -60 + barSpacing, "Hold " .. modifier .. " to show", func)
	barSpacing = barSpacing - 24
end

for i = 1, #panels do
	local panel = panels[i][1]
	local func = function(self) HideMyBarsSavedSettings.panelsEnabled[i] = self:GetChecked() end
	if i > 2 then
		func = false
	end
	optionsPanelsEnabled[i] = createCheckOption("Enable" .. panel, 10, -80 + barSpacing, "Show when " .. panel .. " panel is visible", func)
	barSpacing = barSpacing - 24
end


local function updateActionBars()
	local showBars = false
	for i = 1, #panels do
		if HideMyBarsSavedSettings.panelsEnabled[i] then
			local panel = panels[i][2]			
			
			if i == 2 and ClassTalentFrame then
				panels[i][2] = ClassTalentFrame
			end
			
			if panel and panel:IsShown() then
				showBars = true
				break
			end
		end
	end
					 
	if not showBars then 
		for i = 1, #modifiers do 
			if HideMyBarsSavedSettings.modifiersEnabled[i] then
				if modifiers[i][2]() then
					showBars = true
					break
				end
			end
		end
	end

	for i = 1, #bars do	
		if bars[i] and HideMyBarsSavedSettings.barsEnabled[i] then
			if showBars then
				bars[i]:Show()
			else
				bars[i]:Hide()
			end
		end
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnUpdate", function(self, elapsed)
	if not HideMyBarsSavedSettings.disabled then
		updateActionBars()
	end
end)
