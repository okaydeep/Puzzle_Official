
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

_.stage = {
	{ },
	{ },
	{ },
	{ },
	{ }
}

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
	
	-- 水平連線檢查
	-- 檢查右方連線
	idx = 1
	connectedAmount = 1
	while stageJ+idx<=6 do
		if self:GetColor(stageI, stageJ) == self:GetColor(stageI, stageJ+idx) and self:GetColor(stageI, stageJ) ~= "none" then
			connectedAmount = connectedAmount+1
			idx = idx+1
		else			
			break
		end

		if connectedAmount >= 3 then
			break
		end
	end
	
	if connectedAmount >= 3 then
		return true
	end

	-- 檢查左方連線
	idx = -1	
	while stageJ+idx>=1 do
		if self:GetColor(stageI, stageJ) == self:GetColor(stageI, stageJ+idx) and self:GetColor(stageI, stageJ) ~= "none" then
			connectedAmount = connectedAmount+1
			idx = idx-1
		else
			break
		end

		if connectedAmount >= 3 then
			break
		end
	end
	
	if connectedAmount >= 3 then		
		return true
	end

	-- 垂直連線檢查
	-- 檢查下方連線
	idx = 1
	connectedAmount = 1
	while stageI+idx<=5 do
		if self:GetColor(stageI, stageJ) == self:GetColor(stageI+idx, stageJ) and self:GetColor(stageI, stageJ) ~= "none" then
			connectedAmount = connectedAmount+1
			idx = idx+1
		else
			break
		end

		if connectedAmount >= 3 then
			break
		end
	end
	
	if connectedAmount >= 3 then		
		return true
	end

	-- 檢查上方連線
	idx = -1	
	while stageI+idx>=1 do
		if self:GetColor(stageI, stageJ) == self:GetColor(stageI+idx, stageJ) and self:GetColor(stageI, stageJ) ~= "none" then
			connectedAmount = connectedAmount+1
			idx = idx-1
		else
			break
		end

		if connectedAmount >= 3 then
			break
		end
	end
	
	if connectedAmount >= 3 then		
		return true
	end	

	return false
end

