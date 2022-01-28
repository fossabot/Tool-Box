fx_version 'cerulean'
game 'gta5'

version '0.6.7'

author 'Sm1Ly'
discord 'Sm1Ly#1111'
github 'https://github.com/5m1Ly'
description 'Keep track of client data on the server side using 1 identifier related to all owned and previously owend identifiers'

server_scripts {

	-- load sql library
	'@oxmysql/lib/MySQL.lua',

	-- load config
	'config/private.lua',

	-- load files which hold classes for the monitoring process
	'private/classes/__types.lua',
	'private/classes/__debug.lua',
	'private/classes/__sql.lua',
	'private/classes/__pool.lua',
	'private/classes/__session.lua',
	'private/classes/__msg.lua',

	-- load files which monitor the client data
	'private/monitor.lua'

}

dependency 'connectqueue'