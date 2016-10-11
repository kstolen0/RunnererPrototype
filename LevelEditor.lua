
-- Your code here
local composer = require("composer")
local scene = composer.newScene()
local music = require("Sounds")
local widget = require("widget")
local physics = require("physics")
physics.start()
local screenW = display.viewableContentWidth
local screenH = display.viewableContentHeight
local imageDir = "Images/"
local bg = display.newImage(imageDir.."sky.png",1875,140)
local mountains = display.newImage(imageDir.."mountains.png",1875,screenH-80)
mountains.yScale = 0.8
local scroller = display.newImage(imageDir.."scrollScreen.png",0,0)
local blocks = require("Block")
--local editorBar = require("editorBar")

--	Function to return to the main menu
local function goMenu(event)
	composer.gotoScene("menu","slideDown",1000)
end


local exitBtn = widget.newButton
{
	left = screenW-16,
	top = 0,
	width = 32,
	height = 32,
	defaultFile = imageDir.."ExitButton.png",
	overFile = imageDir.."ExitButton.png",
	onEvent = goMenu
}

--	insert objects into scene group so they'll be removed when we exit
function scene:create(event)
	local sceneGroup = self.view
	sceneGroup:insert(bg)
	sceneGroup:insert(mountains)
	sceneGroup:insert(scroller)
	scroller.x = -16
	scroller.y = -20
	scroller.relX = 0
	scroller.relY = 0
	sceneGroup:insert(exitBtn)
	blocks.EditorInit()
	scroller:addEventListener("touch",scroller)
	scroller:addEventListener("tap",scroller)

	--editorBar:initBar()
end

function scene:show(event)
	music:editChannelPlay()
end

function scene:hide(event)
	composer.removeScene("LevelEditor")
	--music.editChannelEnd()

end

--	remove the objects that are out of scope of the sceneGroup and remove the event listeners to avoid errors
function scene:destroy(event)
	scroller:removeEventListener("touch",scroller)
	scroller:removeEventListener("tap",scroller)
	scroller:removeSelf()
	scroller = nil
	bg:removeSelf()
	bg = nil
	mountains:removeSelf()
	mountains = nil
	blocks:SaveBlocks()
	blocks:RemoveBlocks()
	blocks = nil
	print("editor Destroyed")
	--editorBar:removeBar()
end


--	function to drag grib and blocks around the screen
function scroller:touch(event)

	if event.phase == "moved" then
		dX = event.x - self.prevX
		dY = event.y - self.prevY
		self.prevX = event.x
		self.prevY = event.y

		self.x = self.x + dX
		self.y = self.y + dY

		blocks.editorMoveBlocks(-dX,-dY)

		self.relX = self.relX - dX
		self.relY = self.relY - dY

		--	reset the scroller if we're too far gone
		if self.x < -16 then
			self.x = 1872
		elseif self.x > 1872 then
			self.x = -16
		end

		if self.y < -20 then
			self.y = 1068
		elseif self.y > 1068 then
			self.y = -20
		end

	--	initialize prevX and prevY
	elseif event.phase == "began" then
		self.prevX = event.xStart
		self.prevY = event.yStart
	elseif event.phase == "ended" then

	--	update blocks x and y diff (may need to move this to either moved phase or when we destroy the scene)
	dX = self.relX - (math.floor(self.relX/32)*32)
	dY = self.relY - (math.floor(self.relY/32)*32)

	blocks.updateDiff(dX,dY)

	end
end

function scroller:tap(event)

	--	First we need to find the difference to the nearest factor of 32
	dX = self.relX - (math.floor(self.relX/32)*32)
	dY = self.relY - (math.floor(self.relY/32)*32)

	blocks.updateDiff(dX,dY)
	--	then we need to add this to where we tap (This was the last thing I figured out,
	--	and I'm still not sure I get it), plus 16 for rounding errors.
	x = event.x+dX+16
	y = event.y+dY+16

	--	we then find the nearest factor of 32
	x = math.floor(x/32)*32
	y = math.floor(y/32)*32

	--	We then send the positions to the addblock function, deducting the
	--	difference we initially came up with plus our real tap position to remove.
	blocks.EditorAddBlock(x-dX,y-dY,event.x+16,event.y+16,1)

	--	sometimes add a foot
	temp = math.random(10)
	if temp == 1 then
		blocks.EditorAddBlock(x-dX,y-dY-32,event.x+16,event.y+16-32,2)
	end

end

scene:addEventListener("create",scene)
scene:addEventListener("show",scene)
scene:addEventListener("hide",scene)
scene:addEventListener("destroy",scene)


return scene
