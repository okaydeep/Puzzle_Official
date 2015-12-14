
require( "GlobalManager" )
local GV = GlobalManager

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

-- 新增gem到盤面群組裡, i:橫排, j:縱列, gem:新生成的gem table
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

-- 判斷是否碰撞, posX:x座標, posY:y座標, i:橫排, j:縱列
function _:CheckTouch(posX, posY, stageI, stageJ)
	local result = false
	local dX = GV.gemStartX+stageJ*GV.gemWidth-posX
	local dY = GV.gemStartY+stageI*GV.gemWidth-posY

	if self.distance(dX, dY) <= GV.touchRadius then
		result = true
	end

	return result	
end

-- 計算距離(兩點位差)
function _.distance( dX, dY )
    return math.sqrt( ( dX^2 ) + ( dY^2 ) )
end