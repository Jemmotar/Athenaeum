local _, Addon = ...; -- Namespace
Addon.Command = {};

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

	SLASH_RELOADUI1 = "/rl"; -- shorthand for reloading UI
	SlashCmdList.RELOADUI = ReloadUI;

	SLASH_FRAMESTK1 = "/fs"; -- command for showing framestack tool
	SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
	end

	SLASH_Athenaeum1 = "/at"; -- addon root command
	SlashCmdList.Athenaeum = HandleCommand;
end

function HandleCommand(str)
	if (#str == 0) then
		return; -- User just entered "/at" with no additional args.
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
				return; -- does not exist!
			end
		end
	end
end

----------------------------------
-- Initialization hook
----------------------------------

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", Command.Init);
