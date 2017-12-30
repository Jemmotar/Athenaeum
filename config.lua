--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Config = {}; -- adds Config table to addon namespace
local Config = core.Config;

--------------------------------------
-- Utilities
--------------------------------------

function core:Print(...)
	local prefix = string.format("|cff%s%s|r", "00ccff", "[Athenaeum]")
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...))
end

--------------------------------------
-- Modules
--------------------------------------
Config.modules = {
	morph = {
		enabled = false
	}
}

function Config:ToggleModule(name)
	if Config.modules[name] == nil then
		return; -- Module not found
	end

	local module = Config.modules[name];
	module.enabled = not module.enabled;

	name = string.format("|cff%s%s|r", "FF6A00", name)

	if module.enabled then
		local state = string.format("|cff%s%s|r", "48D80A", "enabled")
		core:Print("Module " .. name .. " was " .. state .. ".")
		module:Enable()
	else
		local state = string.format("|cff%s%s|r", "DB0000", "disabled")
		core:Print("Module " .. name .. " was " .. state .. ".")
		module:Disable()
	end
end

function Config:PrintModules()
	core:Print("Listing available modules...")
	for key, module in pairs(Config.modules) do
		local name = string.format("|cff%s%s|r", "FF6A00", key)
		DEFAULT_CHAT_FRAME:AddMessage("   " .. name .. " - " .. module:GetDescription())
	end
end
