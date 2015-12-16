
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

	if self.isValidStagePos(i, j) == true then
		if self.stage[i][j] ~= nil then		
			color = self.stage[i][j].color		
		end
	end

	return color
end

-- 判斷是否碰撞, posX:x座標, posY:y座標, i:橫排, j:縱列
function _:CheckTouch(posX, posY, stageI, stageJ)
	local result = false

	if self.isValidStagePos(stageI, stageJ) == true then
		local dX = GV.gemStartX+stageJ*GV.gemWidth-posX
		local dY = GV.gemStartY+stageI*GV.gemWidth-posY

		if self.distance(dX, dY) <= GV.touchRadius then
			result = true
		end
	end

	return result	
end

-- 碰撞物件互換, aI:a的橫排, aJ:a的縱列, bI:b的橫排, bJ:b的縱列
function _:GemSwap(aI, aJ, bI, bJ)
	if self.isValidStagePos(aI, aJ) == true and self.isValidStagePos(bI, bJ) == true then
		local a = self.stage[aI][aJ]
		local b = self.stage[bI][bJ]
		local tmpData = a

		b.img.x, b.img.y = self.stageToWorldPos(a.stagePos.y, a.stagePos.x)
		
		-- a.stagePos = b.stagePos
		-- a.color = b.color
		-- a.img = b.img

		-- b.stagePos = tmpData.stagePos
		-- b.color = tmpData.color
		-- b.img = tmpData.img		
	end
end

-- 相對位置轉成實際位置, i:橫排, j:縱列
function _.stageToWorldPos( i, j )
	local posX, posY

	posX = GV.gemStartX+j*GV.gemWidth
	posY = GV.gemStartY+i*GV.gemHeight

	return posX, posY
end

-- 計算距離(兩點位差), dX:水平差, dY:垂直差
function _.distance( dX, dY )
    return math.sqrt( ( dX^2 ) + ( dY^2 ) )
end

-- 判斷相對位置是否合法, i:橫排, j:縱列
function _.isValidStagePos( i, j )
	local result = true

	if i<1 or i>5 or j<1 or j>6 then
		result = false
	end

	return result	
end