-- User And Character Control System
XSystem = {}
XSystem.core = {}

-- table with metamethods
XSystem.core.meta = {} 

-- __len metamethod
XSystem.core.meta.length = function(self)
    local length = 0
    for _ in pairs(self) do
        length = length + 1
    end
    return length
end

-- __tostring metamethod
XSystem.core.meta.debug = function(self)

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
XSystem.core.class = {}

-- mysql class to interact with the data base (includes auto encoder)
XSystem.core.class.sql = function()

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

                self.data[key] = type(value) == 'table' and json.encode(value) or value

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

    Sql.__tostring = XSystem.core.meta.debug
    Sql.__metatable = nil

    return setmetatable({}, Sql)

end

-- class which stores data in a container
---@param name string index of bin where data is stored
XSystem.core.class.container = function(name)

    local Container = {}

    function Container:set(key, data)
        self("set", key, data)
    end

    function Container:get(key)
        self("get", key)
    end

    function Container:move(key, newKey)
        self("move", key, nil, newKey)
    end

    Container.__index = function(self, key)
        if self[key] == nil then
            print('STORAGE:INFO | tried fetching non-existent data from the '..self.name..' storage bin')
        else
            print('STORAGE:INFO | fetched data from the '..self.name..' storage bin')
            return self[key]
        end
    end

    Container.__newindex = function(self, key, value)
        if self.bin[key] == nil then
            print('STORAGE:INFO | someone added something to the '..self.name..' storage bin (key: '..key..', key: '..value..')')
        else
            print('STORAGE:INFO | someone changed somethin in the '..self.name..' storage bin (key: '..key..', key: '..value..')')
        end
    end

    Container.__call = function(self, action, key, data, oldKey)
        key = tostring(key)
        oldKey = tostring(oldKey)
        if type(action) == 'string' then
            if action == 'set' and (key and data) ~= nil then
                self.data[key] = data
            elseif action == 'get' and (key and self.data[key]) ~= nil then
                return self.data[key]
            elseif action == 'move' and (key and self.data[oldKey]) ~= nil then
                self.data[key] = self.data[oldKey]
                self.data[oldKey] = nil
            else
                print('^1STORAGE:ERROR | bin: ^6'..self.name..'^1 | action string should equal "set", "get", "move" or "del", got "'..action..'" instead!^0')
            end
        else
            print('^1STORAGE:ERROR | bin: ^6'..self.name..'^1 | action needs to be a string, got "'..type(action)..'" instead!^0')
        end
    end
    Container.__len = XSystem.core.meta.length
    Container.__tostring = XSystem.core.meta.debug
    Container.__metatable = nil

    return setmetatable({
        name = name or 'unset',
        data = {}
    }, Container)

end

XSystem.core.class.customIds = function()

    local Class = {}

    function Class:randStr(length)

        if length <= 0 then return '' end

        local N = math.random
        local C = string.char

        local randChar = C( N(1, 2) == 2 and ( N(1, 2) == 2 and N(97, 122) or N(48, 57) ) or N(65, 90) )

        return self:randStr(length - 1) .. randChar

    end

    Class.__call = function(self, id)

        local types = {
            userId = {
                id = 'pxl-'..self:randStr(10),
                sql = {
                    {
                        tbl = 'users',
                        cols = {
                            {
                                col = 'client_id',
                                like = false
                            }
                        }
                    }
                }
            },
        }

        local SQL = XSystem.core.class.sql()

        local retval = types[id].id
        local tbls = types[id].sql

        local counter = 0

        for i = 1, #tbls do

            local cols = tbls[i].cols

            for j = 1, #cols do

                SQL:query(
                    ('SYNC SELECT COUNT(*) as count FROM %s WHERE %s %s :id'):format(
                        tbls[i].tbl,
                        cols[j].col,
                        not cols[j].like and '=' or 'LIKE'
                    )
                )

                SQL:data({
                    id = ('%s'):format(
                        not cols[j].like and retval or '%'..retval..'%'
                    )
                })

                local res = SQL()

                counter = counter + res.count

                if counter > 0 then break end

            end

            if counter > 0 then break end

        end

        return counter > 0 and self(id) or retval

    end

    return setmetatable({}, Class)

end

