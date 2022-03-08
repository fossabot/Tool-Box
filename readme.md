[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2F5m1Ly%2FTool-Box.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2F5m1Ly%2FTool-Box?ref=badge_shield)

# The X System 🧠
I created The X System project because i was irritated by the fact that it doesn't matter if you use the qbcore-framework or esx framework, at the end of the day it doesn't link nor seperates client and character data that well. With that being said i went out of my way to solve this problem, this was important for me and probably for you because this is an absolute core mechanic for any server whether it is focused on roleplay, combat, racing or just playing for fun almost everyone has this mechanic or a similar one within their server 😉.

## Documentation Contents
1. **Intro**
1. **Use Case Example**
1. **Visual System Layout**
1. **Sources**
<!-- 1. **Installation |** [go to ->](https://github.com/5m1Ly/Tool-Box/blob/master/docs/installation.md) -->

### Use Case Example 
> ##### *For those who want some extra context..*
> <small>Lets say you are running a qbcore server, then it has an itegrated language system for your server this is nice for those who want to use a single language on their server. If you for example want to have a multi national server, then this system needs some tweeks so the language system is able to let the user set their preferred language. Once you recived this information you dont want to save this for every single character the user owns. So you create a new table in the data base to save this info the only problem then is that this data isn't linked to your characters. In some cases you migth want to use it for the character you are playing with for instance when you assign a new job. This system is exactly what you could use to solve this problem. It links and seperatly saves the data so you dont have to store the same data multible times.</small>

### Visual System Layout
[The X System, Data Structure & Proces Schemas ->](https://my.visme.co/view/epyeem3x-the-x-system-2)

### Sources
1. [connectqueue](https://github.com/Nick78111/ConnectQueue)<br>
  The player queue is handeled by a modified version of the [connectqueue](https://github.com/Nick78111/ConnectQueue) resource.

## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2F5m1Ly%2FTool-Box.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2F5m1Ly%2FTool-Box?ref=badge_large)