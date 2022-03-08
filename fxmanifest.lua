fx_version 'cerulean'
game 'gta5'

version '0.1.0'

author 'Sm1Ly'
discord 'Sm1Ly#1111'
github 'https://github.com/5m1Ly'
description 'Keep track of client data on the server side using 1 identifier related to all owned and previously owend identifiers'

-- // load Shared Data \\
shared_scripts {
    'src/shared/main.lua',
}

-- // load Server Side \\
server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'src/server/main.lua'
}

-- // load Client Side \\
client_scripts {
	'src/client/main.lua'
}

dependency 'oxmysql'