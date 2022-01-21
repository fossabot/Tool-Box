_SESSION = {}

-- set default data for a session
function _SESSION:START(_SOURCE, _NAME)
	-- session data template
	DATA = {
		TEMP_SOURCE = _SOURCE,
		PERM_SOURCE = 0,
		STOP_TIMEOUT = 5,
		CLIENT_ID = '',
		NAME = _NAME,
		INFORMATION = {
			BEHAVIOR_SCORE = 0,
			PLAYTIME = 0,
			LANGUAGE = '',
		},
		TIME_CONNECTED = 0,
		PERMISSIONS = {
			LEVEL = 1, -- holds saved perm level
			LABEL = 'BURGER', -- holds label form self.PERMISSIONS searched by level
			SHORT_NAME = 'USER', -- holds short name form self.PERMISSIONS searched by level
			SSN = '', -- holds social security number of character that is optin by default
			OPTIN = false, -- holds bool which gets set when selecting a character
		},
		QUEUE = {
			LEVEL = 1, -- holds level gotten from self.QUEUE based on permission level of behavior score
			LABEL = 'STANDAART', -- holds label of the queue
			WHITELISTED = true
		},
		IDENTIFIERS = {} -- variable NEW_IDS gets added to this table
	}
	setmetatable(DATA, self)
	self.__index = self
	return DATA
end

-- add client identifiers, perms, language, etc
function _SESSION:SET_DATA()

	local CFG = CONFIG

	local CURRENT_IDENTIFIERS = GetPlayerIdentifiers(self.TEMP_SOURCE)
	local SAVED_CLIENT_DATA = nil
	local OLD_SESSION_INDEX = 0

	local NEW_IDS = {
		IP = {}, -- holds known ips
		XBL = {}, -- holds known xbox live ids
		LIVE = {}, -- holds known known microsoft ids
		STEAM = {}, -- holds known steam ids
		FIVEM = {}, -- holds known fivem ids
		DISCORD = {}, -- holds known discord ids
		LICENSE = {}, -- holds known rockstar license 1
		LICENSE2 = {} -- holds known rockstar license 2
	}

	-- add current identifiers to the session template
	for i = 1, #CURRENT_IDENTIFIERS do
		local ID = DT:STRING_SPLIT(CURRENT_IDENTIFIERS[i], ':')
		if (ID and ID[1] and ID[2]) ~= nil then
			local ID_TYPE = ID[1]:upper()
			local ID_STR = ID[2]
			table.insert(NEW_IDS[ID_TYPE], ID_STR)
			if ID_TYPE == 'LICENSE' then OLD_SESSION_INDEX = ID_STR end
		end
	end

	local INACTIVE_SESSION = INACTIVE_SESSIONS:GET_SESSION(OLD_SESSION_INDEX)

	-- check if an inactive session is found
	if INACTIVE_SESSION ~= nil then

		-- add the inactive session data to the session template if it found any otherwise set new client session defaults
		-- use existing or new client id
		self.CLIENT_ID = INACTIVE_SESSION ~= nil and INACTIVE_SESSION.CLIENT_ID or 'RPX-'..DT:GENERATE_ID(10)

		-- use existing or current info
		self.INFORMATION = INACTIVE_SESSION ~= nil and INACTIVE_SESSION.INFORMATION or self.INFORMATION

		-- use existing or current perms
		self.PERMISSIONS = INACTIVE_SESSION ~= nil and INACTIVE_SESSION.PERMISSIONS or self.PERMISSIONS
		self.PERMISSIONS.LABEL = CFG.PERMISSIONS[self.PERMISSIONS.LEVEL].LABEL
		self.PERMISSIONS.SHORT_NAME = CFG.PERMISSIONS[self.PERMISSIONS.LEVEL].SHORT_NAME
		self.PERMISSIONS.OPTIN = false

		-- now for the queue prio we need information from above and use this information while we loop trought the queue levels
		self.QUEUE = INACTIVE_SESSION ~= nil and INACTIVE_SESSION.QUEUE or self.QUEUE

		self.IDENTIFIERS = INACTIVE_SESSION.IDENTIFIERS

		for _TYPE, _IDS in pairs(self.IDENTIFIERS) do
			for i = 1, #_IDS do
				if _IDS[i] ~= NEW_IDS[_TYPE][1] then
					table.insert(self.IDENTIFIERS[_TYPE], NEW_IDS[_TYPE][1])
				end
			end
			Wait(250)
		end

		INACTIVE_SESSIONS:REMOVE_SESSION(OLD_SESSION_INDEX)

	else

		self.IDENTIFIERS = NEW_IDS

		for _TYPE, _IDS in pairs(self.IDENTIFIERS) do	
			for i = 1, #_IDS do
				local ID = _IDS[i]
				SAVED_CLIENT_DATA = SQL_EXEC_QUERY('SYNC SELECT * FROM clients WHERE identifiers LIKE ?', { '%'..ID..'%' })
				if SAVED_CLIENT_DATA[1] ~= nil then break end
			end
			if SAVED_CLIENT_DATA[1] ~= nil then break end
			Wait(250)
		end

		-- add the saved data to the session template if it found any otherwise set new client session defaults
		-- use existing or new client id
		self.CLIENT_ID = SAVED_CLIENT_DATA[1] ~= nil and SAVED_CLIENT_DATA[1].client_id or 'RPX-'..DT:GENERATE_ID(10)

		-- use existing or current info
		self.INFORMATION = SAVED_CLIENT_DATA[1] ~= nil and json.decode(SAVED_CLIENT_DATA[1].INFORMATION) or self.INFORMATION
		
		-- use existing or current perms
		self.PERMISSIONS = SAVED_CLIENT_DATA[1] ~= nil and json.decode(SAVED_CLIENT_DATA[1].perms) or {
			LEVEL = 1,
			SSN = '',
			LABEL = '',
			SHORT_NAME = '',
			OPTIN = false
		} --TODO: figure out why CONFIG.PERMISSIONS[self.PERMISSIONS.LEVEL] returned nil (note: not propperly connected to db at the time)

		self.PERMISSIONS.LABEL = CONFIG.PERMISSIONS[self.PERMISSIONS.LEVEL].LABEL
		self.PERMISSIONS.SHORT_NAME = CONFIG.PERMISSIONS[self.PERMISSIONS.LEVEL].SHORT_NAME
		self.PERMISSIONS.OPTIN = false

		-- now for the queue prio we need information from above and use this information while we loop trought the queue levels
		self.QUEUE = SAVED_CLIENT_DATA[1] ~= nil and json.decode(SAVED_CLIENT_DATA[1].queue) or self.QUEUE

	end

	local SET_LEVEL = 0

	for i = 1, #CFG.QUEUE do
		if self.PERMISSIONS.LEVEL == 1 then
			if self.INFORMATION.BEHAVIOR_SCORE >= CFG.QUEUE[i].BEHAVIOR_SCORE and self.INFORMATION.BEHAVIOR_SCORE <= CFG.QUEUE[i+1].BEHAVIOR_SCORE then
				SET_LEVEL = SET_LEVEL + 1
			else break end
		else
			SET_LEVEL = self.PERMISSIONS.LEVEL
			break
		end
	end

	self.QUEUE.LEVEL = SET_LEVEL
	self.QUEUE.LABEL = CFG.QUEUE[SET_LEVEL].LABEL

