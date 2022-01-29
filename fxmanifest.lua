fx_version 'cerulean'
game 'gta5'

version '0.6.7'

author 'Sm1Ly'
discord 'Sm1Ly#1111'
github 'https://github.com/5m1Ly'
description 'Keep track of client data on the server side using 1 identifier related to all owned and previously owend identifiers'

-- load sql library
server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
    
	-- load config
	'shared/config.lua',

}

server_scripts {

	-- load core class mimics
	'private/classes/core/__types.lua',
	'private/classes/core/__debug.lua',
	'private/classes/core/__sql.lua',

	-- load feature class mimics
	'private/classes/feature/__pool.lua',
	'private/classes/feature/__session.lua',
	'private/classes/feature/__msg.lua',

	-- load handlers
	'private/handlers/connection.lua'

}

dependencies {
    'oxmysql',
    'connectqueue'
}