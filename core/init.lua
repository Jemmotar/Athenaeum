local _, Addon = ...; -- Namespace
Addon.Init = {};

local Init = Addon.Init;

----------------------------------
-- Initialization
----------------------------------

local Parts = {
	Addon.Config,
	Addon.ModuleManager,
	Addon.Command
};

function Init:InitializeAddon(event, name)
	if name ~= "Athenaeum" then
		return;
	end

	-- allows for arrow buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end

	-- Initialize addon parts one by one
	for _, part in pairs(Parts) do
		part:Init();
	end
end

----------------------------------
-- Initialization hook
----------------------------------

local Events = CreateFrame("Frame");
Events:RegisterEvent("ADDON_LOADED");
Events:SetScript("OnEvent", Init.InitializeAddon);
