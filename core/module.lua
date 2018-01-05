local _, Addon = ...; -- Namespace
Addon.ModuleManager = {};

local ModuleManager = Addon.ModuleManager;
local Config = Addon.Config;
local Util = Addon.Util;

--------------------------------------
-- Initialization
--------------------------------------

local modules = {};
-- Copy keys for the list from config
-- This creates workspace for every module defined in config
for key,_ in pairs(Config.modules) do
	modules[key] = {};
end

--------------------------------------
-- Modules
--------------------------------------

function ModuleManager:GetModule(name)
	return modules[name];
end

function ModuleManager:GetConfig(name)
	return Config.modules[name];
end

function ModuleManager:Toggle(name)
	local config = ModuleManager:GetConfig(name);

	if config == nil then
		return; -- Module not found
	end

	-- Toggle the module
	config.enabled = not config.enabled;
	ModuleManager:GetModule(name)[config.enabled and "Enable" or "Disable"]();
	PrintStatusChange(name, config);
end

function ModuleManager:PrintList()
	Util:Print("Listing available modules...");

	for key, module in pairs(modules) do
		local name = string.format("|cff%s%s|r", "FF6A00", key);
		DEFAULT_CHAT_FRAME:AddMessage("  " .. name .. " - " .. module:GetDescription());
	end
end

--------------------------------------
-- Local
--------------------------------------

function PrintStatusChange(name, config)
	local name = string.format("|cff%s%s|r", "FF6A00", name);
	local state = string.format(
		"|cff%s%s|r",
		config.enabled and "48D80A" or "DB0000",
		config.enabled and "enabled" or "disabled"
	);

	Util:Print("Module " .. name .. " was " .. state .. ".");
end
