
-- ===================================
-- 音源管理
-- 範例:
-- SM = SoundManager:New(SM)
-- SM:LoadSound("test01")
-- SM:PlaySound("test01")
-- ===================================

SoundManager = { }
_ = SoundManager

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.moveSndPath		= ""
_.clickBtnSndPath	= ""

_.sound = { }

-- 讀取音源, soundName:名稱
function _:LoadSound(soundName)
	if self.sound[soundName] == nil then
		self.sound[soundName] = audio.loadSound( "../snd/" .. soundName .. ".wav" )
	else
		print("Specific sound has loaded")
	end
end

-- 播放音源, soundName:名稱
function _:PlaySound(soundName)
	if self.sound[soundName] ~= nil then
		audio.play(self.sound[soundName])
	else
		print("No specific sound to play")
	end
end