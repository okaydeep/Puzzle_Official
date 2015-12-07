-- Class sample
StageManager = { }

_ = StageManager

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.stage = { { },
			{ },
			{ },
			{ },
			{ } }

function _:AddGemToStage(i, j, gem)
	self.stage[i][j] = gem
end

function _:GetColor(i, j)
	local color = "none"

	if self.stage[i][j] ~= nil then
		color = self.stage[i][j].color
	end

	return color
end

