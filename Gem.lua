-- Class sample
Gem = { }

_ = Gem

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.pos = { x=0, y=0 }
_.img = nil
_.color = ""