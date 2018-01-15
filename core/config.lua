local _, Addon = ...; -- Namespace
Addon.Config = {};

local ModuleManager = Addon.ModuleManager;
local Config = Addon.Config;
local Util = Addon.Util;

--------------------------------------
-- Configuration
--------------------------------------

Config.Properties = {
	morph = {
		{
			name = "x",
			default = 10
		},
		{
			name = "y",
			default = 250
		},
		{
			name = "step",
			default = 1,
			validate = Util.Validation.IsPositive
		},
		{
			name = "jump",
			default = 10,
			validate = Util.Validation.IsPositive
		}
	},
	gps = {
		{
			name = "x",
			default = -148
		},
		{
			name = "y",
			default = -124
		},
		{
			name = "refresh",
			default = 3,
			validate = Util.Validation.IsPositive
		},
		{
			name = "accuracy",
			default = 2,
			validate = Util.Validation.IsPositive
		},
		{
			name = "show-x",
			default = true
		},
		{
			name = "show-y",
			default = true
		},
		{
			name = "show-z",
			default = true
		},
		{
			name = "show-orientation",
			default = true
		},
		{
			name = "show-target",
			default = true
		}
	}
}

Config.PropertyEnabled = {
	name = "enabled",
	default = false,
	isConfigurable = false,
	isPreserved = false
};

Config.DefaultPropertyKeys = {
	isConfigurable = true,
	isPreserved = true
};

function Config:Init()
	-- Create saved variable object for config (first time addon is instaled)
	if GlobalConfiguration == nil then
		GlobalConfiguration = {};
	end

	for moduleName, moduleProperties in pairs(Config.Properties) do
		local hasEnabledProperty = false;

		for _, moduleProperty in pairs(moduleProperties) do
			if moduleProperty.name == "enabled" then
				hasEnabledProperty = true;
			end

			-- Make sure every property has default keys
			-- If not, copy them from DefaultPropertyKeys
			for defaultPropertyKey, defaultPropertyValue in pairs(Config.DefaultPropertyKeys) do
				if moduleProperty[defaultPropertyKey] == nil then
					moduleProperty[defaultPropertyKey] = defaultPropertyValue;
				end
			end
		end

		-- Make sure every module has enabled property
		-- If not, use default enabled property
		if not hasEnabledProperty then
			table.insert(moduleProperties, Config.PropertyEnabled);
		end
	end

	for moduleName, moduleProperties in pairs(Config.Properties) do
		-- If module does not have config namespace, create it
		if GlobalConfiguration[moduleName] == nil then
			GlobalConfiguration[moduleName] = {};
		end

		-- Go trough all module properties
		for _,moduleProperty in pairs(moduleProperties) do
			-- If saved config does not have preset variable set it do preset default
			-- Saved variable can be also set to preset default by isPreserved flag
			if GlobalConfiguration[moduleName][moduleProperty.name] == nil or (not moduleProperty.isPreserved) then
				GlobalConfiguration[moduleName][moduleProperty.name] = moduleProperty.default;
			end
		end
	end
end

function Config:GetProperty(moduleName, propertyName)
	for _, moduleProperty in pairs(Config.Properties[moduleName]) do
		if moduleProperty.name == propertyName then
			return moduleProperty;
		end
	end

	return nil;
end

--------------------------------------
-- Events
--------------------------------------

Config.Subscribers = {};

function Config:SubscribePropertyChange(moduleName, subscriber)
	if Config.Subscribers[moduleName] == nil then
		Config.Subscribers[moduleName] = {};
	end

	table.insert(Config.Subscribers[moduleName], subscriber);
end

function Config:EmittPropertyChange(moduleName, propertyName)
	local propertyValue = GlobalConfiguration[moduleName][propertyName];
	local moduleSubscribers = Config.Subscribers[moduleName];

	-- Dispatch change to modules that have OnConfigChange method in workspace
	-- Modules without this method will be ignored


	-- Dispatch change to subscribers
	if moduleSubscribers ~= nil then
		for _,subscriber in pairs(moduleSubscribers) do
			subscriber(propertyName, propertyValue);
		end
	end
end

--------------------------------------
-- Command
--------------------------------------

function Config:PrintAllConfigs()
	for moduleName, _ in pairs(GlobalConfiguration) do
		Config:PrintModuleConfig(moduleName);
	end
end

function Config:PrintModuleConfig(moduleName)
	for _, moduleProperty in pairs(Config.Properties[moduleName]) do
		if Config:GetProperty(moduleName, moduleProperty.name).isConfigurable then
			local propertyValue = GlobalConfiguration[moduleName][moduleProperty.name];
			print("  " ..  Util:Colorize(moduleName, Util.Colors.module) .. "." .. Util:Colorize(moduleProperty.name, Util.Colors.property) .. " = " .. tostring(propertyValue));
		end
	end
end

function Config:PrintPropertyConfig(moduleName, propertyName)
	local propertyValue = GlobalConfiguration[moduleName][propertyName];
	Util:Print("Property " .. Util:Colorize(moduleName, Util.Colors.module) .. "." .. Util:Colorize(propertyName, Util.Colors.property) .. " is set to " .. tostring(propertyValue));
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

		-- If property has validation, test it
		if propertyEntry.validate ~= nil then
			if not propertyEntry.validate.test(propertyValue) then
				Util:Print("Property " .. Util:Colorize(moduleName, Util.Colors.module) .. "." .. Util:Colorize(propertyName, Util.Colors.property) .. " accepts only " .. Util:Colorize(propertyEntry.validate.name, Util.Colors.failure) .. ".");
				return;
			end
		end

		GlobalConfiguration[moduleName][propertyName] = propertyValue;
		Config:EmittPropertyChange(moduleName, propertyName);
		Util:Print("Property " ..  Util:Colorize(moduleName, Util.Colors.module) .. "." .. Util:Colorize(propertyName, Util.Colors.property) .. " was set to " .. Util:Colorize(tostring(propertyValue), Util.Colors.success) .. ".");
	else
		Util:Print("Property " .. Util:Colorize(moduleName, Util.Colors.module) .. "." .. Util:Colorize(propertyName, Util.Colors.property) .. " supports only " .. Util:Colorize(desiredType, Util.Colors.failure) .. " value type.");
	end
end
