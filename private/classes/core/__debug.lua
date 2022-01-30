_DEBUG = {}

-- function to initialize debug mode
function _DEBUG:INIT()
    local tbl = { active = CONFIG.DEBUG_MODE }
    setmetatable(tbl, self)
    self.__index = self
    return tbl
end

function _DEBUG:TOGGLE()
    self.active = not self.active
    print('DEBUG MODE TURNED '..( not self.active and '^1OFF^0' or '^2ON^0' ))
end

-- 2 functions for setting console colors
-- rgb(red, green, blue)
function _DEBUG:RGB(RED, GREEN, BLUE)
	return ('\x1B[38;2;%d;%d;%dm'):format(RED, GREEN, BLUE)
end

-- primary, success, info, data, warning, danger
function _DEBUG:COLOR(_TYPE)
    local COLORS = {
		['primary'] = vector3(20, 98, 242),
		['success'] = vector3(29, 199, 106),
		['info'] 	= vector3(128, 216, 248),
		['data'] 	= vector3(31, 70, 100),
		['warning'] = vector3(255, 178, 35),
		['danger'] 	= vector3(225, 24, 68)
	}
	return self:RGB(COLORS[_TYPE].x, COLORS[_TYPE].y, COLORS[_TYPE].z)
end

function _DEBUG:PRINT(_TABLE, _INDENT)
    _INDENT = _INDENT or 0
	for INDEX, VALUE in pairs(_TABLE) do
		local TYPE = type(VALUE)
		local TABSPACE = string.rep("    ", _INDENT)
        local KEY = ("%s^3%s^0"):format(TABSPACE, INDEX)
        if TYPE == "table" then
			local length = _DT:TABLE_LENGTH(VALUE)
			if length > 0 then
				print(("%s^3 (^5#%d^3): ^4{^0"):format(KEY, length))
				self:PRINT(VALUE, _INDENT + 1)
				print(("%s^4}^0"):format(TABSPACE))
			else
				print(("%s^3: ^1{ !!empty table!! }^0"):format(KEY))
			end
        elseif TYPE == 'boolean' then
            print(("%s^3:^1 %s ^0"):format(KEY, VALUE))
        elseif TYPE == "function" then
            print(("%s^3:^9 %s ^0"):format(KEY, VALUE))
        elseif TYPE == 'number' then
            print(("%s^3:^5 %s ^0"):format(KEY, VALUE))
        elseif TYPE == 'string' then
            print(("%s^3:^2 '%s' ^0"):format(KEY, VALUE))
        else
            print(("%s^3:^2 %s ^0"):format(KEY, VALUE))
        end
	end
end

function _DEBUG:LOG(_TABLE, _SOURCE, _COLOR)
    if not self.active then return end -- if statement to toggle debug mode
    _COLOR = _COLOR ~= nil and _COLOR or "primary"
    local COLOR = self:COLOR(_COLOR)
    local SRC_COLOR = self:COLOR('data')
    _SOURCE = _SOURCE ~= nil and _SOURCE or "debugger"
    print(COLOR.."DEBUG:LOG TRIGGERED FROM "..SRC_COLOR.._SOURCE.."^0")
    self:PRINT(_TABLE)
    print(COLOR.."DEBUG:LOG TRIGGERED FROM "..SRC_COLOR.._SOURCE.."^0")
end


RegisterCommand("debug-mode", function()
    TriggerEvent("toggle:debug-mode")
end)