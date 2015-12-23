
require( "GlobalManager" )
local GM = GlobalManager

require( "Gem" )

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
		local dX = GM.gemStartX+stageJ*GM.gemWidth-posX
		local dY = GM.gemStartY+stageI*GM.gemHeight-posY

		if self.distance(dX, dY) <= GM.touchRadius then
			result = true
		end
	end

	return result	
end

-- 碰撞物件互換, aI:a的橫排, aJ:a的縱列, bI:b的橫排, bJ:b的縱列
function _:GemSwap(aI, aJ, bI, bJ)
	if self.isValidStagePos(aI, aJ) == true and self.isValidStagePos(bI, bJ) == true then		
		self.stage[bI][bJ].img.x, self.stage[bI][bJ].img.y = self.stageToWorldPos(self.stage[aI][aJ].stagePos.y, self.stage[aI][aJ].stagePos.x)		
		
		self.stage[aI][aJ].color = self.stage[bI][bJ].color
		self.stage[bI][bJ].color = self.stage[aI][aJ].color
		
		local imgA = GM.deepCopy(self.stage[aI][aJ].img)
		self.stage[aI][aJ].img = nil
		self.stage[aI][aJ].img = self.stage[bI][bJ].img
		self.stage[bI][bJ].img = imgA		
	end
end

-- 相對位置轉成實際位置, i:橫排, j:縱列
function _.stageToWorldPos( i, j )
	local posX, posY

	posX = GM.gemStartX+j*GM.gemWidth
	posY = GM.gemStartY+i*GM.gemHeight

	return posX, posY
end

-- 實際位置轉成相對位置, x:x位置, y:y位置
function _.worldToStagePos( x, y )
	local posI, posJ

	posI = math.round((y-GM.gemStartY)/GM.gemHeight)
	posJ = math.round((x-GM.gemStartX)/GM.gemWidth)

	return posI, posJ
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