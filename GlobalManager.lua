
-- ===================================
-- 全域管理
-- ===================================

GlobalManager = { }
_ = GlobalManager

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.ImgRootPath	= "img/"
_.SpritePath	= "img/gem03/"
_.UIPath		= "img/ui/"

_.ButtonName = { "Regenerate", "Play back", "Load Image" }
_.ScreenRatioSwitchButtonName = { "16:9", "4:3" }
_.GemName = { "gem_01.png", "gem_02.png", "gem_03.png", "gem_04.png", "gem_05.png", "gem_06.png" }
_.Color = { "red", "blue", "green", "orange", "purple", "pink" }
_.ColorIdxArr = { 1, 2, 3, 4, 5, 6 }

_.LocatePointDir = { "TopLeft", "TopRight", "BottomRight", "BottomLeft" }

_.btnDefaultOption = { 
				left = 100,
                top = 200,
                label = "Button",
                --labelColor = { default={ 1, 1, 1 }, over={ 0.4 ,0.4 ,0.4 } },
                --font = native.systemFont,
                fontSize = 32,
                --emboss = true,
                --id = "button",
                -- width = 160,
                -- height = 80,
                -- defaultFile = GM.SpritePath.."reset.png",
                -- overFile = GM.SpritePath.."reset_pressed.png",
                --onEvent = handleButtonEvent
              }

_.canTouch = true
_.loadFromImage = false

_.touchAreaCoe = 0.3	-- 觸碰範圍係數, 0.5是預設, 越小越好斜轉

-- 每一串珠消除的延遲
_.clearDelay = 350
-- 珠子掉落時間
_.dropDuration = 350
-- 回放珠子移動時間(每格)
_.playbackMoveDuration = 250

-- PAD截圖預設位置
_.PAD_scaleRatio = display.contentHeight/1920
_.PAD_parseXOffset = 177*_.PAD_scaleRatio
_.PAD_parseYOffset = 177*_.PAD_scaleRatio
_.PAD_parseStartPosX = display.contentCenterX-_.PAD_parseXOffset*3
_.PAD_parseStartPosY = display.contentCenterY-57

_.ColorH = { }
_.parsedColor = {
	{ },
	{ },
	{ },
	{ },
	{ }
}

_.parseColorCallback = { }

-- 設定螢幕比例為16:9(預設)
function _:SetScreenRatio16_9()
    self.PAD_parseXOffset = 177*self.PAD_scaleRatio
    self.PAD_parseYOffset = 177*self.PAD_scaleRatio
    self.PAD_parseStartPosY = display.contentCenterY-57
end

-- 設定螢幕比例為4:3
function _:SetScreenRatio4_3()
    self.PAD_parseXOffset = 163*self.PAD_scaleRatio
    self.PAD_parseYOffset = 163*self.PAD_scaleRatio
    self.PAD_parseStartPosY = display.contentCenterY
end

-- 深層拷貝(可以複製table), object:欲複製的目標物件
function _.deepCopy(object)
    local lookup_table = {}

    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        local new_table = {}

        lookup_table[object] = new_table

        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end

    return _copy(object)
end

