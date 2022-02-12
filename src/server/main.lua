xSys = {}
xSys.core = {}

-- table with metamethods
xSys.core.meta = {} 

-- __len metamethod
xSys.core.meta.length = function(self)
    local length = 0
    for _ in pairs(self) do
        length = length + 1
    end
    return length
end

-- __tostring metamethod
xSys.core.meta.debug = function(self)

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

-- table with class mimics
xSys.core.class = {}

-- mysql class to interact with the data base (includes auto encoder)
xSys.core.class.sql = function()

    local Sql = {}
    Sql.__index = Sql

    Sql.stmt = ''
    Sql.data = {}
    Sql.exec = function() end

    function Sql:query(query)

        local function executable(i, j)
            local types = {
                ['SYNC-INSERT'] = MySQL.Sync.insert,
                ['SYNC-SELECT'] = MySQL.Sync.fetchAll,
                ['SYNC-UPDATE'] = MySQL.Sync.execute,
                ['SYNC-DELETE'] = MySQL.Sync.execute,
                ['ASYNC-INSERT'] = MySQL.Async.insert,
                ['ASYNC-SELECT'] = MySQL.Async.fetchAll,
                ['ASYNC-UPDATE'] = MySQL.Async.execute,
                ['ASYNC-DELETE'] = MySQL.Async.execute
            }
            return types[ i .. '-' .. j ]
        end

        local function split(str, delimiter)
            local result = {}
            local from = 1
            local delim_from, delim_to = string.find(str, delimiter, from)
            while delim_from do
                result[#result+1] = string.sub(str, from, delim_from - 1)
                from = delim_to + 1
                delim_from, delim_to = string.find(str, delimiter, from)
            end
            result[#result+1] = string.sub(str, from)
            return result
        end

        local syntax = split(query, " ")
        if syntax[1] == "SYNC" or syntax[1] == "ASYNC" then
            self.stmt = syntax[1] == "SYNC" and query:gsub("SYNC ", "", 1) or query:gsub("ASYNC ", "", 1)
            self.exec = executable(syntax[1], syntax[2])
        else
            print("SQL:ERROR -> Query needs to start with 'SYNC' or 'ASYNC', got '"..query.."' instead!")
            return false
        end

    end

    function Sql:prepare(data)
        if data ~= nil and type(data) == "table" then
            -- clear the table so it doesn't contain any of the previous data
            self.data = {}
            -- auto encode the tables to a json string
            for key, value in pairs(data) do
                if type(value) == 'table' then 
                    self.data[key] = json.encode(value)
                else
                    self.data[key] = value
                end
            end
        else
            print("SQL:ERROR -> data needs to be a table, got '"..type(data).."' instead!")
            return false
        end
    end

    Sql.__call = function(self, callback)
        local result = self.exec(self.stmt, self.data)
        if callback ~= nil then
            callback(result)
        else
            return result
        end
    end

    Sql.__tostring = xSys.core.meta.debug
    Sql.__metatable = nil

    return setmetatable({}, Sql)

end

-- higher order functions
xSys.core.functions = {}

xSys.core.functions.identifiers = function(src)

    local function randomStr(length)
        if length <= 0 then return '' end
        local i = math.random(1, 2)
        local j = math.random(1, 2)
        return randomStr(length - 1) .. string.char(i == 2 and (j == 2 and math.random(97, 122) or math.random(48, 57)) or math.random(65, 90))
    end

    local function split(str, delimiter)
        local result = {}
        local from = 1
        local delim_from, delim_to = string.find(str, delimiter, from)
        while delim_from do
            result[#result+1] = string.sub(str, from, delim_from - 1)
            from = delim_to + 1
            delim_from, delim_to = string.find(str, delimiter, from)
        end
        result[#result+1] = string.sub(str, from)
        return result
    end

    local ids = setmetatable({
        client_id = '',
        ip = {},
        xbl = {},
        live = {},
        steam = {},
        fivem = {},
        discord = {},
        license = {},
        license2 = {}
    }, {
        __index = function(self, key)
            if self[key] == nil then
                print('BUCKET:INFO | tried fetching non-existent identifier')
            else
                print('BUCKET:INFO | fetched '..key..' identifiers')
                return self[key]
            end
        end,
        __newindex = function(self, key, value)
            if self[key] == nil then
                print('BUCKET:INFO | someone added something to bucket (key: '..key..', key: '..value..')')
            else
                print('BUCKET:INFO | someone changed somethin in the bucket (key: '..key..', key: '..value..')')
            end
        end,
        __call = function(self, type, id)
            local found = false
            for i = 1, #self[type], 1 do
                local curr = self[type][i]
                if curr == id then found = true; break end
            end
            if not found then
                self[type][ #self[type] + 1 ] = id
            end
        end,
        __len = xSys.core.meta.length,
        __tostring = xSys.core.meta.debug,
        __metatable = nil
    })

    local sql = xSys.core.class.sql()
    sql:query('SYNC SELECT client_id, identifiers FROM clients WHERE identifiers LIKE ?')

    local found = false
    local data = {}

    local currentIds = GetPlayerIdentifiers(src)
    for i = 1, #currentIds, 1 do
        local id = split(currentIds[i], ':')
        if not found then
            sql:prepare({ '%'..id[2]..'%' })
            local result = sql()
            if result[1] ~= nil then
                found = true
                result[1].identifiers = json.decode(result[1].identifiers)
                data = result[1]
            end
        end
        ids(id[1], id[2])
    end

    if not found then
        ids.client_id = 'pxl-'..randomStr(10)
    else
        ids.client_id = data.client_id
        for type, content in pairs(data.identifiers) do
            for i = 1, #content, 1 do
                -- print(type, content[i])
                ids(type:lower(), content[i])
            end
        end
    end

    return ids

end

-- data storage system that stores created user data
xSys.storage = {}
xSys.storage.bins = {}

-- function to manage data bins
xSys.storage.manage = function(name, action, key, data)
    
    if xSys.storage.bins[name] == nil then
        
        -- when bin doesn't exist create it
        xSys.storage.bins[name] = setmetatable({
            name = '',
            bin = {}
        }, {

            __index = function(self, key)

                if self.bin[key] == nil then

                    print('STORAGE:INFO | tried fetching non-existent data from the '..self.name..' storage bin')

                else

                    print('STORAGE:INFO | fetched data from the '..self.name..' storage bin')

                    return self.bin[key]

                end

            end,
            __newindex = function(self, key, value)

                if self.bin[key] == nil then

                    print('STORAGE:INFO | someone added something to the '..self.name..' storage bin (key: '..key..', key: '..value..')')

                else

                    print('STORAGE:INFO | someone changed somethin in the '..self.name..' storage bin (key: '..key..', key: '..value..')')

                end

            end,
            __call = function(self, action, key, data)

                if type(action) == 'string' then

                    if action == 'set' and (key and data) ~= nil then

                        self.bin[key] = data

                    elseif action == 'get' and (key and self.bin[key]) ~= nil then

                        return self.bin[key]

                    elseif action == 'del' and (key and self.bin[key]) ~= nil then

                        self.bin[key] = nil

                    else

                        print('^1STORAGE:ERROR | bin: ^6'..self.name..'^1 | action string should equal "set", "get" or "del", got "'..action..'" instead!^0')

                    end

                else

                    print('^1STORAGE:ERROR | bin: ^6'..self.name..'^1 | action needs to be a string, got "'..type(action)..'" instead!^0')

                end

            end,
            __len = xSys.core.meta.length,
            __tostring = xSys.core.meta.debug,
            __metatable = nil
        })

        -- check if data is given and add if it is
        if (action and key and data) ~= nil then

            xSys.storage.bins[name](action, key, data)

        end

    else

        -- check if action is equal to del if so, check if bin is empty if so, delete the bin
        if action == 'del' then

            xSys.storage.bins[name](action, key, data)
    
            if  xSys.core.meta.length( xSys.storage.bins[name].bin ) == 0 then

                xSys.storage.bins[name] = nil

            end

        elseif  action == 'get' then

            local retval = xSys.storage.bins[name](action, key, data)

            return retval

        end

    end

end

-- functions that interact with the core classes / functions

-- functions returning class mimics
xSys.users = {} 

xSys.users.create = function(tempId, name)
    return setmetatable({
        name = name,
        id = {
            server = 0,
            temp = tempId,
        },
        identifiers = xSys.core.functions.identifiers(tempId),
    }, {
        __tostring = xSys.core.meta.debug
    })
end

-- functions used for connecting
xSys.connect = {}

xSys.connect.conn = function(name, kick, deferrals)

    local tempId = source
    local user = xSys.users.create(tempId, name)

    print(user)

end

xSys.connect.join = function(tempId)
    --
end

xSys.connect.drop = function(id)
    --
end

-- set copple of metamethods
xSys.__index = xSys
xSys.__tostring = xSys.core.meta.debug

-- make the table a class mimic
xSys = setmetatable({}, xSys)

-- trigger the correct system functions when the player triggered one of the events underneath
AddEventHandler('playerConnecting', xSys.connect.conn)
AddEventHandler('playerJoining',    xSys.connect.join)
AddEventHandler('playerDropped',    xSys.connect.drop)

-- copy/paste --> xSys = exports.XSystem:GetSystem()
exports('GetSystem', function() return xSys end)