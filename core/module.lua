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
	for moduleName, moduleWorkspace in pairs(modules) do
		-- At this point configuration is ready
		-- Injects config field into module workspace
		moduleWorkspace.config = GlobalConfiguration[moduleName];

		-- Enable all modules that are loaded with enabled flag set to true
		if moduleWorkspace.config.enabled then
			moduleWorkspace:Enable();
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

--------------------------------------
-- Command
--------------------------------------

function ModuleManager:Toggle(moduleName)
	if moduleName == nil then
		Util:Print("Command " .. Util:Colorize("/at module [name]", Util.Colors.command) .. " is not valid without module name as first argument.");
		return;
	end

	-- Get module config from workspace using it's name
	local config = ModuleManager:GetModuleWorkspace(moduleName).config;

	if config == nil then
		Util:Print("Module " .. Util:Colorize(moduleName, Util.Colors.module) .. " does not exist!");
		return; -- Module not found
	end

	-- Toggle the module
	config.enabled = not config.enabled;
	ModuleManager:GetModuleWorkspace(moduleName)[config.enabled and "Enable" or "Disable"]();
	ModuleManager:PrintStatusChange(moduleName, config.enabled);
end

function ModuleManager:PrintList()
	Util:Print("Listing available modules...");

	for name, module in pairs(modules) do
		DEFAULT_CHAT_FRAME:AddMessage("  " .. Util:Colorize(name, Util.Colors.module) .. " - " .. module:GetDescription());
	end
end

function ModuleManager:PrintStatusChange(moduleName, isEnabled)
	local enabledState = Util:Colorize(
		isEnabled and "enabled" or "disabled",
		isEnabled and Util.Colors.success or Util.Colors.failure
	);

	Util:Print("Module " .. Util:Colorize(moduleName, Util.Colors.module) .. " was " .. enabledState .. ".");
end
