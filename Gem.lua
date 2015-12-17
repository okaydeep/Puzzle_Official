-- Class sample
Gem = { }

_ = Gem

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

function _:copyGem( gem )
	local copy = setmetatable({}, getmetatable(gem))

    for k, v in pairs(gem or {}) do
        if type(v) ~= "table" then
            copy[k] = v
        else
            copy[k] = self.copyGem(v)
        end
    end

    return copy
end

function _:removeGem( gem )
	for k, v in pairs(gem or {}) do
        if type(v) ~= "table" then
            gem[k] = nil
        else
            self.removeGem(v)
        end
    end
end

_.stagePos = nil
_.color = nil
_.img = nil
