function NewUserdata(tempId, name)
    return setmetatable({
        name = name,
        id = {
            server = 0,
            temp = tempId,
        },
        identifiers = identifiers(tempId),
    }, {
        __tostring = ToStringDebugger
    })
end