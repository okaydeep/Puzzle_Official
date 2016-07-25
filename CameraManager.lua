
-- ===================================
-- 鏡頭管理
-- 範例:
-- CM = CameraManager:New(CM)
-- ===================================

CameraManager = { }
_ = CameraManager

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.layer = { }

-- 讀取音源, soundName:名稱
function _:LoadSound(soundName)
	if self.sound[soundName] == nil then
		self.sound[soundName] = audio.loadSound( "snd/" .. soundName .. ".wav" )
	else
		print("Specific sound has loaded")
	end
end

function _:GetLayer(layerName)
	if self.layer[layerName] == nil then
		print("Layer not found")
	end
	
	return self.layer[layerName]	
end

function _:AddToLayer(obj, layerName)
	if self.layer[layerName] == nil then
		self.layer[layerName] = display.newGroup()
	end

	self.layer[layerName]:insert(obj)
end