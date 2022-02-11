function identifiers(src)

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

    local currentIds = GetPlayerIdentifiers(src)
    for i = 1, #currentIds, 1 do
        local id = split(currentIds[i], ':')
        ids(id[1], id[2])
    end

    return ids
end