local _, core = ...; -- Namespace
local Util = core.Util;
local Module = core.Config.modules.gps;

--------------------------------------
-- Module
--------------------------------------

local OriginalChatHandler;
local UIFrame;
local Data = {
	{ key = "X",           value = 0, visible = true },
	{ key = "Y",           value = 0, visible = true },
	{ key = "Z",           value = 0, visible = true },
	{ key = "Orientation", value = 0, visible = true }
};

function Module:GetDescription()
  return "User interface for .gps command";
end

function Module:Enable()
	if OriginalChatHandler == nil then
		OriginalChatHandler = ChatFrame_MessageEventHandler;
	end

	-- Hijack chat frame event dispatcher
	ChatFrame_MessageEventHandler = ChatFrameMiddleware;

	local frame = UIFrame or CreateUIFrame();
	frame:Show();
end

function Module:Disable()
	-- Remove our middleware from chat
	ChatFrame_MessageEventHandler = OriginalChatHandler;

	UIFrame:Hide();
end

--------------------------------------
-- Logic
--------------------------------------

function SetModuleData(key, value)
	for _, entry in pairs(Data) do
		if entry.key == key then
			entry.value = value;
			return;
		end
	end
end

function ChatFrameMiddleware(event, ...)
	if Module.enabled then
		if HandleChatMessage(...) then
			return; -- Allow for stoping message propagation
		end
	end

	-- Dispach original events after it is handled by addon
	return OriginalChatHandler(event, ...);
end

function IsGpsMessage(type, message)
	return type == "CHAT_MSG_SYSTEM" and (
		Util:StartsWith(message, "no VMAP") or -- I know, this could be looped in list but I don't think .gps command will change any time soon
		Util:StartsWith(message, "Map:") or
		Util:StartsWith(message, "grid[") or
		Util:StartsWith(message, "X: ") or
		Util:StartsWith(message, " ZoneX:") or
		Util:StartsWith(message, "GroundZ:")
	);
end

function HandleChatMessage(type, message)
	if IsGpsMessage(type, message) then
			-- We care about coordiantes
			if Util:StartsWith(message, "X: ") then
				local raw = Util:Split(message, " ");
				SetModuleData("X", raw[2]);
				SetModuleData("Y", raw[4]);
				SetModuleData("Z", raw[6]);
				SetModuleData("Orientation", raw[8]);
				UpdateUIFrame();
			end

			-- When module is enabled we will not show any .gps message in chat
			-- this gets rid of command spam
			return true;
	end

	return false;
end

--------------------------------------
-- UI
--------------------------------------

function CreateUIFrame()
	UIFrame = CreateFrame("Frame", "AT_GPS");
	UIFrame:SetPoint("RIGHT", UIParent, "RIGHT", 0, 200);
	UIFrame:SetSize(155, 64);

	UIFrame.text = UIFrame:CreateFontString(UIFrame:GetName() .. "_TEXT", "OVERLAY", "GameFontNormal");
	UIFrame.text:SetAllPoints();
	UIFrame.text:SetText("");

	-- Create timer that will periodicly send .gps commdns via chat
	-- No need to worry about stoping the timer, it will tick only when main frame is visible
	UIFrame.interval = CreateFrame("Frame", UIFrame:GetName() .. "_INTERVAL", UIFrame);
	UIFrame.interval.value = 3; -- Update internal in seconds
	UIFrame.interval:SetScript("OnUpdate", function(self, elapsed)
	    self.elapsed = (self.elapsed or 0) + elapsed;
	    if self.elapsed >= self.value then
					SendChatMessage(".gps");
	        self.elapsed = 0;
	    end
	end)
	UIFrame.interval:Show();

	-- Get initial data
	SendChatMessage(".gps");

	UIFrame:Hide();
	return UIFrame;
end

function UpdateUIFrame()
	local text = "";

	for _, entry in pairs(Data) do
		if entry.visible then
			text = text .. entry.key .. ": " .. Util:Round(entry.value, 2) .. "\n";
		end
	end

	UIFrame.text:SetText(text);
end
