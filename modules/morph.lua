local _, core = ...; -- Namespace
local Module = core.ModuleManager:GetModule("morph");

--------------------------------------
-- Module
--------------------------------------

local UIFrame;
local MorphModelId = 0;

function Module:GetDescription()
	return "User interface for .morph command";
end

function Module:Enable()
	local overlay = UIFrame or Module:CreateUIFrame();
	overlay:Show();
end

function Module:Disable()
	UIFrame:Hide();
end

--------------------------------------
-- Logic
--------------------------------------

function Module:ExecMorph(id)
	if MorphModelId ~= id then
		MorphModelId = id;
	end

	UIFrame.Input:SetNumber(id);
	UIFrame.Input:ClearFocus();
	SendChatMessage(".morph " .. id);
end

--------------------------------------
-- UI
--------------------------------------

function Module:CreateUIFrame()
	UIFrame = CreateFrame("Frame", "AT_MORPH");
	UIFrame:SetPoint("LEFT", UIParent, "LEFT", 10, 250);
	UIFrame:SetSize(48, 128);

	UIFrame.Input = CreateFrame("EditBox", "AT_INPUT", UIFrame, "InputBoxTemplate");
	UIFrame.Input:SetPoint("CENTER", UIFrame, "CENTER");
	UIFrame.Input:SetWidth(48);
	UIFrame.Input:SetHeight(24);
	UIFrame.Input:SetNumeric(true);
	UIFrame.Input:SetNumber(MorphModelId);
	UIFrame.Input:SetScript("OnEnterPressed", function(self)
		Module:ExecMorph(UIFrame.Input:GetNumber());
	end);

	UIFrame.ButtonPlus = CreateFrame("Button", "AT_BTN_PLUS", UIFrame, "UIPanelButtonTemplate");
	UIFrame.ButtonPlus:SetPoint("CENTER", UIFrame, "CENTER", 0, 25);
	UIFrame.ButtonPlus:SetWidth(32);
	UIFrame.ButtonPlus:SetHeight(24);
	UIFrame.ButtonPlus:SetText("+");
	UIFrame.ButtonPlus:RegisterForClicks("LeftButtonUp, RightButtonUp");
	UIFrame.ButtonPlus:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			MorphModelId = MorphModelId + 1;
		else
			MorphModelId = MorphModelId + 10;
		end
		Module:ExecMorph(MorphModelId);
	end);

	UIFrame.ButtonMinus = CreateFrame("Button", "ADD_BTN_MINUS", UIFrame, "UIPanelButtonTemplate");
	UIFrame.ButtonMinus:SetPoint("CENTER", UIFrame, "CENTER", 0, -24);
	UIFrame.ButtonMinus:SetWidth(32);
	UIFrame.ButtonMinus:SetHeight(24);
	UIFrame.ButtonMinus:SetText("-");
	UIFrame.ButtonMinus:RegisterForClicks("LeftButtonUp, RightButtonUp");
	UIFrame.ButtonMinus:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			if MorphModelId > 0 then
				MorphModelId = MorphModelId - 1;
			end
		else
			if MorphModelId > 10 then
				MorphModelId = MorphModelId - 10;
			else
				MorphModelId = 0;
			end
		end
		Module:ExecMorph(MorphModelId);
	end);

	UIFrame:Hide();
	return UIFrame;
end
