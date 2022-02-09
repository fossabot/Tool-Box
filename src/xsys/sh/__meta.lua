-- __tostring metamethod
function ToStringDebugger(self)

    local function rgb(red, green, blue)

        return ('\x1B[38;2;%d;%d;%dm'):format(red, green, blue)
    
    end

    local function color(type)
        
        local colors = {
            ['primary'] = vector3(20, 98, 242),
            ['success'] = vector3(29, 199, 106),
            ['info'] 	= vector3(128, 216, 248),
            ['data'] 	= vector3(31, 70, 100),
            ['warning'] = vector3(255, 178, 35),
            ['danger'] 	= vector3(225, 24, 68)
        }

        local c = colors[type]

        return rgb(c.x, c.y, c.z)

    end
    
    local function length(tbl)
        local length = 0
        for _ in pairs(tbl) do
            length = length + 1
        end
        return length
    end

    local function typeStr(type)
        local types = {
            ['boolean'] = "%s^3:^1 %s ^0",
            ['function'] = "%s^3:^9 %s ^0",
            ['number'] = "%s^3:^5 %s ^0",
            ['string'] = "%s^3:^2 '%s' ^0",
            ['nil'] = "%s^3:^2 %s ^0",
            ['thread'] = "%s^3:^2 %s ^0",
            ['userdata'] = "%s^3:^2 %s ^0"
        }
        return types[type]
    end

    local function printStr(tbl, depth)

        local retval, first = '', true
        depth = depth or 0

        for index, value in pairs(tbl) do

            local type = type(value)
            local tabs = string.rep("    ", depth)
            local key = ("%s^3%s^0"):format(tabs, index)

            retval = not first and retval .. '\n' or ''
            first = false

            if type == "table" then

                local length = length(value)

                if length > 0 then

                    retval = retval .. ("%s^3 (^5#%d^3): ^4{\n%s\n%s^4}^0^0"):format(
                        key,
                        length,
                        printStr(value, depth + 1),
                        tabs
                    )

                else
                    
                    retval = retval .. ("%s^3: ^1{ !!empty table!! }^0"):format(key)
                
                end

            else
                
                retval = retval .. (typeStr(type)):format(key, value)
            
            end

        end

        return retval

    end

    local debugMode = GetConfig()("System")("Info")("debug_mode")

    return not debugMode and '' or printStr(self)

end