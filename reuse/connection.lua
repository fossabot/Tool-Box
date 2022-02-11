local DEBUG = _DEBUG:INIT()

RegisterNetEvent("toggle:debug-mode", function()
    DEBUG:TOGGLE()
end)

-- creating pools for active and inactive sessions
ACTIVE_SESSIONS = _POOL:INIT()
INACTIVE_SESSIONS = _POOL:INIT()

local function CONNECT_MONITOR(NAME, SET_KICK_REASON, DEFERRALS)

	local SOURCE = tonumber(source)
	local CFG = CONFIG

	-- check if session exists within pool for the client (note: added cus somehow the connecting event triggered twice)
	if ACTIVE_SESSIONS.POOL[SOURCE] == nil then

        local MSG = _MESSAGES:INIT(NAME, DEFERRALS)
        Wait(10)

        MSG:SEND() -- let client know we are creating a session
		local SESSION = _SESSION:INIT(SOURCE, NAME) -- start a new session		
		ACTIVE_SESSIONS:ADD_SESSION(SOURCE, SESSION) -- add the session to the active sessions pool
		Wait(1000)

        DEBUG:LOG(SESSION, "Connect Monitor Function", "info")

		MSG:SEND() -- let client know we are creating its data
		SESSION:SET_DATA() -- format the session for the client
		Wait(1250)

        MSG:SEND() -- let client know we are update thier session in pool
		ACTIVE_SESSIONS:SET_SESSION(SOURCE, SESSION) -- initialize the session data
		Wait(1500)

        MSG:SEND() -- let client know we are now about to save thier data
		SESSION:SAVE_DATA() -- save the session data
		Wait(1250)

		if (CONFIG.WHITELISTED and SESSION.QUEUE.WHITELISTED) or not CONFIG.WHITELISTED then
            MSG:SEND() -- let client know we are now ready and that they will join within a few secconds
			Wait(2500)
			exports.BabyMonitor:SEND_TO_QUEUE(SOURCE, NAME, SET_KICK_REASON, DEFERRALS)
		else
			DEFERRALS.DONE(CFG.DEFER_MSGS.NOT_ON_LIST)
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