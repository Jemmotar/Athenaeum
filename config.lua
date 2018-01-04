local _, core = ...; -- Namespace
core.Config = {}; -- adds Config table to addon namespace
local Config = core.Config;
local Util = core.Util;

--------------------------------------
-- Modules
--------------------------------------
Config.modules = {
	morph = {},
	gps = {}
}

function Config:ToggleModule(name)
	if Config.modules[name] == nil then
		return; -- Module not found
	end

	local module = Config.modules[name];

	-- Module used for first time
	if module.enabled == nil then
		module.enabled = false;
	end

	-- Toggle the module
	module.enabled = not module.enabled;

	-- Log result into the chat
	name = string.format("|cff%s%s|r", "FF6A00", name)
	if module.enabled then
		local state = string.format("|cff%s%s|r", "48D80A", "enabled")
		Util:Print("Module " .. name .. " was " .. state .. ".")
		module:Enable()
	else
		local state = string.format("|cff%s%s|r", "DB0000", "disabled")
		Util:Print("Module " .. name .. " was " .. state .. ".")
		module:Disable()
	end
end

function Config:PrintModules()
	Util:Print("Listing available modules...")
	for key, module in pairs(Config.modules) do
		local name = string.format("|cff%s%s|r", "FF6A00", key)
		DEFAULT_CHAT_FRAME:AddMessage("   " .. name .. " - " .. module:GetDescription())
	end
end
