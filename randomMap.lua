

--	initialize variables

local composer = require("composer")
local scene = composer.newScene()
--local music = require("Sounds")
local widget = require("widget")
local physics = require("physics")
physics.start()
--local screenW = display.viewableContentWidth
--local screenH = display.viewableContentHeight
--local imageDir = "Images\\"
local bg = display.newImage(imageDir.."sky.png",1875,140)
local mountains = display.newImage(imageDir.."mountains.png",1875,screenH-80)
mountains.yScale = 0.8
local blocks = require("Block")
local player = require("Player")
local rightTut
local leftTut
local jumpTut


--	runtime event handler, constantly runs
function Runtime:enterFrame( event )

	--	run the player logic and get their x and y pos
	x,y = player.playerLogic(screenW,screenH)

	--	move the blocks relative to the player
	blocks.moveBlocks(x,y,screenW,true)

	--	move the background relative to the player
	bg.x = bg.x - (0.5 + (x/2))

	--	reset the background if beyond a certain threshold
	if bg.x < -45 then
		bg.x = 1875
	elseif bg.x > 1875 then
		bg.x = -45
	end

	--	move the mountains relative to the player
	mountains.x = mountains.x - (x/8)

	--	reset the mountains if beyond a certain threshold
	if mountains.x < -45 then
		mountains.x = 1875
	elseif mountains.x > 1875 then
		mountains.x = -45
	end
end

--	event handler to make the player jump
function bg:touch(event)
	player.playerJump()

	--	remove the tutorial if exists
	if jumpTut then
		jumpTut:removeSelf()
		jumpTut = nil
	end
end

--	event handler to make the player attack
local function handleAttack(event)
	player.attack(event)
end

--	event handler to make the player run right
local function handleRightEvent(event)
	player.moveRight(event)

	--	remove the tutorial if exists
	if rightTut then
		rightTut:removeSelf()
		rightTut = nil
	end
end

--	event handler to make the player run right
local function handleLeftEvent(event)
	player.moveLeft(event)

	--	remove the tutorial if exists
	if leftTut then
		leftTut:removeSelf()
		leftTut = nil
	end
end

--	event handler to return to menu
local function goMenu(event)
	composer.gotoScene("menu","slideUp",1000)
end

--	make attack button
local attack = widget.newButton
{
	left = 0,
	top = screenH-64,
	width = screenW,
	height = 64,
	defaultFile = imageDir.."attackBtn.png",
	overFile = imageDir.."attackBtn_press.png",
	onEvent = handleAttack
}

--	make right button
local rightArrow = widget.newButton
{
	left = screenW-32,
	top = 0,
	width = 64,
	height = screenH,
	defaultFile = imageDir.."rightArr.png",
	overFile = imageDir.."rightArr_h.png",
	onEvent = handleRightEvent
}

--	make left button
local leftArrow = widget.newButton
{
	left = -32,
	top = 0,
	width = 64,
	height = screenH,
	defaultFile = imageDir.."leftArr.png",
	overFile = imageDir.."leftArr_h.png",
	onEvent = handleLeftEvent
}

--	make exit button
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

--	scene create event handler, add objects to scene group
function scene:create(event)
	local sceneGroup = self.view
	sceneGroup:insert(bg)
	sceneGroup:insert(mountains)
	sceneGroup:insert(attack)
	sceneGroup:insert(leftArrow)
	sceneGroup:insert(rightArrow)
	sceneGroup:insert(exitBtn)
	blocks.init(screenW,screenH)
	player:CreatePlayer()
	rightTut = display.newImage(imageDir.."right_Tut.png",screenW-90,128)
	leftTut = display.newImage(imageDir.."left_Tut.png",90,128)
	jumpTut = display.newImage(imageDir.."jump_Tut.png",screenW/2,64)
	sceneGroup:insert(rightTut)
	sceneGroup:insert(leftTut)
	sceneGroup:insert(jumpTut)
end

function scene:show(event)

end

--	remove scene when hidden
function scene:hide(event)
		composer.removeScene("randomMap")
end

--	clear objects when scene is destroyed
function scene:destroy(event)
	Runtime:removeEventListener("enterFrame",mListener)
	bg:removeEventListener("touch",bg)
	blocks:RemoveBlocks()
	blocks = nil
	player:RemovePlayer()
	player = nil
	print("map destroyed?")
end

--	add event handlers
Runtime:addEventListener("enterFrame",Runtime)
bg:addEventListener("touch",bg)
scene:addEventListener("create",scene)
scene:addEventListener("show",scene)
scene:addEventListener("hide",scene)
scene:addEventListener("destroy",scene)

return scene
