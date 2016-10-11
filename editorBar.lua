--	turn this into a module
module(..., package.seeall)
local widget = require("widget")


local function eSlide( event )
--[[
  if event.phase == "moved" then
    if event.x < editorBar.sX then
      if editorBar.x > screenW - 64 then
        editorBar.x = editorBar.x - 1
      end
    else
      if editorBar.x < screenW then
        editorBar.x = editorBar.x + 1
      end
    end
  elseif event.phase == "began" then
    editorBar.sX = event.xStart
  end
--]]
end

function initBar()
  editorBar.open = true
  editorBar.isOpen = false
end



function removeBar()
  editorBar:removeSelf()
  editorBar = nil
end
