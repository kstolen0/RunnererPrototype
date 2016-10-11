module(..., package.seeall)

local imageDir = "Images/"

function expBlock(x,y)
	
	block = display.newImage(imageDir.."expBlock.png",x,y)
	block.id = "expBlock"

end