-- handles user identifiers
XSystem.core.class.identifiers = function(src)

    local CustomId = XSystem.core.class.customIds()

    local Class = {}
    local cData = {
        client_id = '',
        ip = {},
        xbl = {},
        live = {},
        steam = {},
        fivem = {},
        discord = {},
        license = {},
        license2 = {}
    }

    function Class:randomStr(length)

        if length <= 0 then return '' end

        local i = math.random(1, 2)
        local j = math.random(1, 2)

        return randomStr(length - 1) .. string.char(i == 2 and (j == 2 and math.random(97, 122) or math.random(48, 57)) or math.random(65, 90))

    end

    function Class:split(str, delimiter)

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

    Class.__index = function(self, key)
        if self[key] == nil then
            print('BUCKET:INFO | tried fetching non-existent identifier')
        else
            print('BUCKET:INFO | fetched '..key..' identifiers')
            return self[key]
        end
    end

    Class.__newindex = function(self, key, value)
        if self[key] == nil then
            print('BUCKET:INFO | someone added something to bucket (key: '..key..', key: '..value..')')
        else
            print('BUCKET:INFO | someone changed somethin in the bucket (key: '..key..', key: '..value..')')
        end
    end

    Class.__call = function(self, type, id)
        local found = false
        for i = 1, #self[type], 1 do
            local curr = self[type][i]
            if curr == id then found = true; break end
        end
        if not found then
            self[type][ #self[type] + 1 ] = id
        end
    end

    Class.__len = XSystem.core.meta.length
    Class.__tostring = XSystem.core.meta.debug
    Class.__metatable = nil

    local Class = setmetatable(cData, Class)

    local sql = XSystem.core.class.sql()
    sql:query('SYNC SELECT * FROM clients WHERE identifiers LIKE ?')

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
        Class(id[1], id[2])
    end

    if not found then
        Class.client_id = CustomId('userID')
    else
        Class.client_id = data.client_id
        for type, content in pairs(data.identifiers) do
            for i = 1, #content, 1 do
                Class(type:lower(), content[i])
            end
        end
    end

    return Class

end

-- handles user permissions
XSystem.core.class.permissions = function(data)

    local Class = {}
    local cData = {
        level = data.level or 1,
        label = cfg[data.level or 1].label,
        ssn = data.ssn or '',
        optin = false
    }

    function Class:set(level, by)
        local cfg = GetConfig()("system")("perms")
        by = type(by) ~= 'number' and (type(by) == 'table' and by.level or #cfg) or by
        self.level = self.level < by and level or self.level
        return self
    end

    function Class:setSsn(ssn, by)
        self.ssn = self.level < by and ssn or self.ssn
        return self
    end

    function Class:check(required)
        local cfg = GetConfig()("system")("perms")
        if type(required) == 'string' then
            local found = false
            for k, v in pairs(cfg) do
                if (v.id or v.label) == required then
                    found = true
                    required = k;
                    break
                end
            end
            if not found then required = 1 end
        end
        return self.level >= required and self.optin or false
    end

    function Class:toggleOptin(ssn)
        self.optin = self.ssn == ssn and true or false
        return self
    end

    Class.__call = function(self, action, ...)
        local retval  = action == "set"     and self.set(self, ...)         or (
                        action == "check"   and self.check(self, ...)       or (
                        action == "snn"     and self.setSsn(self, ...)      or (
                        action == "optin"   and self.toggleOptin(self, ...) or false ) ) )
        return retval
    end

    Class.__tostring = XSystem.core.meta.debug
    Class.__metatable = nil

    return setmetatable(cData, Class)

end

-- creates a users
XSystem.core.class.user = function(name, tempId, ids, perms)

    local Class = {}
    local cData = {
        name = name,
        id = {
            server = 0,
            temp = tempId,
        },
        identifiers = ids,
        permissions = perms,
    }

    Class.__tostring = XSystem.core.meta.debug

    return setmetatable(cData, Class)

end

-- data storage system that stores created user data
XSystem.storage = {}

XSystem.storage.bins = {}
XSystem.storage.bins.__call = function(self, key)
    return self[key] ~= nil and self[key] or {}
end
XSystem.storage.bins.__tostring = XSystem.core.meta.debug
XSystem.storage.bins.__metatable = nil
XSystem.storage.bins = setmetatable({}, XSystem.storage.bins)

-- function that creates a storage bin
---@param index string index of the bin
---@param key string | number index within the bin where the data is stored
---@param data any data type that is stored within bin
function XSystem.storage:create(index, key, data)
    
    if self.bins[index] == nil then
        self.bins[index] = XSystem.core.class.container(index)
    end

    if (key and data) ~= nil then
        self.bins[index]:add(key, data)
    end

end

-- function to manage data bins
---@param index string index of the storage bin
---@param key string | number index of the data within the specified bin
function XSystem.storage:fetch(index, key)
    return self.bins[index] ~= nil and self.bins[index]:get(key) or nil
end

-- function to manage data bins
---@param index string index of the storage bin
---@param key string | number current index of the data within the specified bin
---@param key string | number new index of the data within the specified bin
function XSystem.storage:move(index, key, newKey)
    if self.bins[index] ~= nil then
        self.bins[index]:move(key, newKey)
    end
end

-- function to manage data bins
---@param index string index of the storage bin
---@param key string | number current index of the data within the specified bin
---@param key string | number new index of the data within the specified bin
function XSystem.storage:remove(index)
    self.bins[index] = nil
end

-- functions returning class mimics
XSystem.users = {}

function XSystem.users:create(name, tempId)

    local ids = XSystem.core.class.identifiers(tempId)



    local perms = XSystem.core.class.perms(data.perms)

    XSystem.core.class.user(name, tempId, ids, perms)

end

-- functions used for connecting
XSystem.connect = {}

XSystem.connect.conn = function(name, kick, deferrals)

    local tempId = source
    local user = XSystem.users.create(tempId, name)

    XSystem.storage.manage('users', 'set', tempId, user)

end

XSystem.connect.join = function(tempId)

    local serverId = source
    local user = XSystem.storage.manage('users', 'get', tempId)

    user.id.server = serverId

    XSystem.storage.manage('users', 'move', serverId, user, tempId)

end

XSystem.connect.drop = function(reason)

    local src = source
    local user = XSystem.storage.manage('users', 'get', src)

    if user ~= nil then

        XSystem.storage.manage('users', 'del', src)

    end

end

-- XSystem metamethods
Xs = setmetatable(XSystem, {
    __index = XSystem,
    __tostring = XSystem.core.meta.debug
})

-- trigger the correct system functions when the player triggered one of the events underneath
AddEventHandler('playerConnecting', Xs.connect.conn)
AddEventHandler('playerJoining',    Xs.connect.join)
AddEventHandler('playerDropped',    Xs.connect.drop)

-- functions format when used outside resource or inside event or copied to table
--[[
    XSystem.catagory.functionName = function(...)
        return
    end
]]

-- function format when !! NOT !! used outside resource or inside event or copied to table
--[[
    self is auto included like source or [playerSrc]
    function XSystem.catagory:functionName(self, ...)
        return
    end
]]

-- copy/paste --> Xs = exports.XSystem:GetSystem()
exports('GetSystem', function() return Xs end)