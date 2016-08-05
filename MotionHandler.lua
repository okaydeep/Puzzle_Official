
hnd = { }
_ = hnd

function _.test()
	print( "ha" )
end

function _.Move( target, deltaX, deltaY, duration, easingType )
	local finalPosX = target.x + deltaX
	local finalPosY = target.y + deltaY
	transition.to( target, { x = finalPosX, y = finalPosY, time = duration, transition = easingType } )	
end

function _.MoveFromTo( target, startX, startY, endX, endY, duration, easingType )
	local finalPosX = startX + deltaX
	local finalPosY = startY + deltaY
	transition.to( target, { x = startX + deltaX, y = startY + deltaY, time = duration, transition = easingType } )
end

return hnd