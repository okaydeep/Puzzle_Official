-- Class sample
InfoManager = { }

_ = InfoManager

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.infoItem = { }

-- 產生資訊文字, msgOption:資訊文字設定
function _:GenerateInfo(msgOption)
	if #(self.infoItem) <= 0 then
		print("No info to display")
		return
	end

	local options = nil

	if msgOption ~= nil then
		options = msgOption
	else
		-- 預設資訊文字設定
		options = 
	    {
	        text = "",
	        x = 350,
	        y = 0,
	        width = 600,     --required for multi-line and alignment
	        font = native.systemFontBold,
	        fontSize = 20,
	        align = "left"  --new alignment parameter
	    }
	end

	for i=1, #(self.infoItem) do
		if self.infoItem[i].msg == nil then
			self.infoItem[i].msg = display.newText( options )
		end		

		if self.infoItem[i].title ~= nil then
			local info = self.infoItem[i].title

			if self.infoItem[i].content ~= nil then
				info = info .. self.infoItem[i].content
			end

			self.infoItem[i].msg.text = info
		end

        self.infoItem[i].msg.y = self.infoItem[i].msg.size*1.25*(i-1)	-- 間距為字型大小的1.25倍
        self.infoItem[i].msg:setFillColor( 1, 1, 1 )
	end
end

-- 增加項目, itemIdx:項目序列, title:項目標題, content:項目內容
function _:AddItem(itemIdx, title, content)
	if self.infoItem[itemIdx] == nil then
		self.infoItem[itemIdx] = { }		
	end

	self.infoItem[itemIdx].isShow = true
	self.infoItem[itemIdx].title = title
	self.infoItem[itemIdx].content = content
end

-- 更新項目內容, itemIdx:項目序列, content:項目更新內容
function _:UpdateItemContent(itemIdx, content)
	if self.infoItem[itemIdx] ~= nil and self.infoItem[itemIdx].msg ~= nil then
		self.infoItem[itemIdx].content = content
		self.infoItem[itemIdx].msg.text = self.infoItem[itemIdx].title .. content
	end
end

-- 設定項目是否顯示, itemIdx:項目序列, isShow:項目是否顯示
function _:ShowItem(itemIdx, isShow)
	if self.infoItem[itemIdx] ~= nil then
		self.infoItem[itemIdx].isShow = isShow
	end

	local posIdx = itemIdx-1

	for i=itemIdx, #(self.infoItem) do
		if self.infoItem[i].isShow == true then
			self.infoItem[i].msg.isVisible = true
			self.infoItem[i].msg.y = 25*posIdx
			posIdx = posIdx+1
		else
			self.infoItem[i].msg.isVisible = false
		end
	end
end