local _, core = ...; -- Namespace

local Module = core.ModuleManager:GetModule("gps");
local Util = core.Util;

--------------------------------------
-- Module
--------------------------------------

local OriginalChatHandler;
local UIFrame;
local Data = {
	{ key = "X",           value = 0 },
	{ key = "Y",           value = 0 },
	{ key = "Z",           value = 0 },
	{ key = "Orientation", value = 0 }
};

function Module:GetDescription()
	return "User interface for .gps command";
end

function Module:Enable()
	if OriginalChatHandler == nil then
		OriginalChatHandler = ChatFrame_MessageEventHandler;
	end

	-- Hijack chat event dispatcher with our middleware
	ChatFrame_MessageEventHandler = Module.ChatFrameMiddleware;

	local frame = UIFrame or Module:CreateUIFrame();
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

function Module:ChatFrameMiddleware(type, message, ...)
	if Module:IsGpsMessage(type, message) then
			-- We care about coordiantes
			if Util:StartsWith(message, "X: ") then
				local raw = Util:Split(message, " ");
				Module:SetData("X", raw[2]);
				Module:SetData("Y", raw[4]);
				Module:SetData("Z", raw[6]);
				Module:SetData("Orientation", raw[8]);
				Module:UpdateUIFrame();
			end

			-- When module is enabled we will not show any .gps message in chat
			-- this gets rid of command spam
			return;
	end

	-- Dispach original events after it is handled by addon
	return OriginalChatHandler(type, message, ...);
end

function Module:IsGpsMessage(type, message)
	return type == "CHAT_MSG_SYSTEM" and (
		Util:StartsWith(message, "no VMAP") or -- I know, this could be looped in list but I don't think .gps command will change any time soon
		Util:StartsWith(message, "Map:") or
		Util:StartsWith(message, "grid[") or
		Util:StartsWith(message, "X: ") or
		Util:StartsWith(message, " ZoneX:") or
		Util:StartsWith(message, "GroundZ:")
	);
end

function Module:SetData(key, value)
	for _, entry in pairs(Data) do
		if entry.key == key then
			entry.value = value;
			return;
		end
	end
end

--------------------------------------
-- UI
--------------------------------------

function Module:CreateUIFrame()
	UIFrame = CreateFrame("Frame", "AT_GPS");
	UIFrame:SetPoint("RIGHT", UIParent, "RIGHT", 0, 200);
	UIFrame:SetSize(155, 64);

	UIFrame.Text = UIFrame:CreateFontString(UIFrame:GetName() .. "_TEXT", "OVERLAY", "GameFontNormal");
	UIFrame.Text:SetAllPoints();
	UIFrame.Text:SetText("");

	-- Create timer that will periodicly send .gps commdns via chat
	-- No need to worry about stoping the timer, it will tick only when main frame is visible
	UIFrame.Interval = CreateFrame("Frame", UIFrame:GetName() .. "_INTERVAL", UIFrame);
	UIFrame.Interval.value = 3; -- Update internal in seconds
	UIFrame.Interval:SetScript("OnUpdate", function(self, elapsed)
	    self.elapsed = (self.elapsed or 0) + elapsed;
	    if self.elapsed >= self.value then
					SendChatMessage(".gps");
	        self.elapsed = 0;
	    end
	end)
	UIFrame.Interval:Show();

	-- Get initial data
	SendChatMessage(".gps");

	UIFrame:Hide();
	return UIFrame;
end

function Module:UpdateUIFrame()
	local text = "";

	for _, entry in pairs(Data) do
		text = text .. entry.key .. ": " .. Util:Round(entry.value, 2) .. "\n";
	end

	UIFrame.Text:SetText(text);
end
