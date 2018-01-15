local _, Addon = ...; -- Namespace

local Module = Addon.ModuleManager:GetModuleWorkspace("morph");

--------------------------------------
-- Module
--------------------------------------

local UIFrame;
local MorphModelId = 0;

function Module:GetDescription()
	return "User interface for .morph command";
end

function Module:Enable()
	local ui = UIFrame or Module:CreateUIFrame();
	ui:Show();
end

function Module:Disable()
	local ui = UIFrame or Module:CreateUIFrame();
	ui:Hide();
end

function Module.OnConfigChange(propertyName, propertyValue)
	if propertyName == "x" or propertyName == "y" then
		UIFrame:SetPoint("LEFT", UIParent, "LEFT", Module.config.x, Module.config.y);
	end
end

--------------------------------------
-- UI
--------------------------------------

function Module:CreateUIFrame()
	-- Wrapper
	UIFrame = CreateFrame("Frame", "AT_MORPH");
	UIFrame:SetPoint("LEFT", UIParent, "LEFT", Module.config.x, Module.config.y);
	UIFrame:SetSize(48, 128);

	-- Model Id input
	UIFrame.Input = CreateFrame("EditBox", "AT_INPUT", UIFrame, "InputBoxTemplate");
	UIFrame.Input:SetPoint("CENTER", UIFrame, "CENTER");
	UIFrame.Input:SetWidth(48);
	UIFrame.Input:SetHeight(24);
	UIFrame.Input:SetNumeric(true);
	UIFrame.Input:SetNumber(MorphModelId);
	UIFrame.Input:SetScript("OnEnterPressed", function(self)
		Module:ExecMorph(UIFrame.Input:GetNumber());
	end);

	-- Controls
	UIFrame.ButtonPlus = Module:CreateUIControl(UIFrame, 0, 25, "+");
	UIFrame.ButtonPlus:SetScript("OnMouseUp", function(self, button)
		Module:ExecMorph(MorphModelId + (button == "LeftButton" and Module.config.step or Module.config.jump));
	end);

	UIFrame.ButtonMinus = Module:CreateUIControl(UIFrame, 0, -24, "-");
	UIFrame.ButtonMinus:SetScript("OnMouseUp", function(self, button)
		Module:ExecMorph(MorphModelId - (button == "LeftButton" and Module.config.step or Module.config.jump));
	end);

	UIFrame:Hide();
	return UIFrame;
end

function Module:CreateUIControl(parent, x, y, text)
	local control = CreateFrame("Button", "AT_CONTROL_" .. text, parent, "UIPanelButtonTemplate");
	control:SetPoint("CENTER", parent, "CENTER", x, y);
	control:SetWidth(32);
	control:SetHeight(24);
	control:SetText(text);
	control:RegisterForClicks("LeftButtonUp, RightButtonUp");
	return control;
end

--------------------------------------
-- Logic
--------------------------------------

function Module:ExecMorph(id)
	if id < 0 then
		id = 0;
	end

	if MorphModelId ~= id then
		MorphModelId = id;
		UIFrame.Input:SetNumber(id);
		UIFrame.Input:ClearFocus();
		SendChatMessage(".morph " .. id);
	end
end
