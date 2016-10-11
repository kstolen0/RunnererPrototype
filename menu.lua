
--	I fear there is a memory leak in here somewhere but I'm not sure where

--	Declare variables / get required modules
local composer = require("composer")
local widget = require("widget")
local scene = composer.newScene()
local imageDir = "Images/"
local screenW = display.viewableContentWidth
local screenH = display.viewableContentHeight
local title
local sheet_title = graphics.newImageSheet(imageDir.."TitleSeqalt.png",{width=1280,height=720,numFrames=3})
local SeqTitle = {
	{
		name = "def",
		start = 1,
		count = 3,
		time = 300,
		loopCount = 0,
		loopDirection = "bounce"
	},
}

title = display.newSprite(sheet_title,SeqTitle)
title:play()
title.xScale = 0.5
title.yScale = 0.5
title.x = screenW/2
title.y = screenH/2



--	function to enter the randomMap scene. Originally
--	this was a swipe function but in the release version
--	the program would crash
function GoPlay(event)

	--[[if event.phase == "moved" then
		local dY = event.y - event.yStart

		if dY > 30 then
			composer.gotoScene("randomMap","slideDown",1000)
		end
	end
	--]]

	if event.phase == "ended" then
		composer.gotoScene("randomMap","slideDown",1000)
	end
end

--	function to enter the LevelEditor scene
function GoEdit(event)

	--[[if event.phase == "moved" then
		local dY = event.yStart - event.y
		if dY > 30  and event.target.set ~= true then
			composer.gotoScene("LevelEditor","slideUp",1000)
			event.target.set = true
		end
	end
	--]]

	if event.phase == "ended" then
		composer.gotoScene("LevelEditor","slideUp",1000)
	end
end

function exitGame(event)
	os.exit()
end

--	declaring menu buttons
local PlayButton = widget.newButton
{
	top = screenH/2,
	width = 64,
	height = 64,
	defaultFile = imageDir.."PlayButton.png",
	overFile = imageDir.."PlayButton_h.png",
	onEvent = GoPlay,
	set = false
}

local EditButton = widget.newButton
{
	top = screenH/2 + 64,
	width = 64,
	height = 64,
	defaultFile = imageDir.."EditoButton.png",
	overFile = imageDir.."EditorButton_h.png",
	onEvent = GoEdit
}

local ExitBtn = widget.newButton
{
	left = screenW-16,
	top = 0,
	width = 32,
	height = 32,
	defaultFile = imageDir.."ExitButton.png",
	overFile = imageDir.."ExitButton.png",
	onEvent = exitGame
}


--	add variables to scene
function scene:create(event)
	local sceneGroup = self.view
	sceneGroup:insert(title)
	sceneGroup:insert(PlayButton)
	sceneGroup:insert(EditButton)
	sceneGroup:insert(ExitBtn)

end


--	remove slpash screen when its hidden
function scene:show(event)
	composer.removeScene("splash")
end

--	remove this scene when its hidden
function scene:hide(event)
	composer.removeScene( "menu" )
end


scene:addEventListener("create",scene)
scene:addEventListener("show",scene)
scene:addEventListener("hide",scene)
title:addEventListener("touch",title)

return scene
