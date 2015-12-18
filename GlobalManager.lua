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

_.GemName = { "gem_red.png", "gem_orange.png", "gem_green.png", "gem_blue.png", "gem_purple.png", "gem_pink.png" }

_.Color = { "red", "orange", "green", "blue", "purple", "pink" }

_.touchRadius = 40

_.gemWidth = 100
_.gemHeight = 110

_.gemStartX = 10
_.gemStartY = 100

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