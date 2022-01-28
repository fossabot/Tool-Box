CONFIG = {
	SERVER_NAME = '5 pixel', -- your server name
	WHITELISTED = true,
    DEFER_STRINGS = {
        TITLE = "Welkom bij %s %s, wij maken ons klaar voor jouw avontuur.", -- msg displayed on top
        PROCESSES = {
            "creating session", -- step 1 when connecting
            "getting/adding data", -- step 2 when connecting
            "storing session", -- step 3 when connecting
            "saving session data", -- step 4 when connecting
            "done.... joining within a few seconds", -- step 5 when connecting
        },
        NOT_ON_LIST = "Je moet op de whitelist staan om hier te kunnen spelen..." -- kick msg when user doesn't have a whitelist
    },
	PERMISSIONS = {
		{ LABEL = 'BURGER', 		SHORT_NAME = 'USER' },
		{ LABEL = 'TESTER', 		SHORT_NAME = 'TEST' },
		{ LABEL = 'MODERATOR', 		SHORT_NAME = 'MOD' },
		{ LABEL = 'ADMINISTRATOR', 	SHORT_NAME = 'ADMIN' },
		{ LABEL = 'DEVELOPER', 		SHORT_NAME = 'DEV' },
	},
	QUEUE = {
		{ LABEL = 'STANDAART', 	BEHAVIOR_SCORE = 0 },
		{ LABEL = '4e PRIO', 	BEHAVIOR_SCORE = 10 },
		{ LABEL = '3e PRIO', 	BEHAVIOR_SCORE = 20 },
		{ LABEL = '2e PRIO', 	BEHAVIOR_SCORE = 30 },
		{ LABEL = '1e PRIO', 	BEHAVIOR_SCORE = 40 },
	}
}