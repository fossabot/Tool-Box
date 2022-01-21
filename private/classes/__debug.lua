local function TABLE_LENGTH(tbl)
	local ret = 0
	for k, v in pairs(tbl) do
		ret = ret + 1
	end
	return ret
end

-- 2 functions for setting console colors
-- rgb(red, green, blue)
local function _RGB(r, g, b)
	return ('\x1B[38;2;%d;%d;%dm'):format(r, g, b)
end

-- primary, success, info, data, warning, danger
local function _C(type)
	local colors = {
		['primary'] = vector3(20, 98, 242),
		['success'] = vector3(29, 199, 106),
		['info'] 	= vector3(128, 216, 248),
		['data'] 	= vector3(31, 70, 100),
		['warning'] = vector3(255, 178, 35),
		['danger'] 	= vector3(225, 24, 68)
	}
	return _RGB(colors[type].x, colors[type].y, colors[type].z)
end

local function _PRINT(tbl, indent)
    indent = indent or 0
	for k, v in pairs(tbl) do
		local _type = type(v)
		local tabs = string.rep("    ", indent)
        local key = ("%s^3%s^0"):format(tabs, k)
        if _type == "table" then
			local length = TABLE_LENGTH(v)
			if length > 0 then
				print(("%s^3 (^5#%d^3): ^4{^0"):format(key, length))
				_PRINT(v, indent + 1)
				print(("%s^4}^0"):format(tabs))
			else
				print(("%s^3: ^1{ !!empty table!! }^0"):format(key))
			end
        elseif _type == 'boolean' then
            print(("%s^3:^1 %s ^0"):format(key, v))
        elseif _type == "function" then
            print(("%s^3:^9 %s ^0"):format(key, v))
        elseif _type == 'number' then
            print(("%s^3:^5 %s ^0"):format(key, v))
        elseif _type == 'string' then
            print(("%s^3:^2 '%s' ^0"):format(key, v))
        else
            print(("%s^3:^2 %s ^0"):format(key, v))
        end
	end
end

DEBUG = {}

function DEBUG:LOG(table)
	_PRINT(table)
end