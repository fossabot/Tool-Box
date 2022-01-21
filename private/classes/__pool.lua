-- A class mimic to handel session data within a pool
_POOL = {}

function _POOL:CREATE()
	local _TABLE = {
		POOL = {}
	}
	setmetatable(_TABLE, self)
	self.__index = self
	return _TABLE
end

function _POOL:GET_POOL()
	return self.POOL
end

function _POOL:ADD_SESSION(_SOURCE, _SESSION)
	if self.POOL[_SOURCE] == nil then
		self.POOL[_SOURCE] = _SESSION
	end
end

function _POOL:GET_SESSION(_SOURCE)
	if self.POOL[_SOURCE] ~= nil then
		return self.POOL[_SOURCE]
	end
end

function _POOL:SET_SESSION(_SOURCE, _UPDATED_SESSION)
	if self.POOL[_SOURCE] == nil then
		self.POOL[_SOURCE] = _UPDATED_SESSION
	end
end

function _POOL:REMOVE_SESSION(_SOURCE)
	self.POOL[_SOURCE] = nil
end