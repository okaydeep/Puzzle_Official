-- Class sample
GlobalManager = { }
_ = GlobalManager

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.SpritePath = "img/sprite/"

_.GemName = { "gem_red.png", "gem_orange.png", "gem_green.png", "gem_blue.png", "gem_purple.png", "gem_pink.png" }

_.Color = { "red", "orange", "green", "blue", "purple", "pink" }

_.touchRadius = 40

_.gemWidth = 100
_.gemHeight = 110

_.gemStartX = 10
_.gemStartY = 100