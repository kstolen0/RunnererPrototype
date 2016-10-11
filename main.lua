
--[[------------------------------------------------------------------
----------------------------------------------------------------------
NAME:		KRISTIAN STOLEN
STUDENT ID:	10385892
DATE:		09/16
PURPOSE:	A project I built as part of my portfolio learning,
				I added features to the project as time went buy, each 
				feature required me to learn something new about lua and 
				the corona environment. 
			As this was mostly a learning project, much of the code is quite messy
			so if I want to continue expanding this I will likely attempt to start from
			scratch and try to apply what I've learned in this unit. 
			
----------------------------------------------------------------------
---------------------------------------------------------------------]]


--  enable multitouch and composer
system.activate("multitouch")
imageDir = "Images\\"
screenW = display.viewableContentWidth
screenH = display.viewableContentHeight
local composer = require("composer")

--  open splash screen
composer.gotoScene("splash","fade",1500)


--  Need to review how objects are displayed on here as some screens
--  don't like it, looked into changing the config file but this may
--  require many changes which likely won't be implemented before the
--  due date.
