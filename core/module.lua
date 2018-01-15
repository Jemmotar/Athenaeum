local _, Addon = ...; -- Namespace
Addon.ModuleManager = {};

local ModuleManager = Addon.ModuleManager;
local Config = Addon.Config;
local Util = Addon.Util;

--------------------------------------
-- Initialization
--------------------------------------

local modules = {};

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

function ModuleManager:GetModuleWorkspace(moduleName)
	if modules[moduleName] == nil then
		modules[moduleName] = {};
	end

	return modules[moduleName];
end

function ModuleManager:GetConfig(module)
	return GlobalConfiguration[module];
end

function ModuleManager:Toggle(module)
	if module == nil then
		Util:Print("Command " .. Util:Colorize("/at module [name]", Util.Colors.command) .. " is not valid without module name as first argument.");
		return;
	end

	local config = ModuleManager:GetConfig(module);

	if config == nil then
		Util:Print("Module " .. Util:Colorize(module, Util.Colors.module) .. " does not exist!");
		return; -- Module not found
	end

	-- Toggle the module
	config.enabled = not config.enabled;
	ModuleManager:GetModuleWorkspace(module)[config.enabled and "Enable" or "Disable"]();
	ModuleManager:PrintStatusChange(module, config.enabled);
end

function ModuleManager:PrintList()
	Util:Print("Listing available modules...");

	for name, module in pairs(modules) do
		DEFAULT_CHAT_FRAME:AddMessage("  " .. Util:Colorize(name, Util.Colors.module) .. " - " .. module:GetDescription());
	end
end

function ModuleManager:PrintStatusChange(module, enabled)
	local state = Util:Colorize(
		enabled and "enabled" or "disabled",
		enabled and Util.Colors.success or Util.Colors.failure
	);

	Util:Print("Module " .. Util:Colorize(module, Util.Colors.module) .. " was " .. state .. ".");
end
