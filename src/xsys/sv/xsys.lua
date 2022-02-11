xSystem = {}
xSystem.__index = xSystem

function xSystem.connect(name, kick, deferrals)

    local tempId = source
    local user = NewUserdata(tempId)

    print(user)

end

xSystem = setmetatable({}, xSystem)

AddEventHandler('playerConnecting', xSystem.connect)
AddEventHandler('playerJoining', xSystem.join)
AddEventHandler('playerDropped', xSystem.drop)