# 👶 Baby Monitor 👶
I created the baby monitor project because i was irritated by the fact that it doesn't matter if you use the qbcore-framework or esx framework, at the end of the day it doesn't link nor seperates client and character data that well. With that being said i went out of my way to solve this problem, this was important for me and probably for you because this is an absolute core mechanic for any server whether it is focused on roleplay, combat, racing or just playing for fun almost everyone has this mechanic within the server. If you don't have this mechanic within your server it probably would be a good thing to use anyway just look at the way identifiers are saved 😉.

## Document Contents
- **Requirements**
- **Installation**
- **Configuration**
- **Monitor**
- **Classes**
  - *datatypes*
  - *debug*
  - *message*
  - *pool*
  - *session*
  - *sql*
- **Sources**

## Requirements
- A home or server hosted FiveM server | [how to ->](https://docs.fivem.net/docs/server-manual/setting-up-a-server/)
- version 1.9.3 of oxmysql | [download ->](https://github.com/overextended/oxmysql)

## Installation
1. **Requirements**<br>
Make sure that you downloaded and installed the requirements mentioned above.

1. **Download**<br>
Download the latest version of BabyMonitor, i strongly advice you to create a local git repo and clone it so you can easily update to the latest features.
[git beginner tutorial](https://www.youtube.com/watch?v=8JJ101D3knE)

1. **Connectqueue**<br>
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

## Configuration
## Monitor
## Classes
### datatypes
### debug
### message
### pool
### session
### sql

## Sources
One function wihtin the debugger class is a modified function from the [pma-voice](https://github.com/AvarianKnight/pma-voice) resource.
Two functions within the datatypes class are modified functions from the [Qbus](https://github.com/qbcore-framework) framework.
The player queue is handeled by a modified version of the [connectqueue](https://github.com/Nick78111/ConnectQueue) resource.