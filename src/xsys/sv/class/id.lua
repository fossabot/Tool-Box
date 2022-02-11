function identifiers(src)

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
        __len = FullTableLength,
        __tostring = ToStringDebugger,
        __metatable = nil
    })

    local sql = __sql()
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