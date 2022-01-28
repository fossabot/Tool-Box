_sql = {}

local EXEC_FUNCTIONS = {
    ['SYNC-INSERT'] = MySQL.Sync.insert,
    ['SYNC-SELECT'] = MySQL.Sync.fetchAll,
    ['SYNC-UPDATE'] = MySQL.Sync.execute,
    ['SYNC-DELETE'] = MySQL.Sync.execute,
    ['ASYNC-INSERT'] = MySQL.Async.insert,
    ['ASYNC-SELECT'] = MySQL.Async.fetchAll,
    ['ASYNC-UPDATE'] = MySQL.Async.execute,
    ['ASYNC-DELETE'] = MySQL.Async.execute
}

-- function to use sql
function _sql:assign(TBL)
    local TBL = {
        Q = "",
        D = {},
        F = function() return end
    }
    setmetatable(TBL, self)
    self.__index = self
    return TBL
end

-- function to prepare the query for execution
---@param QUERY string - query starting with 'SYNC' or 'ASYNC'
function _sql:query(QUERY)
    -- split the query on space
    local QSPLIT = DT:STRING_SPLIT(QUERY, " ")
    -- check if query contains sync or async
    if QSPLIT[1] == "SYNC" or QSPLIT[1] == "ASYNC" then
        -- remove the sync or async then we get an executeble query
        self.Q = QSPLIT[1] == "SYNC" and QUERY:gsub("SYNC ", "", 1) or QUERY:gsub("ASYNC ", "", 1)
        -- create query type to get the correct index
        local TYPE = QSPLIT[1]..'-'..QSPLIT[2]
        self.F = EXEC_FUNCTIONS[TYPE]
    else
        print("SQL:ERROR -> Query needs to start with 'SYNC' or 'ASYNC', got '"..QUERY.."' instead!")
        return false
    end
end

-- function to prepare the query for execution
---@param DATA table - table containing data to be processed for execution
function _sql:data(DATA)
    if DATA ~= nil and type(DATA) == "table" then
        self.D = {} -- empty the table, important so dont touch
        for KEY, VALUE in pairs(DATA) do
            if type(VALUE) == 'table' then 
                self.D[KEY] = json.encode(VALUE)
            else
                self.D[KEY] = VALUE
            end
        end
    else
        print("SQL:ERROR -> data needs to be a table, got '"..type(DATA).."' instead!")
        return false
    end
end

-- function to prepare the query for execution
---@param CB function - callback function with the result as parameter
function _sql:exec(CB)
	-- now execute the query by selecting a function
    local RESULT = self.F(self.Q, self.D)
    -- return data within callback or just a return
    if CB ~= nil then CB(RESULT) else return RESULT end
end

exports('_sql', _sql)