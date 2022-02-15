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

XSystem.core.class.character = function(data)

    local src = source
    local Class = {}
    local cData = {
        source = src,
        -- citizenid = (data and data.citizenid) ~= nil and data.citizenid or Class.ids:CreateCitizenId(),
        -- license = (data and data.license) ~= nil and data.license or QBCore.Functions.GetIdentifier(src, 'license'),
        -- name = GetPlayerName(src),
        cid = (data and data.license) ~= nil and data.cid or 1,
        funds = (data and data.license) ~= nil and data.funds or {},
        info = {
            firstname   = (data and data.info and data.info.firstname) ~= nil   and data.info.firstname or 'Firstname',
            lastname    = (data and data.info and data.info.lastname) ~= nil    and data.info.lastname or 'Lastname',
            birthdate   = (data and data.info and data.info.birthdate) ~= nil   and data.info.birthdate or '00-00-0000',
            gender      = (data and data.info and data.info.gender) ~= nil      and data.info.gender or 0,
            backstory   = (data and data.info and data.info.backstory) ~= nil   and data.info.backstory or 'placeholder backstory',
            nationality = (data and data.info and data.info.nationality) ~= nil and data.info.nationality or 'USA',
            phone       = (data and data.info and data.info.phone) ~= nil       and data.info.phone ~= nil and data.info.phone or '1' .. math.random(111111111, 999999999),
            account     = (data and data.info and data.info.account) ~= nil     and data.info.account ~= nil and data.info.account or 'US0' .. math.random(1, 9) .. 'QBCore' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
        },
        meta = {
            ['hunger']                  = (data and data.meta and data.meta['hunger']) ~= nil                   and data.meta['hunger'] or 100,
            ['thirst']                  = (data and data.meta and data.meta['thirst']) ~= nil                   and data.meta['thirst'] or 100,
            ['stress']                  = (data and data.meta and data.meta['stress']) ~= nil                   and data.meta['stress'] or 0,
            ['isdead']                  = (data and data.meta and data.meta['isdead']) ~= nil                   and data.meta['isdead'] or false,
            ['inlaststand']             = (data and data.meta and data.meta['inlaststand']) ~= nil              and data.meta['inlaststand'] or false,
            ['armor']                   = (data and data.meta and data.meta['armor']) ~= nil                    and data.meta['armor'] or 0,
            ['ishandcuffed']            = (data and data.meta and data.meta['ishandcuffed']) ~= nil             and data.meta['ishandcuffed'] or false,
            ['tracker']                 = (data and data.meta and data.meta['tracker']) ~= nil                  and data.meta['tracker'] or false,
            ['injail']                  = (data and data.meta and data.meta['injail']) ~= nil                   and data.meta['injail'] or 0,
            ['jailitems']               = (data and data.meta and data.meta['jailitems']) ~= nil                and data.meta['jailitems'] or {},
            ['status']                  = (data and data.meta and data.meta['status']) ~= nil                   and data.meta['status'] or {},
            ['phone']                   = (data and data.meta and data.meta['phone']) ~= nil                    and data.meta['phone'] or {},
            ['fitbit']                  = (data and data.meta and data.meta['fitbit']) ~= nil                   and data.meta['fitbit'] or {},
            ['commandbinds']            = (data and data.meta and data.meta['commandbinds']) ~= nil             and data.meta['commandbinds'] or {},
            -- ['bloodtype']               = (data and data.meta and data.meta['bloodtype']) ~= nil                and data.meta['bloodtype'] or QBCore.Config.Player.Bloodtypes[math.random(1, #QBCore.Config.Player.Bloodtypes)],
            ['dealerrep']               = (data and data.meta and data.meta['dealerrep']) ~= nil                and data.meta['dealerrep'] or 0,
            ['craftingrep']             = (data and data.meta and data.meta['craftingrep']) ~= nil              and data.meta['craftingrep'] or 0,
            ['attachmentcraftingrep']   = (data and data.meta and data.meta['attachmentcraftingrep']) ~= nil    and data.meta['attachmentcraftingrep'] or 0,
            ['currentapartment']        = (data and data.meta and data.meta['currentapartment']) ~= nil         and data.meta['currentapartment'] or nil,
            ['jobrep'] = {
                ['tow']     = (data and data.meta and data.meta['jobrep'] and data.meta['jobrep']['tow']) ~= nil        and data.meta['jobrep']['tow'] or 0,
                ['trucker'] = (data and data.meta and data.meta['jobrep'] and data.meta['jobrep']['trucker']) ~= nil    and data.meta['jobrep']['trucker'] or 0,
                ['taxi']    = (data and data.meta and data.meta['jobrep'] and data.meta['jobrep']['taxi']) ~= nil       and data.meta['jobrep']['taxi'] or 0,
                ['hotdog']  = (data and data.meta and data.meta['jobrep'] and data.meta['jobrep']['hotdog']) ~= nil     and data.meta['jobrep']['hotdog'] or 0
            },
            ['callsign']        = (data and data.meta and data.meta['callsign']) ~= nil         and data.meta['callsign'] or 'NO CALLSIGN',
            -- ['fingerprint']     = (data and data.meta and data.meta['fingerprint']) ~= nil      and data.meta['fingerprint'] or self.ids:CreateFingerId(),
            -- ['walletid']        = (data and data.meta and data.meta['walletid']) ~= nil         and data.meta['walletid'] or self.ids:CreateWalletId(),
            ['criminalrecord']  = (data and data.meta and data.meta['criminalrecord']) ~= nil   and data.meta['criminalrecord'] or {
                ['hasRecord'] = false,
                ['date'] = nil
            },
            ['licences']    = (data and data.meta and data.meta['licences']) ~= nil     and data.meta['licences'] or {
                ['driver'] = true,
                ['business'] = false,
                ['weapon'] = false
            },
            ['inside']      = (data and data.meta and data.meta['inside']) ~= nil       and data.meta['inside'] or {
                house = nil,
                apartment = {
                    apartmentType = nil,
                    apartmentId = nil
                }
            },
            ['phonedata']   = (data and data.meta and data.meta['phonedata']) ~= nil    and data.meta['phonedata'] or {
                -- SerialNumber = self.ids:CreateSerialNumber(),
                InstalledApps = {}
            }
        },
        job = {
            name    = (data and data.job and data.job.name) ~= nil  and data.job.name or 'unemployed',
            label   = (data and data.job and data.job.label) ~= nil and data.job.label or 'Civilian',
            grade = {
                name    = (data and data.job and data.job.grade and data.job.grade.name) ~= nil    and data.job.grade.name or 'Freelancer',
                level   = (data and data.job and data.job.grade and data.job.grade.level) ~= nil   and data.job.grade.level or 0
            },
            -- payment = QBCore.Shared.Jobs[data.job.name].grade[data.job.grade.level].payment,
            -- isboss = QBCore.Shared.Jobs[data.job.name].grade[data.job.grade.level].isboss,
            -- onduty = (QBCore.Shared.ForceJobDefaultDutyAtLogin or (data or data.job or data.job.onduty)) == nil and QBCore.Shared.Jobs[data.job.name].defaultDuty or false
        },
        gang = {
            name    = (data and data.gang and data.gang.name) ~= nil    and data.gang.name or 'none',
            label   = (data and data.gang and data.gang.label) ~= nil   and data.gang.label or 'No Gang Affiliaton',
            isboss  = (data and data.gang and data.gang.isboss) ~= nil  and data.gang.isboss or false,
            grade = {
                name    = (data and data.gang and data.gang.grade and data.gang.grade.name) ~= nil  and data.gang.grade.name or 'none',
                level   = (data and data.gang and data.gang.grade and data.gang.grade.level) ~= nil and data.gang.grade.level or 0
            }
        },
        -- position = data.position or QBConfig.DefaultSpawn,
        LoggedIn = true
    }

    -- for moneytype, startamount in pairs(QBCore.Config.Money.MoneyTypes) do
    --     cData.funds[moneytype] = cData.funds[moneytype] or startamount
    -- end

    function Class:UpdatePlayerData(dontUpdateChat)
        TriggerClientEvent('QBCore:Player:SetPlayerData', self.source, self)
        if dontUpdateChat == nil then
            QBCore.Commands.Refresh(self.source)
        end
    end

    function Class:SetJob(job, grade)
        local job = job:lower()
        local grade = tostring(grade) or '0'

        if QBCore.Shared.Jobs[job] then
            self.job.name = job
            self.job.label = QBCore.Shared.Jobs[job].label
            self.job.onduty = QBCore.Shared.Jobs[job].defaultDuty

            if QBCore.Shared.Jobs[job].grades[grade] then
                local jobgrade = QBCore.Shared.Jobs[job].grades[grade]
                self.job.grade = {}
                self.job.grade.name = jobgrade.name
                self.job.grade.level = tonumber(grade)
                self.job.payment = jobgrade.payment or 30
                self.job.isboss = jobgrade.isboss or false
            else
                self.job.grade = {}
                self.job.grade.name = 'No Grades'
                self.job.grade.level = 0
                self.job.payment = 30
                self.job.isboss = false
            end

            self:UpdatePlayerData()
            TriggerClientEvent('QBCore:Client:OnJobUpdate', self.source, self.job)
            return true
        end

        return false
    end

    function Class:SetGang(gang, grade)
        local gang = gang:lower()
        local grade = tostring(grade) or '0'

        if QBCore.Shared.Gangs[gang] then
            self.gang.name = gang
            self.gang.label = QBCore.Shared.Gangs[gang].label
            if QBCore.Shared.Gangs[gang].grades[grade] then
                local ganggrade = QBCore.Shared.Gangs[gang].grades[grade]
                self.gang.grade = {}
                self.gang.grade.name = ganggrade.name
                self.gang.grade.level = tonumber(grade)
                self.gang.isboss = ganggrade.isboss or false
            else
                self.gang.grade = {}
                self.gang.grade.name = 'No Grades'
                self.gang.grade.level = 0
                self.gang.isboss = false
            end

            self:UpdatePlayerData()
            TriggerClientEvent('QBCore:Client:OnGangUpdate', self.source, self.gang)
            return true
        end
        return false
    end

    function Class:SetJobDuty(onDuty)
        self.job.onduty = onDuty
        self:UpdatePlayerData()
    end

    function Class:SetMetaData(meta, val)
        local meta = meta:lower()
        if val ~= nil then
            self.meta[meta] = val
            self:UpdatePlayerData()
        end
    end

    function Class:AddJobReputation(amount)
        local amount = tonumber(amount)
        self.meta['jobrep'][self.job.name] = self.meta['jobrep'][self.job.name] + amount
        self:UpdatePlayerData()
    end

    function Class:AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        if amount < 0 then
            return
        end
        if self.funds[moneytype] then
            self.funds[moneytype] = self.funds[moneytype] + amount
            self:UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.funds[moneytype], true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.funds[moneytype])
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.source, moneytype, amount, false)
            return true
        end
        return false
    end

    function Class:RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        if amount < 0 then
            return
        end
        if self.funds[moneytype] then
            for _, mtype in pairs(QBCore.Config.Money.DontAllowMinus) do
                if mtype == moneytype then
                    if self.funds[moneytype] - amount < 0 then
                        return false
                    end
                end
            end
            self.funds[moneytype] = self.funds[moneytype] - amount
            self:UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.funds[moneytype], true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.funds[moneytype])
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.source, amount)
            end
            return true
        end
        return false
    end

    function Class:SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        if amount < 0 then
            return
        end
        if self.funds[moneytype] then
            self.funds[moneytype] = amount
            self:UpdatePlayerData()
            TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.funds[moneytype])
            return true
        end
        return false
    end

    function Class:GetMoney(moneytype)
        if moneytype then
            local moneytype = moneytype:lower()
            return self.funds[moneytype]
        end
        return false
    end

    function Class:AddItem(item, amount, slot, info)
        local totalWeight = QBCore.Player.GetTotalWeight(self.items)
        local itemInfo = QBCore.Shared.Items[item:lower()]
        if itemInfo == nil then
            TriggerClientEvent('QBCore:Notify', self.source, Lang:t('error.item_not_exist'), 'error')
            return
        end
        local amount = tonumber(amount)
        local slot = tonumber(slot) or QBCore.Player.GetFirstSlotByItem(self.items, item)
        if itemInfo['type'] == 'weapon' and info == nil then
            info = {
                serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4)),
            }
        end
        if (totalWeight + (itemInfo['weight'] * amount)) <= QBCore.Config.Player.MaxWeight then
            if (slot and self.items[slot]) and (self.items[slot].name:lower() == item:lower()) and (itemInfo['type'] == 'item' and not itemInfo['unique']) then
                self.items[slot].amount = self.items[slot].amount + amount
                self:UpdatePlayerData()
                TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. self.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.items[slot].amount)
                return true
            elseif (not itemInfo['unique'] and slot or slot and self.items[slot] == nil) then
                self.items[slot] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = slot, combinable = itemInfo['combinable'] }
                self:UpdatePlayerData()
                TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. self.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.items[slot].amount)
                return true
            elseif (itemInfo['unique']) or (not slot or slot == nil) or (itemInfo['type'] == 'weapon') then
                for i = 1, QBConfig.Player.MaxInvSlots, 1 do
                    if self.items[i] == nil then
                        self.items[i] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = i, combinable = itemInfo['combinable'] }
                        self:UpdatePlayerData()
                        TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** got item: [slot:' .. i .. '], itemname: ' .. self.items[i].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.items[i].amount)
                        return true
                    end
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', self.source, Lang:t('error.too_heavy'), 'error')
        end
        return false
    end

    function Class:RemoveItem(item, amount, slot)
        local amount = tonumber(amount)
        local slot = tonumber(slot)
        if slot then
            if self.items[slot].amount > amount then
                self.items[slot].amount = self.items[slot].amount - amount
                self:UpdatePlayerData()
                TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. self.items[slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. self.items[slot].amount)
                return true
            elseif self.items[slot].amount == amount then
                self.items[slot] = nil
                self:UpdatePlayerData()
                TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. item .. ', removed amount: ' .. amount .. ', item removed')
                return true
            end
        else
            local slots = QBCore.Player.GetSlotsByItem(self.items, item)
            local amountToRemove = amount
            if slots then
                for _, slot in pairs(slots) do
                    if self.items[slot].amount > amountToRemove then
                        self.items[slot].amount = self.items[slot].amount - amountToRemove
                        self:UpdatePlayerData()
                        TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. self.items[slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. self.items[slot].amount)
                        return true
                    elseif self.items[slot].amount == amountToRemove then
                        self.items[slot] = nil
                        self:UpdatePlayerData()
                        TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. item .. ', removed amount: ' .. amount .. ', item removed')
                        return true
                    end
                end
            end
        end
        return false
    end

    function Class:SetInventory(items, dontUpdateChat)
        self.items = items
        self:UpdatePlayerData(dontUpdateChat)
        TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'SetInventory', 'blue', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** items set: ' .. json.encode(items))
    end

    function Class:ClearInventory()
        self.items = {}
        self:UpdatePlayerData()
        TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'ClearInventory', 'red', '**' .. GetPlayerName(self.source) .. ' (citizenid: ' .. self.citizenid .. ' | id: ' .. self.source .. ')** inventory cleared')
    end

    function Class:GetItemByName(item)
        local item = tostring(item):lower()
        local slot = QBCore.Player.GetFirstSlotByItem(self.items, item)
        if slot then
            return self.items[slot]
        end
        return nil
    end

    function Class:GetItemsByName(item)
        local item = tostring(item):lower()
        local items = {}
        local slots = QBCore.Player.GetSlotsByItem(self.items, item)
        for _, slot in pairs(slots) do
            if slot then
                items[#items+1] = self.items[slot]
            end
        end
        return items
    end

    function Class:SetCreditCard(cardNumber)
        self.info.card = cardNumber
        self:UpdatePlayerData()
    end

    function Class:GetCardSlot(cardNumber, cardType)
        local item = tostring(cardType):lower()
        local slots = QBCore.Player.GetSlotsByItem(self.items, item)
        for _, slot in pairs(slots) do
            if slot then
                if self.items[slot].info.cardNumber == cardNumber then
                    return slot
                end
            end
        end
        return nil
    end

    function Class:GetItemBySlot(slot)
        local slot = tonumber(slot)
        if self.items[slot] then
            return self.items[slot]
        end
        return nil
    end

    function Class:Save()
        QBCore.Player.Save(self.source)
    end

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

XSystem.characters = {}

function XSystem.characters:create()
    XSystem.core.class.character()
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

-- print to check if everything is set within
print(Xs)

local char = XSystem.core.class.character({})

-- trigger the correct system functions when the player triggered one of the events underneath
AddEventHandler('playerConnecting', Xs.connect.conn)
AddEventHandler('playerJoining',    Xs.connect.join)
AddEventHandler('playerDropped',    Xs.connect.drop)

-- copy/paste --> Xs = exports.XSystem:GetSystem()

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

exports('GetSystem', function()
    return Xs
end)