# Resource Installation

1. **Requirements**<br>
- A home or server hosted FiveM server | [how to ->](https://docs.fivem.net/docs/server-manual/setting-up-a-server/)
- version 1.9.3 of oxmysql | [download ->](https://github.com/overextended/oxmysql)

1. **Download**<br>
Download the latest version of BabyMonitor, i strongly advice you to create a local git repo and clone it so you can easily update to the latest features.
[git beginner tutorial](https://www.youtube.com/watch?v=8JJ101D3knE)

1. **Setup Connectqueue**<br>
ConnectQueue will be implemented in the future, but for now you need to make a few changes yourself to `path/resource/[standalone]/connectqueue/shared/sh_queue.lua`.

- *Go to line 444, and change the following*
```lua
--[[ old ]] local function playerConnect(name, setKickReason, deferrals)
--[[ new ]] local function playerConnect(src, name, setKickReason, deferrals) -- playerSrc is added so it knows which player to add
```

- *Go to line 445, and remove the following*
```lua
local src = source -- not needed anymore sinds we are passing it as a parameter to the function
```

- *Go to line 653 (for qbcore-framework line 660), and change the following*
```lua
--[[ old ]] AddEventHandler("playerConnecting", playerConnect)
--[[ new ]] exports('SEND_TO_QUEUE', playerConnect) -- this export will be triggerd from the BabyMonitor resource
```

1. **qb-core**<br>
For the qbcore-framework users goto to the following file `path/resource/[qb]/qb-core/server/events.lua`.<br>
Go to line 43, now remove or comment everything out from line 43 to line 87<br>
*NOTE: don't disable any other connection code sinds its needed for handling the player data.*

<hr>

### [<-- Go Back](https://github.com/5m1Ly/BabyMonitor)