-- 取得(若有)連線gem的座標(若無則返回空table), stageI:橫排, stageJ:縱列
function _:GetConnectedGemPos( stageI, stageJ )
	local gemPos = { }

	if self:CheckConnected(stageI, stageJ) == false then
		return gemPos
	end

	-- 取得從單個gem起始的連線座標
	local function getDirConnectedGemPos(stageI, stageJ, dir)
		local connPos = { }
		local hDirLimit
		local vDirLimit
		local posXOffset
		local posYOffset
		local posXDelta
		local posYDelta		

		if dir == "horizon" then
			hDirLimit = 6
			posXOffset = 1
			posXDelta = 1

			while stageJ+posXDelta <= hDirLimit do
				if self.stage[stageI][stageJ+posXDelta].checkHConnected == true then break end

				if self:GetColor(stageI, stageJ) == self:GetColor(stageI, stageJ+posXDelta) and self:GetColor(stageI, stageJ) ~= "none" then
					connPos[#connPos+1] = {stageJ+posXDelta, stageI}
				else
					break
				end

				posXDelta = posXDelta+posXOffset				
			end

			hDirLimit = 1
			posXOffset = -1
			posXDelta = -1

			while stageJ+posXDelta >= hDirLimit do
				if self.stage[stageI][stageJ+posXDelta].checkHConnected == true then break end

				if self:GetColor(stageI, stageJ) == self:GetColor(stageI, stageJ+posXDelta) and self:GetColor(stageI, stageJ) ~= "none" then
					connPos[#connPos+1] = {stageJ+posXDelta, stageI}
				else
					break
				end

				posXDelta = posXDelta+posXOffset				
			end

		elseif dir == "vertical" then		
			vDirLimit = 5
			posYOffset = 1
			posYDelta = 1

			while stageI+posYDelta <= vDirLimit do
				if self.stage[stageI+posYDelta][stageJ].checkVConnected == true then break end

				if self:GetColor(stageI, stageJ) == self:GetColor(stageI+posYDelta, stageJ) and self:GetColor(stageI, stageJ) ~= "none" then
					connPos[#connPos+1] = {stageJ, stageI+posYDelta}
				else
					break
				end
				
				posYDelta = posYDelta+posYOffset
			end

			vDirLimit = 1
			posYOffset = -1
			posYDelta = -1

			while stageI+posYDelta >= vDirLimit do
				if self.stage[stageI+posYDelta][stageJ].checkVConnected == true then break end

				if self:GetColor(stageI, stageJ) == self:GetColor(stageI+posYDelta, stageJ) and self:GetColor(stageI, stageJ) ~= "none" then
					connPos[#connPos+1] = {stageJ, stageI+posYDelta}
				else
					break
				end
				
				posYDelta = posYDelta+posYOffset
			end

		end		

		-- check過的更新
		for i=1, #connPos do
			if dir == "horizon" then
				self.stage[connPos[i][2]][connPos[i][1]].checkHConnected = true
			elseif dir == "vertical" then
				self.stage[connPos[i][2]][connPos[i][1]].checkVConnected = true
			end
		end		

		if #connPos >= 2 then			
			return connPos
		else
			return { }
		end
	end

	gemPos[1] = {stageJ, stageI}

	local idx = 1

	while idx <= #gemPos do		
		local hGems, vGems = { }, { }			

		if self.stage[gemPos[idx][2]][gemPos[idx][1]].checkHConnected == false then
			self.stage[gemPos[idx][2]][gemPos[idx][1]].checkHConnected = true
			hGems = getDirConnectedGemPos(gemPos[idx][2], gemPos[idx][1], "horizon")						
		end

		if self.stage[gemPos[idx][2]][gemPos[idx][1]].checkVConnected == false then
			self.stage[gemPos[idx][2]][gemPos[idx][1]].checkVConnected = true
			vGems = getDirConnectedGemPos(gemPos[idx][2], gemPos[idx][1], "vertical")			
		end

		if #hGems > 0 then
			for i=1, #hGems do
				gemPos[#gemPos+1] = hGems[i]
			end
		end

		if #vGems > 0 then
			for i=1, #vGems do
				gemPos[#gemPos+1] = vGems[i]
			end
		end

		idx = idx+1
	end

	return gemPos
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

		-- Not working
		-- local gemA = table.remove( self.stage[aI], aJ )
		-- local gemB = table.remove( self.stage[bI], bJ )
		-- table.insert( self.stage[bI], bJ, gemA )
		-- table.insert( self.stage[aI], aJ, gemB )

		local gemA = self.stage[aI][aJ]
		gemA.stagePos.y, gemA.stagePos.x = aI, aJ
		local gemB = self.stage[bI][bJ]
		gemB.stagePos.y, gemB.stagePos.x = bI, bJ
	end
end

function _.GeneratePosTable()
	local posTable = { }

	local idx = 1

	for i=1, 5 do
        for j=1, 6 do
           posTable[idx] = {j, i}
           idx = idx+1
        end
    end

    return posTable
end

function _:InitGem()
	local posTable = self.GeneratePosTable()

    for i=1, #posTable do
		local gem = Gem:New(gem)    	
	    gem.stagePos = {x=posTable[i][1], y=posTable[i][2]}
	    gem.color = "none"
	    gem.checkHConnected = false
	    gem.checkVConnected = false	    

	    self:AddGemToStage(gem.stagePos.y, gem.stagePos.x, gem)	    
    end
end

-- 產生盤面,
-- displayGroup:Image的group,
-- colorIdxArr:盤面會出現的顏色引數陣列,
-- parsedColor:分析圖片得到的顏色table
-- connectionAllowed:允許預設連線,
-- touchEvt:規定的觸碰事件,
function _:GenerateGem( displayGroup, colorIdxTable, parsedColor, connectionAllowed, touchEvt )	
	-- 迴圈跳出標準
	local connected
	local colorIdxArr
	local gemInitPosYOffset = { }
	local posTable = self.GeneratePosTable()

	if parsedColor == nil then		
		colorIdxArr = colorIdxTable
	else
		colorIdxArr = {1, 2, 3, 4, 5, 6}
	end

	for j=1, 6 do		
		for i=1, 5 do
			self.stage[i][j].color = "none"
			if self.stage[i][j].img then
				self.stage[i][j].img:removeSelf()
			end
		end		
	end

	for j=1, 6 do
		local offset = 0

		for i=1, 5 do
			if self.stage[i][j].color == "none" then
				offset = offset+1
			end
		end

		gemInitPosYOffset[j] = offset
	end

    for i=1, 5 do
    	for j=1, 6 do
    		local gem = self.stage[i][j]

    		-- 如果gem種類為none
    		if gem.color == "none" then
    			local rand = -1

    			-- 沒有參考資料, 隨機產生
    			if parsedColor == nil then
		    		rand = math.random(1, #colorIdxArr)
		    	-- 如果有傳入分析圖片的顏色table
		    	else
		    		rand = parsedColor[i][j]		    		
		    	end

			    gem.color = GM.Color[colorIdxArr[rand]]
			    --local posX, posY = self.stageToWorldPos(gem.stagePos.y, gem.stagePos.x)
		    	gem.img = display.newImage( displayGroup, GM.SpritePath..GM.GemName[colorIdxArr[rand]], 0, -1000 )
			end

		    gem.checkHConnected = false
		    gem.checkVConnected = false		    

		    if touchEvt ~= nil then
		    	gem.img:addEventListener("touch", touchEvt)
		    end		    

		    -- test
		   	-- local circle = display.newCircle( posX, posY, GM.touchRadius*0.5 )
	  	end
    end

    -- 確認盤面是否有連結
    local function checkAllGem()    	
    	connected = false

    	for i=1, #posTable do
    		local idx = 1
    		local pos = posTable[i]
    		local tmpIdxArr = { }

    		if self:CheckConnected(pos[2], pos[1]) == true then
    			local colorIdx = 1

    			-- 找出不相同的顏色引數並記錄
	    		for j=1, #colorIdxArr do
	    			--if self.stage[pos[2]][pos[1]].color ~= GM.Color[colorIdxArr[j]] then
	    				tmpIdxArr[colorIdx] = colorIdxArr[j]
	    				colorIdx = colorIdx+1
	    			--end
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
	    				connected = true
	    				break
	    			end

	    			self.stage[pos[2]][pos[1]].color = GM.Color[tmpIdxArr[idx]]    				
	    			self.stage[pos[2]][pos[1]].img:removeSelf()
	    			self.stage[pos[2]][pos[1]].img = display.newImage( displayGroup, GM.SpritePath..GM.GemName[tmpIdxArr[idx]], 0, -1000 )
	    				    			
	    			if touchEvt ~= nil then
				    	self.stage[pos[2]][pos[1]].img:addEventListener("touch", touchEvt)
				    end

	    			if self:CheckConnected(pos[2], pos[1]) == false then	    				
		    			break
		    		end

	    			idx = idx+1
	    		end
	    	end
    	end
    end

    -- 不允許預設連線
    if connectionAllowed == false then
    	local checkTimes = 0

    	repeat
    		checkAllGem()
    		checkTimes = checkTimes+1

    		-- 最多會check幾次
    		if checkTimes >= 5 then
    			break
    		end
    	until(connected == false)
    end

    -- 掉落動畫
    for j=1, 6 do
    	for i=1, 5 do
    		local gem = self.stage[i][j]    		
    		local posX, posY = self.stageToWorldPos(gem.stagePos.y, gem.stagePos.x)
    		local initPosY = 200-(gemInitPosYOffset[j]-i+1)*GM.gemHeight
    		
    		gem.img.x, gem.img.y = posX, initPosY
    		gem.img.alpha = 0.3

    		local transParams = {time=GM.dropDuration, y=posY, alpha=1, transition=easing.inQuad}
    		transition.to( gem.img, transParams )
    	end
    end    
end

-- 消除盤面中有連線的gem
function _:EliminateGem()
	-- 將直橫檢查還原
	for i=1, 5 do
		for j=1, 6 do
			self.stage[i][j].checkHConnected = false
			self.stage[i][j].checkVConnected = false
		end
	end

	-- 更新掉落後的珠子
	local function updateGem()
		for j=1, 6 do
			for i=5, 1, -1 do
				if self:GetColor(i, j) == "none" then
					local yIdx = -1

					while i+yIdx >= 1 do
						if self:GetColor(i+yIdx, j) ~= "none" then
							self:GemSwap(i, j, i+yIdx, j)
							-- self.stage[i][j].color = self:GetColor(i+yIdx, j)
							-- self.stage[i][j].img = self.stage[i+yIdx][j].img
							-- self.stage[i+yIdx][j].color = "none"
							-- self.stage[i+yIdx][j].img:removeSelf()
							break
						else
							yIdx = yIdx-1
						end
					end
				end
			end
		end

		self:EliminateGem()
	end

	-- 消除後的掉落
	local function gemDrop(event)
		-- 計算掉落距離		
		local dropIdxArr = { }		

		for j=1, 6 do
			local dropIdx = 0

			for i=5, 1, -1 do
				if self.stage[i][j].color == "none" then
					dropIdx = dropIdx+1
				else
					if dropIdx > 0 then
						local target = self.stage[i][j].img
						transition.to( target, {time=GM.dropDuration, y=target.y+(GM.gemHeight*dropIdx), transition=easing.inQuad, 
							onComplete=updateGem} )
					end
				end
			end

			dropIdxArr[j] = dropIdx
		end
	end

	-- 將組合消除
	local function clearGem(event)
		local params = event.source.params
        local pos = params.gemPos        

        for i=1, #pos do
        	self.stage[pos[i][2]][pos[i][1]].color = "none"
        	local target = self.stage[pos[i][2]][pos[i][1]].img
        	transition.to( target, {time=GM.clearDelay, alpha=0} )
        end		
	end

	-- 放置待消除組合的容器
	-- ex:{ { {g1x1, g1y1},{g1x2, g1y2} }, { {g2x1, g2y1}, {g2x2, g2y2} } }, g=group
    local allClearGemPos = { }

    -- 全盤檢查, 儲存相連的組合
    for i=1, 5 do
        for j=1, 6 do
            if self.stage[i][j].checkHConnected == false or self.stage[i][j].checkVConnected == false then
                local clearGemPos = self:GetConnectedGemPos(i, j)

                if #clearGemPos > 0 then
                    allClearGemPos[#allClearGemPos+1] = clearGemPos
                end
            end
        end
    end

    if #allClearGemPos > 0 then	
		for i=1, #allClearGemPos do
			local t = timer.performWithDelay( GM.clearDelay*(i-1), clearGem )
			t.params = {gemPos = allClearGemPos[i]}
		end

		timer.performWithDelay( GM.clearDelay*#allClearGemPos, addNewGem )
		timer.performWithDelay( GM.clearDelay*#allClearGemPos, gemDrop )
	end

	allClearGemPos = nil
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