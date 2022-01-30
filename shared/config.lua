local CFG = {
    DEBUG_MODE = true, -- set default debug mode state en/disabled
	SERVER_NAME = '5 pixel', -- your server name
	WHITELISTED = true, -- toggle server whitelisting
    SERVER = {
        NAME = '5 pixel', -- your server name
        MAX_PLAYERS = GetConvarInt("sv_maxclients", 30), -- your server name
        DEBUG_MODE = true, -- set default debug mode state en/disabled
        WHITELISTED = true, -- toggle server whitelisting
    },
    DEFER_STRINGS = {
        TITLE = "Welkom bij %s %s, wij maken ons klaar voor jouw avontuur.",
        PROCESSES = {
            "creating session", -- step 1
            "getting/adding data", -- step 2
            "storing session", -- step 3
            "saving session data", -- step 4
            "done.... joining within a few seconds", -- step 5
        },
        NOT_ON_LIST = "Je moet op de whitelist staan om hier te kunnen spelen..." -- no whitelist
    },
	PERMISSIONS = {
		{ LABEL = 'Burger', 		SHORT_NAME = 'USER' },
		{ LABEL = 'Tester', 		SHORT_NAME = 'TEST' },
		{ LABEL = 'Moderator', 		SHORT_NAME = 'MOD' },
		{ LABEL = 'Administrator', 	SHORT_NAME = 'ADMIN' },
		{ LABEL = 'Developer', 		SHORT_NAME = 'DEV' },
	},
	QUEUE = {
        LISTS = {
            { LABEL = 'Standaard', 	BEHAVIOR_SCORE = 0 },
            { LABEL = '4e prio', 	BEHAVIOR_SCORE = 10 },
            { LABEL = '3e prio', 	BEHAVIOR_SCORE = 20 },
            { LABEL = '2e prio', 	BEHAVIOR_SCORE = 30 },
            { LABEL = '1e prio', 	BEHAVIOR_SCORE = 40 },
        },
        INFO = {
            JOIN_DELAY = 30000
        }
	}
}

--[[ english
    local CFG = {
        DEBUG_MODE = true, -- en/disable debug mode by default
        SERVER_NAME = '*server name*', -- your server name
        WHITELISTED = true, -- en/disable whitelisting
        DEFER_STRINGS = {
            TITLE = "Welcome to %s %s, were getting ready for your adventure.", -- msg displayed on top
            PROCESSES = {
                "creating session", -- step 1 when connecting
                "getting/adding data", -- step 2 when connecting
                "storing session", -- step 3 when connecting
                "saving session data", -- step 4 when connecting
                "done.... joining within a few seconds", -- step 5 when connecting
            },
            NOT_ON_LIST = "You need to be whitelisted to join this server..." -- kick msg when user doesn't have a whitelist
        },
        PERMISSIONS = { -- these are all the permission levels
            { LABEL = 'Citizen', 		SHORT_NAME = 'USER' },
            { LABEL = 'Tester', 		SHORT_NAME = 'TEST' },
            { LABEL = 'Moderator', 		SHORT_NAME = 'MOD' },
            { LABEL = 'Administrator', 	SHORT_NAME = 'ADMIN' },
            { LABEL = 'Developer', 		SHORT_NAME = 'DEV' },
        },
        QUEUE = { -- these are all the queues for the players
            { LABEL = 'Default', 	BEHAVIOR_SCORE = 0 },
            { LABEL = '4th prio', 	BEHAVIOR_SCORE = 10 },
            { LABEL = '3th prio', 	BEHAVIOR_SCORE = 20 },
            { LABEL = '2th prio', 	BEHAVIOR_SCORE = 30 },
            { LABEL = '1th prio', 	BEHAVIOR_SCORE = 40 },
        }
    }
]]--

CONFIG = {}

function CONFIG:INIT(SPECIFIER)

    SPECIFIER = type(SPECIFIER) == 'table' and SPECIFIER or { SPECIFIER }

    local RETVAL = {}

    if SPECIFIER == nil then RETVAL = CFG else
        for I = 1, #SPECIFIER do
            local CURRENT = SPECIFIER[I]
            RETVAL[CURRENT] = CFG[CURRENT]
        end
    end

    setmetatable(RETVAL, self)
	self.__index = self

    return RETVAL

end