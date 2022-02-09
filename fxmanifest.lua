fx_version 'cerulean'
game 'gta5'

version '0.8.4'

author 'Sm1Ly'
discord 'Sm1Ly#1111'
github 'https://github.com/5m1Ly'
description 'Keep track of client data on the server side using 1 identifier related to all owned and previously owend identifiers'

-- load sql library
server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
    
	-- load config
	'config/config.lua',
	'config/config.class.lua',

}

server_scripts {

	-- load core class mimics
	'src/test.lua',
    
}

dependency 'oxmysql'