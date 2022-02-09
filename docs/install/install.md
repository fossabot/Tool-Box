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

### [configure ->](https://github.com/5m1Ly/BabyMonitor/blob/master/docs/install/configure.md)

<hr>

### [<- go back](https://github.com/5m1Ly/BabyMonitor)