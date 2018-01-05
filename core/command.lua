local _, Addon = ...; -- Namespace
Addon.Command = {};

local Util = Addon.Util;
local Command = Addon.Command;

--------------------------------------
-- Commands
--------------------------------------

Command.list = {
	["module"] = Addon.ModuleManager.Toggle,
	["list"] = Addon.ModuleManager.PrintList
};

----------------------------------
-- Logic
----------------------------------

function Command:Init(event, name)
	if (name ~= "Athenaeum") then
		return;
	end

	-- allows for arrow buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end

	-- shorthand for reloading UI
	SLASH_RELOADUI1 = "/rl";
	SlashCmdList.RELOADUI = ReloadUI;

	-- command for showing framestack tool
	SLASH_FRAMESTK1 = "/fs";
	SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
	end

 	-- addon root command
	SLASH_Athenaeum1 = "/at";
	SlashCmdList.Athenaeum = HandleCommand;
end

function HandleCommand(str)
	if (#str == 0) then
		 -- User just entered "/at" with no additional args.
		Util:Print("Command " .. Util:Colorize("/at", Util.Colors.command) .. " without any arguments is not valid.");
		return;
	end

	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end

	local path = Command.list; -- required for updating found table.

	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower();
			if (path[arg]) then
				if (type(path[arg]) == "function") then
					-- all remaining args passed to our function!
					path[arg](select(id, unpack(args)));
					return;
				elseif (type(path[arg]) == "table") then
					path = path[arg]; -- another sub-table found!
				end
			else
				Util:Print("Command " .. Util:Colorize("/at " .. str, Util.Colors.command) .. " does not exist.");
				return; -- does not exist!
			end
		end
	end
end

----------------------------------
-- Initialization hook
----------------------------------

local Events = CreateFrame("Frame");
Events:RegisterEvent("ADDON_LOADED");
Events:SetScript("OnEvent", Command.Init);
