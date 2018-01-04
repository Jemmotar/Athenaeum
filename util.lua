local _, core = ...; -- Namespace
core.Util = {}; -- adds Util table to addon namespace
local Util = core.Util;

--------------------------------------
-- Utilities
--------------------------------------

function Util:Print(...)
	local prefix = string.format("|cff%s%s|r", "00ccff", "[Athenaeum]")
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
