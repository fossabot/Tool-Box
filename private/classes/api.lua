local config = CONFIG:INIT()

Monitor = {}

function Monitor:API()
    local api = {
        config = CONFIG,
        debug = _DEBUG,
        sql = _SQL,
        types = DT,
        pool = _POOL,
        session = _SESSION,
    }
    setmetatable(api, self)
	self.__index = self
	return api
end

function Monitor:init(_class)
    if self[_class] ~= nil then
        return self[_class]:INIT()
    end
end

exports("API", function()
    print(GetInvokingResource())
    return Monitor:API()
end)