Cfg = {
    System = {
        Info = {
            name = '5 Pixel',
            max_clients = 0,
            debug_mode = true,
        },
        Perms = {
            { id = 'user',  label = 'Burger' },
            { id = 'mod',   label = 'Moderator' },
            { id = 'admin', label = 'Administrator' },
            { id = 'dev',   label = 'Developer' },
        }
    }
}

-- handles the config and makes sure it can't be edited
function GetConfig(tbl)
    return setmetatable(tbl or Cfg, {
        __index = function(self, key)
            if self.ids[key] ~= nil then
                return self.ids[key]
            else
                print("^1CONFIG:ERROR | wanted to fetch non existing value (key: "..key..")^0")
            end
        end,
        __newindex = function(self, key, value)
            if self.ids[key] ~= nil then
                print("^1CONFIG:ERROR | wanted to modify a value (key: "..key..", value: "..value..")^0")
            else
                print("^1CONFIG:ERROR | wanted to add a new value (key: "..key..", value: "..value..")^0")
            end
        end,
        __call = function(self, key)
            local retval
            if self[key] ~= nil then
                local retval
                if type(self[key]) == 'table' then
                    retval = GetConfig(self[key])
                else
                    retval = self[key]
                end
                return retval
            else
                print("^1CONFIG:ERROR | wanted to fetch non existing value (key: "..key..")^0")
            end
        end,
        __metatable = nil
    })
end