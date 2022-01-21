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
	'private/classes/__debug.lua',
	'private/classes/__types.lua',
	'private/classes/__sql.lua', --[[
		__sql.lua is not safe and ready to use yet, dont enable it!!!
	]]

	'private/classes/__pool.lua',
	'private/classes/__session.lua',

	-- load files which monitor the client data
	'private/main.lua',
	'private/monitor.lua'

}

dependency 'connectqueue' 
--[[ TODO EVERYONE

	within connectqueue change line 660 to -> exports('SEND_TO_QUEUE', playerConnect)
	and add the src variable ar parameter to the function

	if you dont want to use connectqueue simply comment line 70 and uncomment 71

	For people working with QBCore comment lines 43 till line 87

]]