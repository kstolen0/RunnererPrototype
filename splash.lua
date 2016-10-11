
--	declare important variables
local composer = require("composer")
local scene = composer.newScene()
local imageDir = "Images/"
local screenW = display.viewableContentWidth
local screenH = display.viewableContentHeight
local splash
--	set splash image
splash = display.newImage(imageDir.."splash.png",1280,1280)

--	resize to nice fit
splash.xScale = 0.7
splash.yScale = 0.7
splash.x = screenW/2
splash.y = screenH/2

local mtimer

--	function to move to next scene
local function MoveIt()

	splash:removeEventListener("touch",splash)
	composer.gotoScene("menu","fade",1500)
end

local function MoveItQuick()
	composer.gotoScene("menu")
end

function splash:touch( event )

	if event.phase == "ended" then
		MoveItQuick()
	end

end

function scene:create(event)
	local sceneGroup = self.view
	mTimer = timer.performWithDelay(4000,MoveIt,1)
	sceneGroup:insert(splash)
end

function scene:hide(event)
	timer.cancel(mTimer);
	mTimer = nil
end

scene:addEventListener("create",scene)
scene:addEventListener("hide",scene)
splash:addEventListener("touch",splash)

return scene
