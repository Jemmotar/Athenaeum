local _, Addon = ...; -- Namespace
Addon.Util = {};

local Util = Addon.Util;

--------------------------------------
-- Tables
--------------------------------------

Util.Colors = {
	athenaeum = "00CCFF",
	success = "48D80A",
	failure = "DB0000",
	module = "FF6A00",
	command = "FFE13A",
	property = "CA60FF"
}

Util.Validation = {
	IsPositive = {
		name = "positive number",
		test = function(input)
			return input > 0;
		end
	},
	IsPositiveOrZero = {
		name = "positive number or zero",
		test = function(input)
			return input >= 0;
		end,
	}
}

--------------------------------------
-- Utilities
--------------------------------------

function Util:Print(...)
	local prefix = string.format("|cff%s%s|r", Util.Colors.athenaeum, "[Athenaeum]")
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...))
end

function Util:StartsWith(str, needle)
	 return string.sub(str, 1, string.len(needle)) == needle;
end

function Util:Split(str, separator)
	local result = {};
	local regex = ("([^%s]+)"):format(separator);

	for each in str:gmatch(regex) do
		 table.insert(result, each);
	end

	return result;
end

function Util:Round(num, n)
	local mult = 10 ^ (n or 0);
	return math.floor(num * mult + 0.5) / mult;
end

function Util:Colorize(str, color)
	return string.format("|cff%s%s|r", color, str);
end

function Util:Capitalize(str)
    return (str:gsub("^%l", string.upper))
end
