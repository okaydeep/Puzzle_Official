-- Class sample
MenuManager = { }

_ = MenuManager

-- Menu設定
_.iconIndexPosition = nil
_.iconHSpacing = nil
_.iconVSpacing = nil

--Menu資源
_.group = nil
_.bgImg = nil
_.menuIcons = nil
_.menuIconEvents = nil

-- Menu生成
function _:GenerateMenu( object, settings )
	-- 生成子物件
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	
	if type( settings ) ~= "table" then
		print( "Parameters type wrong" )
		return
	end

	self.group = display.newGroup()
	self.group:toFront()
	self.group.isVisble = false
	self.menuIconEvents = { }
	
	if settings.bgImg then
		self.bgImg = display.newImage( self.group, settings.bgImg )
	else
		print( "No such background image" )
	end

	if settings.menuIcons then
		self.menuIcons = { }
		for i=1, #settings.menuIcons do
			self.menuIcons[i] = display.newImage( self.group, settings.menuIcons[i] )
			local function touchEvent( event )
				if event.phase == "began" then
			    elseif event.phase == "ended" then
			    	if self.menuIconEvents[i] then
			    		self.menuIconEvents[i]()
			    	end
			        return true
			    end
			end
			self.menuIcons[i]:addEventListener( "touch", touchEvent )

-- function object:touch( event )
--     if event.phase == "began" then
--         print( "You touched the object!" )
--         return true
--     end
-- end

-- object:addEventListener( "touch", object )
		end
	else
		print( "No such menu icons" )
	end

	return object
end

-- 設定menu icon相對位置
--[[ 
	使用二維陣列表示, 根據產生menu時設定的圖片順序決定物件引數(從1開始), 小於1表示填空
	例:
	{
		{0,1,0},
		{0,2,0},
		{0,3,0}
	}
	上述例子的menu會將icon做垂直排列並置中, 且按順序的由上至下
]]
function _:SetIconPosition( posTable )
	if posTable then
		self.iconHSpacing = self.bgImg.height / (#posTable+1)		
		local vIconMaxAmount = 1
		for i=1, #posTable do
			if #(posTable[i]) > vIconMaxAmount then
				vIconMaxAmount = #(posTable[i])
			end
		end
		self.iconVSpacing = self.bgImg.width / (vIconMaxAmount+1)
	end

	for i=1, #posTable do
		for j=1, #posTable[i] do
			local idx = posTable[i][j]
			if idx > 0 then
				self.menuIcons[idx].x = self.menuIcons[idx].x + self.iconVSpacing*j - self.bgImg.width/2
				self.menuIcons[idx].y = self.menuIcons[idx].y + self.iconHSpacing*i - self.bgImg.height/2
			end
		end
	end
end

function _:SetIconClickEvent( eventTable )
	if eventTable then
		for i=1, #eventTable do
			if eventTable[i] then
				self.menuIconEvents[i] = eventTable[i]
			end
		end
	else
		print( "No event set" )
	end
end

-- 是否顯示menu
function _:ShowMenu(isShow)
	self.group.isVisble = isShow
end
