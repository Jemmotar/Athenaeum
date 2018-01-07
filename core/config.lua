local _, Addon = ...; -- Namespace
Addon.Config = {};

local ModuleManager = Addon.ModuleManager;
local Config = Addon.Config;
local Util = Addon.Util;

--------------------------------------
-- Configuration
--------------------------------------

Config.Subscribers = {};

Config.Properties = {
	morph = {
		{ name = "enabled",     default = false, isConfigurable = false, isPreserved = false },
		{ name = "frameX",      default = 10,    isConfigurable = true,  isPreserved = true  },
		{ name = "frameY",      default = 250,   isConfigurable = true,  isPreserved = true  }
	},
	gps = {
		{ name = "enabled",     default = false, isConfigurable = false, isPreserved = false },
		{ name = "refreshRate", default = 3,     isConfigurable = true,  isPreserved = true  },
		{ name = "accuracy",    default = 2,     isConfigurable = true,  isPreserved = true  },
		{ name = "frameX",      default = -148,  isConfigurable = true,  isPreserved = true  },
		{ name = "frameY",      default = -124,  isConfigurable = true,  isPreserved = true  }
	}
}

function Config:Init()
	-- Create saved variable object for config (first time addon is instaled)
	if GlobalConfiguration == nil then
		GlobalConfiguration = {};
	end

	for module,presets in pairs(Config.Properties) do
		-- If module does not have config namespace, create it
		if GlobalConfiguration[module] == nil then
			GlobalConfiguration[module] = {};
		end

		-- Go trough all module presets
		for _,property in pairs(presets) do
			-- If saved config does not have preset variable set it do preset default
			-- Saved variable can be also set to preset default by isPreserved flag
			if GlobalConfiguration[module][property.name] == nil or isPreserved == false then
				GlobalConfiguration[module][property.name] = property.default;
			end
		end
	end
end

function Config:GetProperty(module, propertyName)
	for _,property in pairs(Config.Properties[module]) do
		if property.name == propertyName then
			return property;
		end
	end

	return nil;
end

function Config:SubscribePropertyChange(moduleName, subscriber)
	if Config.Subscribers[moduleName] == nil then
		Config.Subscribers[moduleName] = {};
	end

	table.insert(Config.Subscribers[moduleName], subscriber);
end

function Config:EmittPropertyChange(moduleName, propertyName)
	local propertyValue = GlobalConfiguration[moduleName][propertyName];

	for _,subscriber in ipairs(Config.Subscribers[moduleName]) do
		subscriber(propertyName, propertyValue);
	end
end

--------------------------------------
-- Command
--------------------------------------

function Config:PrintAllConfigs()
	for module,_ in pairs(GlobalConfiguration) do
		Config:PrintModuleConfig(module);
	end
end

function Config:PrintModuleConfig(moduleName)
	for _,property in pairs(Config.Properties[moduleName]) do
		Config:PrintPropertyConfig(moduleName, property.name);
	end
end

function Config:PrintPropertyConfig(moduleName, propertyName)
	if Config:GetProperty(moduleName, propertyName).isConfigurable then
		local value = GlobalConfiguration[moduleName][propertyName];
		print("  " ..  Util:Colorize(moduleName, Util.Colors.module) .. "." .. Util:Colorize(propertyName, Util.Colors.property) .. " = " .. tostring(value));
	end
end

function Config:HandleConfigCommand(moduleName, propertyName, propertyValue)
	if moduleName == nil then
		Util:Print("Listing configuration for all modules...");
		Config:PrintAllConfigs();
		return;
	end

	if GlobalConfiguration[moduleName] == nil then
		Util:Print("Module " .. Util:Colorize(moduleName, Util.Colors.module) .. " does not exist!");
		return;
	end

	if propertyName == nil then
		Util:Print("Listing configuration for module " .. Util:Colorize(moduleName, Util.Colors.module) .. "...");
		Config:PrintModuleConfig(moduleName);
		return;
	end

	if GlobalConfiguration[moduleName][propertyName] == nil then
		Util:Print("Module " .. Util:Colorize(moduleName, Util.Colors.module) .. " does not have property " .. Util:Colorize(propertyName, Util.Colors.property) .. ".");
		return;
	end

	if propertyValue == nil then
		Config:PrintPropertyConfig(moduleName, propertyName);
		return;
	end

	local propertyEntry = Config:GetProperty(moduleName, propertyName);
	if propertyEntry.isConfigurable == false then
		return;
	end

	if propertyValue == "default" then
		GlobalConfiguration[moduleName][propertyName] = propertyEntry.default;
		Config:EmittPropertyChange(moduleName, propertyName);
		Util:Print("Property " ..  Util:Colorize(moduleName, Util.Colors.module) .. "." .. Util:Colorize(propertyName, Util.Colors.property) .. " was set to " .. Util:Colorize("default (" .. tostring(propertyEntry.default) .. ")", Util.Colors.success) .. " value.");
		return;
	end

	local desiredType = type(propertyEntry.default);
	if (desiredType == type(propertyValue)) or (desiredType == "number" and tonumber(propertyValue) ~= nil) or (desiredType == "boolean" and (propertyValue == "true" or propertyValue == "false")) then
		if desiredType == "number" then
			propertyValue = tonumber(propertyValue);
		elseif desiredType == "boolean" then
			propertyValue = propertyValue == "true" and true or false;
		end

		GlobalConfiguration[moduleName][propertyName] = propertyValue;
		Config:EmittPropertyChange(moduleName, propertyName);
		Util:Print("Property " ..  Util:Colorize(moduleName, Util.Colors.module) .. "." .. Util:Colorize(propertyName, Util.Colors.property) .. " was set to " .. Util:Colorize(tostring(propertyValue), Util.Colors.success) .. ".");
	else
		Util:Print("Property " .. Util:Colorize(propertyName, Util.Colors.property) .. " supports only " .. Util:Colorize(desiredType, Util.Colors.failure) .. " value type.");
	end
end
