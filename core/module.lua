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

function ModuleManager:Init()
	-- Enable all modules that are loaded with enabled flag set to true
	for name,module in pairs(modules) do
		if ModuleManager:GetConfig(name).enabled then
			module:Enable();
		end
	end
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
	if name == nil then
		Util:Print("Command " .. Util:Colorize("/at module", Util.Colors.command) .. " is not valid without module name as first argument.");
		return;
	end

	local config = ModuleManager:GetConfig(name);

	if config == nil then
		Util:Print("Module " .. Util:Colorize(name, Util.Colors.module) .. " does not exist!");
		return; -- Module not found
	end

	-- Toggle the module
	config.enabled = not config.enabled;
	ModuleManager:GetModule(name)[config.enabled and "Enable" or "Disable"]();
	ModuleManager:PrintStatusChange(name, config.enabled);
end

function ModuleManager:PrintList()
	Util:Print("Listing available modules...");

	for name, module in pairs(modules) do
		DEFAULT_CHAT_FRAME:AddMessage("  " .. Util:Colorize(name, Util.Colors.module) .. " - " .. module:GetDescription());
	end
end

function ModuleManager:PrintStatusChange(name, enabled)
	local state = Util:Colorize(
		enabled and "enabled" or "disabled",
		enabled and Util.Colors.success or Util.Colors.failure
	);

	Util:Print("Module " .. Util:Colorize(name, Util.Colors.module) .. " was " .. state .. ".");
end