-- Color Sample 的callback
function _.onColorSample( event )
	-- print( "Sampling pixel at position (" .. event.x .. "," .. event.y .. ")" )
	-- print( "R = " .. event.r )
	-- print( "G = " .. event.g )
	-- print( "B = " .. event.b )
	-- print( "A = " .. event.a )
	local h = GlobalManager.rgbToHsv(event.r, event.g, event.b)
	GlobalManager.ColorH[#(GlobalManager.ColorH)+1] = h
end

-- 分析顏色, verticalIdx:第幾橫排, horizontalIdx:第幾縱列
function _:DoColorSample(verticalIdx, horizontalIdx)
	local xOffset, yOffset, finalPosX, finalPosY = 0, 0, 0, 0	
	
	xOffset = horizontalIdx-3
	yOffset = verticalIdx-3

	finalPosX = GlobalManager.PAD_parseStartPosX+GlobalManager.PAD_parseXOffset*0.5+(GlobalManager.PAD_parseXOffset*(horizontalIdx-1))
	finalPosY = GlobalManager.PAD_parseStartPosY+GlobalManager.PAD_parseYOffset*0.5+(GlobalManager.PAD_parseYOffset*(verticalIdx-1))

	-- display.newRect( finalPosX, finalPosY, 3, 3 )	-- 偵測位置測試點

	-- 九個取樣點
	display.colorSample( finalPosX, finalPosY, GlobalManager.onColorSample )
	-- display.colorSample( finalPosX+10, finalPosY+10, GlobalManager.onColorSample )
	-- display.colorSample( finalPosX, finalPosY+10, GlobalManager.onColorSample )
	-- display.colorSample( finalPosX-10, finalPosY+10, GlobalManager.onColorSample )
	-- display.colorSample( finalPosX-10, finalPosY, GlobalManager.onColorSample )
	-- display.colorSample( finalPosX-10, finalPosY-10, GlobalManager.onColorSample )
	-- display.colorSample( finalPosX, finalPosY-10, GlobalManager.onColorSample )
	-- display.colorSample( finalPosX+10, finalPosY-10, GlobalManager.onColorSample )
	-- display.colorSample( finalPosX+10, finalPosY, GlobalManager.onColorSample )

	-- local colorIdx = GlobalManager.getColorByRGB(avgColorR, avgColorG, avgColorB)
	-- print (verticalIdx .. "," .. horizontalIdx .. ": " .. colorIdx .. ". " .. avgColorR .. "," .. avgColorG .. "," .. avgColorB)	-- 分析顏色資訊

	-- if #(GlobalManager.ColorR) >= 1 then
		if type(GlobalManager.parseColorCallback[1]) == "function" then
			GlobalManager.parseColorCallback[1]()
			GlobalManager.parseColorCallback[1] = nil
		end
	-- end
end

-- 分析平均顏色決定種類
function _.getColorByRGB(r, g, b)
	local colorIdx = 0

	-- local h, s, v = GlobalManager.rgbToHsv(r, g, b, 255)
	-- print("H: " .. h .. ", S: " .. s .. ", V: " .. v)

	if r > 0.8 then
		if g < 0.7 and g > 0.4 then
			if b < 0.6 and b > 0.2 then
				-- red
				colorIdx = 1
			end
		elseif g < 1.0 and g > 0.7 then
			if b < 0.6 and b > 0.2 then
				-- orange
				colorIdx = 2
			end
		elseif g < 0.4 and g > 0.0 then
			if b < 0.8 and b > 0.4 then
				-- pink
				colorIdx = 6
			end
		end
	elseif r < 0.8 then
		if g < 0.9 and g > 0.5 then
			if b < 0.6 then
				-- green
				colorIdx = 3
			elseif b > 0.6 then
				-- blue
				colorIdx = 4
			end
		elseif g < 0.5 then
			if b < 0.8 and b > 0.4 then
				-- purple
				colorIdx = 5
			end
		end
	end

	if colorIdx == 0 then
		print("No similiar color sample: R:" .. r .. " G:" .. g .. " B:" .. b .. "\nUsing default red instead")
		colorIdx = 1
	end

	return colorIdx
end

function _.hToColorIdx( h )
	local colorIdx = 1

	if h > 0 and h < 20 then
		colorIdx = 1
	elseif h > 40 and h < 80 then
		colorIdx = 4
	elseif h > 120 and h < 140 then
		colorIdx = 3
	elseif h > 180 and h < 220 then
		colorIdx = 2
	elseif h > 280 and h < 310 then
		colorIdx = 5
	elseif h > 310 and h < 340 then
		colorIdx = 6
	end

	return colorIdx
end

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+4))
                        print(indent..string.rep(" ",string.len(pos)+3).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else            
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function _.rgbToHsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  -- 額外增加角度
  h = h * 360

  return h, s, v
end

function _.hsvToRgb(h, s, v)
  local r, g, b

  local i = Math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255
end

function _.ClearTable(table)
    for k,v in pairs(table) do
        if type(table[k] ~= "table") then
            table[k] = nil
        else
            if noInnerTable(table[k]) == true then
                table[k] = nil
            else
                ClearTable(table[k])
            end
        end
    end

    function noInnerTable(t)
        if type(t) ~= "table" then return end

        local tNum = 0

        for k,v in pairs(t) do
            if type(t[k]) == "table" then
                tNum = tNum+1
            end
        end

        if tNum <= 0 then
            return true
        else
            return false
        end
    end
end

table.print = print_r