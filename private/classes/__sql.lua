local function SQL_ERROR_HANDELING(_QUERY, _PARAMETERS)

	local retval = false

	if _QUERY == nil or type(_QUERY) ~= 'string' then
		DEBUG:ERROR('query given to QUERY should be a string, got "?" instead', {
			type(_QUERY)
		})
		retval = true
	end

	if _PARAMETERS == nil or type(_PARAMETERS) ~= 'table' then
		DEBUG:ERROR('params given to QUERY should be placed within a table, got "?" instead', {
			type(_PARAMETERS)
		})
		retval = true
	end

	return retval

end

local function SQL_SPLIT_QUERY(_QUERY, _DELIMITER)

    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(_QUERY, _DELIMITER, from)

	while delim_from do
		result[#result+1] = string.sub(_QUERY, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(_QUERY, _DELIMITER, from)
    end

	result[#result+1] = string.sub(_QUERY, from)

	return result

end

local function SQL_BUILD_QUERY(_QUERY)

	-- split the query on space
	local SPLIT_QUERY = SQL_SPLIT_QUERY(_QUERY, " ")

	-- check if query contains sync or async
	if SPLIT_QUERY[1] == "SYNC" or SPLIT_QUERY[1] == "ASYNC" then

		-- remove the sync or async then we get an executeble query
		local EXECUTABLE_QUERY = SPLIT_QUERY[1] == "SYNC" and _QUERY:gsub("SYNC ", "", 1) or _QUERY:gsub("ASYNC ", "", 1)

		-- create query type to get the correct index
		local QUERY_TYPE = SPLIT_QUERY[1]..'-'..SPLIT_QUERY[2]

		-- now return the query and query type
		return EXECUTABLE_QUERY, QUERY_TYPE

	else

		-- a print to indicate what is wrong
		print("Given query needs to start with SYNC or ASYNC")

	end

end

local function SQL_PROCESS_PARAMETERS(_PARAMETERS)
	local RETVAL_PARAMS = {}
	if type(_PARAMETERS) ~= 'table' then
		table.insert(RETVAL_PARAMS, _PARAMETERS)
	else
		for KEY, VALUE in pairs(_PARAMETERS) do
			if type(VALUE) == 'table' then VALUE = json.encode(VALUE) end
			table.insert(RETVAL_PARAMS, VALUE)
		end
	end
	return RETVAL_PARAMS
end

-- save the other one in case the first on doesnt work
function SQL_EXEC_QUERY(_QUERY, _PARAMETERS, _CALLBACK)

	-- function trigger to check if the correct parameters are given
	if SQL_ERROR_HANDELING(_QUERY, _PARAMETERS) then return end

	-- a list with functions we are able to execute the query with
	local SQL_FUNCTIONS = {
		['SYNC-INSERT'] = MySQL.Sync.insert,
		['SYNC-SELECT'] = MySQL.Sync.fetchAll,
		['SYNC-UPDATE'] = MySQL.Sync.execute,
		['SYNC-DELETE'] = MySQL.Sync.execute,
		['ASYNC-INSERT'] = MySQL.Async.insert,
		['ASYNC-SELECT'] = MySQL.Async.fetchAll,
		['ASYNC-UPDATE'] = MySQL.Async.execute,
		['ASYNC-DELETE'] = MySQL.Async.execute
	}

	-- transform the query into an executeble one and recieve the type op function we want to use
	local SQL_EXEC_QUERY, SQL_FUNCTION_TYPE = SQL_BUILD_QUERY(_QUERY)

	-- assign the function we want to use to a new var
	local SQL_EXEC_FUNCTION = SQL_FUNCTIONS[SQL_FUNCTION_TYPE]

	-- check the parameter types and json encode tables
	local SQL_PARAMETERS = SQL_PROCESS_PARAMETERS(_PARAMETERS)

	-- now execute the query by selecting a function
	local QUERY_RESULT = SQL_EXEC_FUNCTION(SQL_EXEC_QUERY, SQL_PARAMETERS)

	-- return data within callback or just a return
	if _CALLBACK ~= nil then _CALLBACK(QUERY_RESULT) else return QUERY_RESULT end

end

-- exports('QUERY', SQL_EXEC_QUERY)