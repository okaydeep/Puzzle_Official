-- Class sample
GlobalManager = { }
_ = GlobalManager

function _:New(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

_.SpritePath = "img/sprite/"

_.ButtonName = { "Regenerate", "Play back", "Load Image" }
_.GemName = { "gem_red.png", "gem_orange.png", "gem_green.png", "gem_blue.png", "gem_purple.png", "gem_pink.png" }
_.Color = { "red", "orange", "green", "blue", "purple", "pink" }
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

_.touchRadius = 40
_.touchAreaCoe = 0.3	-- 觸碰範圍係數, 0.5是預設, 越小越好斜轉

_.gemWidth = 100
_.gemHeight = 110

_.gemStartX = 10
_.gemStartY = 100

-- 每一串珠消除的延遲
_.clearDelay = 350
-- 珠子掉落時間
_.dropDuration = 350
-- 回放珠子移動時間(每格)
_.playbackMoveDuration = 250

_.ColorR = { }
_.ColorG = { }
_.ColorB = { }

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

	GlobalManager.ColorR[#(GlobalManager.ColorR)+1] = event.r
	GlobalManager.ColorG[#(GlobalManager.ColorG)+1] = event.g
	GlobalManager.ColorB[#(GlobalManager.ColorB)+1] = event.b      
end

function _.DoColorSample(VerticalIdx, HorizontalIdx)
	local xOffset, yOffset, finalPosX, finalPosY = 0, 0, 0, 0
	local sumColorR, sumColorG, sumColorB = 0, 0, 0
	local avgColorR, avgColorG, avgColorB = 0, 0, 0

	xOffset = HorizontalIdx-3
	yOffset = VerticalIdx-3
	finalPosX = display.contentCenterX-50+(xOffset*100)
	finalPosY = display.contentCenterY+(yOffset*98)

	-- print(finalPosX, finalPosY)

	if #(GlobalManager.ColorR) > 0 then
		GlobalManager.ColorR = nil
		GlobalManager.ColorR = { }
	end

	if #(GlobalManager.ColorG) > 0 then
		GlobalManager.ColorG = nil
		GlobalManager.ColorG = { }
	end

	if #(GlobalManager.ColorB) > 0 then
		GlobalManager.ColorB = nil
		GlobalManager.ColorB = { }
	end

	-- 九個取樣點
	display.colorSample( finalPosX, finalPosY, GlobalManager.onColorSample )
	display.colorSample( finalPosX+10, finalPosY+10, GlobalManager.onColorSample )
	display.colorSample( finalPosX, finalPosY+10, GlobalManager.onColorSample )
	display.colorSample( finalPosX-10, finalPosY+10, GlobalManager.onColorSample )
	display.colorSample( finalPosX-10, finalPosY, GlobalManager.onColorSample )
	display.colorSample( finalPosX-10, finalPosY-10, GlobalManager.onColorSample )
	display.colorSample( finalPosX, finalPosY-10, GlobalManager.onColorSample )
	display.colorSample( finalPosX+10, finalPosY-10, GlobalManager.onColorSample )
	display.colorSample( finalPosX+10, finalPosY, GlobalManager.onColorSample )

	for i=1, #(GlobalManager.ColorR) do
		sumColorR = sumColorR+GlobalManager.ColorR[i]
		sumColorG = sumColorG+GlobalManager.ColorG[i]
		sumColorB = sumColorB+GlobalManager.ColorB[i]
	end

	avgColorR = sumColorR*(1/#(GlobalManager.ColorR))
	avgColorG = sumColorG*(1/#(GlobalManager.ColorR))
	avgColorB = sumColorB*(1/#(GlobalManager.ColorR))

	-- print ( string.format("RedAVG: %.2f, GreenAVG: %.2f, BlueAVG: %.2f",
	-- 	avgColorR,
	-- 	avgColorG,
	-- 	avgColorB ) )

	print( GlobalManager.Color[GlobalManager.getColorByRGB(avgColorR, avgColorG, avgColorB)] )
	-- print ( string.format("Aver Green: %.2f", averColorG*(1/#(GlobalManager.ColorR)) ) )
	-- print ( string.format("Aver Blue: %.2f", averColorB*(1/#(GlobalManager.ColorR) ) ) )
end

function _.getColorByRGB(r, g, b)
	local colorIdx = 0

	if r < 1.0 and r > 0.65 then
		if g < 0.6 and g > 0.3 then
			if b < 0.5 and b >0.2 then
				-- red
				colorIdx = 1
			end
		elseif g < 1.0 and g > 0.7 then
			if b < 0.55 and b > 0.25 then
				-- orange
				colorIdx = 2
			end
		elseif g < 0.3 and g > 0.0 then
			if b < 0.7 and b > 0.4 then
				-- pink
				colorIdx = 6
			end
		end
	elseif r < 0.65 and r > 0.2 then
		if g < 0.9 and g > 0.6 then
			if b < 0.55 and b > 0.25 then
				-- green
				colorIdx = 3
			elseif b < 1.0 and b > 0.7 then
				-- blue
				colorIdx = 4
			end
		elseif g < 0.4 and g > 0.1 then
			if b < 0.65 and b > 0.35 then
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

table.print = print_r