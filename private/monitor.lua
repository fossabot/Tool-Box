-- creating pools for active and inactive sessions
ACTIVE_SESSIONS = _POOL:CREATE()
INACTIVE_SESSIONS = _POOL:CREATE()

local function CONNECT_MONITOR(NAME, SET_KICK_REASON, DEFER)

	local SOURCE = tonumber(source)
	local CFG = CONFIG

	-- check if session exists within pool for the client (note: added cus somehow the connecting event triggered twice)
	if ACTIVE_SESSIONS.POOL[SOURCE] == nil then

		-- a function te format the connection progress within a string
		local function CREATE_PROGRESS_STRING(MSG, DOING)
			local PROGRESS = (100 / #CFG.DEFERALS_TEXT) * MSG --TODO: look for better way to keep track of loading percentage
			local VISUAL_PROGRESS = math.floor(PROGRESS / 5)
			local FRONT_VISUAL = VISUAL_PROGRESS
			local BACK_VISUAL = 20 - VISUAL_PROGRESS
			local PROGRESS_STRING = ('[%s%s] '):format(
				string.rep('/', FRONT_VISUAL),
				string.rep('~', BACK_VISUAL)
			)..PROGRESS
			return PROGRESS_STRING
		end
	
		-- send a message with the 
		local function MSG(SRC, DEFER, MSG, DOING, ...)
			local PROGRESS = CREATE_PROGRESS_STRING(MSG, DOING)
			MSG = CFG.DEFERALS_TEXT[MSG]
			MSG = MSG:format(...)
			DEFER.update(MSG..'\n'..PROGRESS..'% '..DOING)
		end

		DEFER.defer()

		-- let client know we are creating a session
		MSG(SOURCE, DEFER, 1, "creating session", CONFIG.SERVER_NAME, NAME)

		-- start a new session
		local SESSION = _SESSION:START(SOURCE, NAME)

		-- add the session to the active sessions pool
		ACTIVE_SESSIONS:ADD_SESSION(SOURCE, SESSION)
		Wait(600)

		-- let client know we are creating its data
		MSG(SOURCE, DEFER, 2, "getting/adding data", CONFIG.SERVER_NAME, NAME)

		-- format the session for the client
		SESSION:SET_DATA()
		Wait(900)

		-- let client know we are update thier session in pool
		MSG(SOURCE, DEFER, 3, "storing session", CONFIG.SERVER_NAME, NAME)

		ACTIVE_SESSIONS:SET_SESSION(SOURCE, SESSION)
		Wait(1000)

		-- let client know we are now about to save thier data
		MSG(SOURCE, DEFER, 4, "saving session data", CONFIG.SERVER_NAME, NAME)

		-- save the session data
		SESSION:SAVE_DATA()
		Wait(600)

		if (CONFIG.WHITELISTED and SESSION.QUEUE.WHITELISTED) or not CONFIG.WHITELISTED then
			-- let client know we are now ready and that they will join within a few secconds
			MSG(SOURCE, DEFER, 5, "done.... joining within a few seconds", CONFIG.SERVER_NAME, NAME)
			Wait(2000)
			exports.connectqueue:SEND_TO_QUEUE(SOURCE, NAME, SET_KICK_REASON, DEFER)
			-- DEFER.done()
		else
			DEFER.done('Je moet op de whitelist staan om hier te kunnen spelen...')
		end

	end

end

local function JOIN_MONITOR(TEMP_SOURCE)

	-- define new source
	local TEMP_SOURCE = tonumber(TEMP_SOURCE)
	local PERM_SOURCE = tonumber(source)

	-- get session with temp source
	local SESSION = ACTIVE_SESSIONS:GET_SESSION(TEMP_SOURCE)

	-- update the session data
	SESSION:UPDATE_DATA('PERM_SOURCE', PERM_SOURCE)
	SESSION:UPDATE_DATA('TIME_CONNECTED', os.clock())

	-- add the session to the pool with the new source
	ACTIVE_SESSIONS:ADD_SESSION(PERM_SOURCE, SESSION)

	-- remove the session stored with the old source
	ACTIVE_SESSIONS:REMOVE_SESSION(TEMP_SOURCE)

end

local function LEAVE_MONITOR(reason)
    
	local SOURCE = tonumber(source)
	local SESSION = ACTIVE_SESSIONS:GET_SESSION(SOURCE)

	-- calculate new play time
	SESSION.INFORMATION.PLAYTIME = math.floor(SESSION.INFORMATION.PLAYTIME + (os.clock() - SESSION.TIME_CONNECTED))

	print(SESSION.NAME.." now has a total play time of "..SESSION.INFORMATION.PLAYTIME.."s")

	-- save session data
	SESSION:SAVE_DATA()
	Wait(100)

	-- add session to inactive sessions pool
	INACTIVE_SESSIONS:ADD_SESSION(SESSION.IDENTIFIERS.LICENSE[1], SESSION)
	Wait(100)

	ACTIVE_SESSIONS:REMOVE_SESSION(SOURCE)
	Wait(100)

end

-- execute monitor functions when event is triggerd
AddEventHandler('playerConnecting', CONNECT_MONITOR)
AddEventHandler('playerJoining', JOIN_MONITOR)
AddEventHandler('playerDropped', LEAVE_MONITOR)