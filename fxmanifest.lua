fx_version 'cerulean'
game 'gta5'

version '0.1.0'

author 'Sm1Ly'
discord 'Sm1Ly#1111'
github 'https://github.com/5m1Ly'
description 'Keep track of client data on the server side using 1 identifier related to all owned and previously owend identifiers'

-- // load Config System \\
shared_scripts {
    'src/xsys/sh/config.lua',
    'src/xsys/sh/__meta.lua',
}

-- // load Server System \\
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'src/xsys/sv/**/__meta.lua',
    'src/xsys/sv/**/class.lua',
    'src/xsys/sv/**/*.lua',
	'src/xsys/sv/*.lua'
}

-- // load Sync System \\
shared_script 'src/xsys/sync.lua'

-- // load Client System \\
client_scripts {
    -- 'src/xsys/cl/**/__meta.lua',
    -- 'src/xsys/cl/**/class.lua',
    -- 'src/xsys/cl/**/*.lua',
	'src/xsys/cl/*.lua'
}

dependency 'oxmysql'