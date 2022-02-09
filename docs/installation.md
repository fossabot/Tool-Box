# Resource Installation

1. **Requirements**<br>
    - A home or server hosted FiveM server | [how to ->](https://docs.fivem.net/docs/server-manual/setting-up-a-server/)
    - version 1.9.3 of oxmysql | [download ->](https://github.com/overextended/oxmysql)

2. **Download**<br>
    - Download the latest version of The X System, i strongly advice you to create a local git repo and clone it so you can easily update to the latest features.<br>
    - [new with git?](https://www.youtube.com/watch?v=8JJ101D3knE)

3. **Setup Connectqueue**<br>
    - !!!__backup your current connectqueue resource__!!!
    - replace it with the one from your version package

4. **qb-core**<br>
    - !!!__backup your current `events.lua` file__!!! within `qb-core/server/`
    - replace it with the one from your version package

5. **database setup (i'm not responsible for any lost data)**<br>
    - !!!__backup your database__!!! best practice is to save one with the data and one with clean tables
    - if you use qbus skip this step otherwise insert the tables from bm-tables.sql within your database
    - __for qbcore-framework users__
        - after you made a backup of your current database alter it and delete the tables within
        - then execute the qb-database.sql file within you database
        - when you got your new tables setup you can then insert your old data and should be good to go

<br>
<hr>
<br>

# Resource Configuration
Within your version package you can find a `private.lua` config file. This file contains all the configuration data that is only used by the server. By default it comes in dutch so i added a english version of the config within this file.

## Permissions
Perm levels are created with tables like shown below. for power grade comparison we use the index of the table by default and check if it is higher then or equal to the table index required. that is why positioning of the grade tables are importent, because it stands for the power it represents.
```lua
PERMISSIONS = {
    { -- parent table index of 1
        LABEL = 'Citizen', -- the label we display to the user
        SHORT_NAME = 'USER' -- the string used when power grade comparison is done with strings
    },
    { -- parent table index of 2
        LABEL = 'Administrator',
        SHORT_NAME = 'ADMIN'
    }, 
},
```

### Adding perms
When adding perms its important to keep in mind that the last within the list is the one with the higher power. whitin the example below the admin has a lower power grade then the citizen for a big chunk of the code it doesn't matter but for some functions it will give the citizen more power then an admin.
```lua
-- !!! DONT USE THIS EXAMPLE !!! ---
PERMISSIONS = {
    { LABEL = 'Administrator', 	SHORT_NAME = 'ADMIN' }, -- power grade 1
    { LABEL = 'Citizen',        SHORT_NAME = 'USER' }, -- power grade 2
},
-- !!! DONT USE THIS EXAMPLE !!! ---
```

This is the correct way of setting the permissions
```lua
PERMISSIONS = {
    { LABEL = 'Citizen',        SHORT_NAME = 'USER' }, -- power grade 1
    { LABEL = 'Administrator', 	SHORT_NAME = 'ADMIN' }, -- power grade 2
},
```

## Queue lists
For adding queue lists its basicly the same as mentioned above.

<hr>

### [<-- Go Back](https://github.com/5m1Ly/BabyMonitor)