
-- ===================================
-- 音源管理
-- 範例:
-- SM = SoundManager:New(SM)
-- SM:LoadSound("test01")
-- SM:PlaySound("test01")
-- ===================================

SoundManager = { }
_ = SoundManager

-- 音效根目錄 (./snd/)
local soundPath = system.pathForFile(nil, system.ResourceDirectory) .. "\\snd\\"

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.sound = { }

-- 讀取音源, soundName:名稱
function _:LoadSound(soundName)
	if self.sound[soundName] == nil then
		self.sound[soundName] = audio.loadSound( "snd/" .. soundName .. ".wav" )
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

-- 改變當前路徑
lfs.chdir(soundPath)

-- 讀取所有wav檔
for file in lfs.dir(soundPath) do
    local last_three = string.sub( file, #file - 2, #file)
    if last_three == "wav" then
    	_:LoadSound(string.sub( file, 1, -5))
    	-- print(string.sub( file, 1, -5))
    end
end

print("test!!!")