end

function _SESSION:UPDATE_DATA(_DATATYPE, _NEWDATA)
	if type(_DATATYPE) == 'table' then
		self[_DATATYPE[1]][_DATATYPE[2]] = _NEWDATA
	else
		self[_DATATYPE] = _NEWDATA
	end
end

-- save session in the data base
function _SESSION:SAVE_DATA()

	local SAVE_DATA = {
		CLIENT_ID 		= self.CLIENT_ID,
		NAME 			= self.NAME,
		INFORMATION 	= self.INFORMATION,
		PERMISSIONS = {
			LEVEL 		= self.PERMISSIONS.LEVEL, -- holds saved perm level
			SSN 		= self.PERMISSIONS.SSN, -- holds social security number of character that is optin by default
		},
		QUEUE = {
			WHITELISTED = self.QUEUE.WHITELISTED
		},
		IDENTIFIERS = self.IDENTIFIERS
	}

	-- print to check what we want to save
	-- DEBUG:LOG(SAVE_DATA)

	-- save actual data
	MySQL.Async.insert('INSERT INTO clients (client_id, name, info, perms, queue, identifiers) VALUES (:clientId, :name, :info, :perms, :queue, :identifiers) ON DUPLICATE KEY UPDATE name = :name, info = :info, perms = :perms, queue = :queue, identifiers = :identifiers', {
		clientId = SAVE_DATA.CLIENT_ID,
		name = SAVE_DATA.NAME,
		info = json.encode(SAVE_DATA.INFORMATION),
		perms = json.encode(SAVE_DATA.PERMISSIONS),
		queue = json.encode(SAVE_DATA.QUEUE),
		identifiers = json.encode(SAVE_DATA.IDENTIFIERS)
	})

end
