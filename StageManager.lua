
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
function _:AddGemToStage( i, j, gem )
	self.stage[i][j] = gem
end

function _:GetColor( i, j )
	local color = "none"

	if self.isValidStagePos(i, j) == true then
		if self.stage[i][j] ~= nil then
			color = self.stage[i][j].color
		end
	end

	return color
end

-- 檢查是否碰撞, posX:x座標, posY:y座標, stageI:橫排, stageJ:縱列
function _:CheckTouch( posX, posY, stageI, stageJ )
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

-- 檢查是否連線, stageI:橫排, stageJ:縱列
function _:CheckConnected( stageI, stageJ )	
	local idx
	local connectedAmount	
	
	-- 檢查右方連線
	idx = 1
	connectedAmount = 1
	while stageJ+idx<=6 do
		if self.stage[stageI][stageJ].color == self.stage[stageI][stageJ+idx].color then
			connectedAmount = connectedAmount+1
			idx = idx+1
		else			
			break
		end
	end
	
	if connectedAmount >= 3 then		
		return true
	end

	-- 檢查左方連線
	idx = -1
	connectedAmount = 1
	while stageJ+idx>=1 do
		if self.stage[stageI][stageJ].color == self.stage[stageI][stageJ+idx].color then
			connectedAmount = connectedAmount+1
			idx = idx-1
		else
			break
		end
	end
	
	if connectedAmount >= 3 then		
		return true
	end

	-- 檢查下方連線
	idx = 1
	connectedAmount = 1
	while stageI+idx<=5 do
		if self.stage[stageI][stageJ].color == self.stage[stageI+idx][stageJ].color then
			connectedAmount = connectedAmount+1
			idx = idx+1
		else
			break
		end
	end
	
	if connectedAmount >= 3 then		
		return true
	end

	-- 檢查上方連線
	idx = -1
	connectedAmount = 1
	while stageI+idx>=1 do
		if self.stage[stageI][stageJ].color == self.stage[stageI+idx][stageJ].color then
			connectedAmount = connectedAmount+1
			idx = idx-1
		else
			break
		end
	end
	
	if connectedAmount >= 3 then		
		return true
	end	

	return false
end

-- 碰撞物件互換, aI:a的橫排, aJ:a的縱列, bI:b的橫排, bJ:b的縱列
function _:GemSwap( aI, aJ, bI, bJ )		
	if self.isValidStagePos(aI, aJ) == true and self.isValidStagePos(bI, bJ) == true then
		local imgB = self.stage[bI][bJ].img
		imgB.x, imgB.y = self.stageToWorldPos(aI, aJ)
		
		local tmpA = GM.deepCopy(self.stage[aI][aJ])
		local tmpB = GM.deepCopy(self.stage[bI][bJ])
		self.stage[aI][aJ] = nil
		self.stage[aI][aJ] = tmpB
		self.stage[bI][bJ] = nil
		self.stage[bI][bJ] = tmpA

		local gemA = self.stage[aI][aJ]
		gemA.stagePos.y, gemA.stagePos.x = aI, aJ
		local gemB = self.stage[bI][bJ]
		gemB.stagePos.y, gemB.stagePos.x = bI, bJ
	end
end

-- 產生盤面, colorIdxArr:盤面會出現的顏色引數陣列, connectionAllowed:允許預設連線
function _:GenerateGems( displayGroup, colorIdxArr, connectionAllowed, touchEvt )
	local posTable = { }
	local idx = 1

	for i=1, 5 do
        for j=1, 6 do
           posTable[idx] = {j, i}
           idx = idx+1
        end
    end

    for i=1, #posTable do
		local gem = Gem:New(gem)
    	local rand = math.random(1, #colorIdxArr)
	    gem.stagePos = {x=posTable[i][1], y=posTable[i][2]}
	    gem.color = GM.Color[colorIdxArr[rand]]
	    local posX, posY = self.stageToWorldPos(gem.stagePos.y, gem.stagePos.x)
	    gem.img = display.newImage( displayGroup, GM.SpritePath..GM.GemName[rand], posX, posY )

	    if touchEvt ~= nil then
	    	gem.img:addEventListener("touch", touchEvt)
	    end

	    self:AddGemToStage(posTable[i][2], posTable[i][1], gem)

	    -- test
	    local circle = display.newCircle( posX, posY, GM.touchRadius*0.5 )
    end

    -- 確認盤面是否有連結
    local function checkAllGems()
    	for i=1, #posTable do
    		local idx = 1
    		local pos = posTable[i]
    		local tmpIdxArr = { }

    		if self:CheckConnected(pos[2], pos[1]) == true then
    			local colorIdx = 1

    			-- 找出不相同的顏色引數並記錄
	    		for j=1, #colorIdxArr do
	    			if self.stage[pos[2]][pos[1]].color ~= GM.Color[colorIdxArr[j]] then
	    				tmpIdxArr[colorIdx] = colorIdxArr[j]
	    				colorIdx = colorIdx+1
	    			end
	    		end	    		

	    		-- 使用洗牌法打亂顏色引數
	    		for j=#tmpIdxArr, 1, -1 do	    			
	    			local rand = math.random(1, j)
	    			local tmpIdx = tmpIdxArr[rand]
	    			tmpIdxArr[rand] = tmpIdxArr[j]
	    			tmpIdxArr[j] = tmpIdx
	    		end

	    		-- 將剛剛的顏色引數帶入並確認未連結
	    		while self:CheckConnected(pos[2], pos[1]) == true do
	    			if idx > #tmpIdxArr then
	    				break
	    			end

	    			self.stage[pos[2]][pos[1]].color = GM.Color[tmpIdxArr[idx]]

	    			if self:CheckConnected(pos[2], pos[1]) == false then
		    			self.stage[pos[2]][pos[1]].img:removeSelf()
		    			self.stage[pos[2]][pos[1]].img = display.newImage( displayGroup, GM.SpritePath..GM.GemName[tmpIdxArr[idx]], posX, posY )
		    			break
		    		end

	    			idx = idx+1
	    		end
	    	end
    	end
    end

    if connectionAllowed == false then
    	--for k=1, #posTable do
    		checkAllGems()
    	--end
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