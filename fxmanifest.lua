fx_version 'cerulean'
game 'gta5'

version '0.1.0'

author 'Sm1Ly'
discord 'Sm1Ly#1111'
github 'https://github.com/5m1Ly'
description 'Keep track of client data on the server side using 1 identifier related to all owned and previously owend identifiers'

-- // load Shared Sync System \\
shared_scripts {
    'src/xsys/sh/cfg/config.lua',
    'src/xsys/sh/class/__meta.lua',
    'src/xsys/sh/class/bucket.lua',
    'src/xsys/sh/xsys.lua',
    'src/xsys/sh/sync.lua',
}

-- // load Server System \\
server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'src/xsys/sv/class/*.lua',
	'src/xsys/sv/xsys.lua'
}

-- // load Client System \\
client_scripts {
	'src/xsys/cl/xsys.lua'
}

dependency 'oxmysql'