local _, Addon = ...; -- Namespace

local Module = Addon.ModuleManager:GetModuleWorkspace("gps");
local Util = Addon.Util;

--------------------------------------
-- Module
--------------------------------------

local OriginalChatHandler;
local UIFrame;

local Data = {
	{ key = "x",           value = 0 },
	{ key = "y",           value = 0 },
	{ key = "z",           value = 0 },
	{ key = "orientation", value = 0 }
};

function Module:GetDescription()
	return "User interface for .gps command";
end

function Module:Enable()
	if OriginalChatHandler == nil then
		OriginalChatHandler = ChatFrame_MessageEventHandler;
	end

	-- Hijack chat event dispatcher with our middleware
	ChatFrame_MessageEventHandler = function(event, ...)
		if Module:IsGpsMessage(arg1) then
					-- We care about coordiantes
					if Util:StartsWith(arg1, "X: ") then
						local raw = Util:Split(arg1, " ");
						Module:SetData("x", raw[2]);
						Module:SetData("y", raw[4]);
						Module:SetData("z", raw[6]);
						Module:SetData("orientation", raw[8]);
						Module:UpdateUIFrame();
					end

					-- When module is enabled we will not show any .gps message in chat
					-- this gets rid of command spam
					return;
		end

		-- Dispach original events after it is handled by addon
		return OriginalChatHandler(event, ...);
	end

	local ui = UIFrame or Module:CreateUIFrame();
	ui:Show();

	-- Get initial data
	SendChatMessage(".gps");
end

function Module:Disable()
	-- Remove our middleware from chat
	if OriginalChatHandler ~= nil then
		ChatFrame_MessageEventHandler = OriginalChatHandler;
	end

	local ui = UIFrame or Module:CreateUIFrame();
	ui:Hide();
end

--------------------------------------
-- Logic
--------------------------------------

local GpsLineParts = {
	"X: ",
	"no VMAP",
	"You are outdoors.",
	"Map:",
	"grid[",
	" ZoneX:",
	"GroundZ:"
}

function Module:IsGpsMessage(message)
	if message == nil then
		return false;
	end

	for _,part in pairs(GpsLineParts) do
		if Util:StartsWith(message, part) then
			return true;
		end
	end

	return false;
end

function Module:SetData(key, value)
	for _, entry in pairs(Data) do
		if entry.key == key then
			entry.value = value;
			return;
		end
	end
end

function Module.OnConfigChange(propertyName, propertyValue)
	if propertyName == "refresh" then
		UIFrame.Interval.value = propertyValue;
		return;
	end

	if propertyName == "x" or propertyName == "y" then
		local ModuleConfig = Addon.ModuleManager:GetConfig("gps");
		UIFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ModuleConfig.x, ModuleConfig.y);
	end
end

--------------------------------------
-- UI
--------------------------------------

function Module:CreateUIFrame()
	Addon.Config:SubscribePropertyChange("gps", Module.OnConfigChange);
	local ModuleConfig = Addon.ModuleManager:GetConfig("gps");

	UIFrame = CreateFrame("Frame", "AT_GPS");
	UIFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ModuleConfig.x, ModuleConfig.y);
	UIFrame:SetSize(155, 64);

	UIFrame.TargetText = UIFrame:CreateFontString(UIFrame:GetName() .. "_TARGETTEXT", "OVERLAY", "GameFontGreen");
	UIFrame.TargetText:SetPoint("CENTER", UIFrame, 0, UIFrame:GetHeight() / 2);
	UIFrame.TargetText:SetText("");

	UIFrame.Text = UIFrame:CreateFontString(UIFrame:GetName() .. "_TEXT", "OVERLAY", "GameFontNormal");
	UIFrame.Text:SetAllPoints();
	UIFrame.Text:SetText("");

	-- Create timer that will periodicly send .gps commdns via chat
	-- No need to worry about stoping the timer, it will tick only when main frame is visible
	UIFrame.Interval = CreateFrame("Frame", UIFrame:GetName() .. "_INTERVAL", UIFrame);
	UIFrame.Interval.value = ModuleConfig.refreshRate; -- Update internal in seconds
	UIFrame.Interval:SetScript("OnUpdate", function(self, elapsed)
	    self.elapsed = (self.elapsed or 0) + elapsed;
	    if self.elapsed >= self.value then
					SendChatMessage(".gps");
	        self.elapsed = 0;
	    end
	end)
	UIFrame.Interval:Show();

	UIFrame:Hide();
	return UIFrame;
end

function Module:UpdateUIFrame()
	local config = Addon.ModuleManager:GetConfig("gps");
	local text = "";

	if config["show-target"] and UnitExists("target") and (not UnitIsUnit("target", "player")) then
		UIFrame.TargetText:SetText("[" .. UnitName("target") .. "]");
	else
		UIFrame.TargetText:SetText("");
	end

	for _, entry in pairs(Data) do
		local showKey = config["show-" .. entry.key];
		if showKey or showKey == nil then
			text = text .. Util:Capitalize(entry.key) .. ": " .. Util:Round(entry.value, config.accuracy) .. "\n";
		end
	end

	UIFrame.Text:SetText(text);
end
