function __sql()

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

    Sql.__tostring = ToStringDebugger
    Sql.__metatable = nil

    return setmetatable({}, Sql)

end