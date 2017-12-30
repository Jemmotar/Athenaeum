local _, core = ...; -- Namespace

--------------------------------------
-- Slash Commands
--------------------------------------
core.commands = {
	["module"] = core.Config.ToggleModule,
	["list"] = core.Config.PrintModules
};

local function HandleSlashCommands(str)
	if (#str == 0) then
		return; -- User just entered "/at" with no additional args.
	end

	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end

	local path = core.commands; -- required for updating found table.

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
-- Addon Initialization
----------------------------------

function core:init(event, name)
	if (name ~= "Athenaeum") then return end

	-- allows using left and right buttons to move through the chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end

	-- Register Slash Commands!
	SLASH_RELOADUI1 = "/rl"; -- shorthand for reloading UI
	SlashCmdList.RELOADUI = ReloadUI;

	SLASH_FRAMESTK1 = "/fs"; -- command for showing framestack tool
	SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
	end

	SLASH_Athenaeum1 = "/at"; -- main addon command
	SlashCmdList.Athenaeum = HandleSlashCommands;
end

----------------------------------
-- Initialization hook
----------------------------------

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", core.init);
