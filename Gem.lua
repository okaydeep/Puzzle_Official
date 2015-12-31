-- Class sample
Gem = { }

_ = Gem

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.stagePos = nil
_.color = nil
_.checkHConnected = nil
_.checkVConnected = nil
_.img = nil
