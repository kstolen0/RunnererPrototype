module(..., package.seeall)

local loadsave = require("loadsave")
local blocks = {}
local blockStash = {}
local ntimer = 0
local prevY = 200
local altBlock = 32
--local blockDir = "Images/block.png"
local imageDir = "Images/"

--	create deathball image sheet for horizontal and verticle
local deathBallSheet = graphics.newImageSheet(imageDir.."killBall.png",{width=16,height=16,numFrames=16})
local deathBallSequences = {

	{
		name = "horiz",
		start = 1,
		count = 6,
		time = 800,
		loopCount = 0,
		loopDirection = "forward"
	},

	{
		name = "vert",
		start = 9,
		count = 6,
		time = 800,
		loopCount = 0,
		loopDirection = "forward"
	},

}

--	initialize function for randomMap
function init(sW,sH)

	blocks = {}
	blockStash = {}
	local x = 0
	prevY = sH/2
	while x < sW+64 do
	local block = display.newImage(imageDir.."block.png",x,200)
	block.id = "block"
	physics.addBody(block,"static",{friction=0.5,bounce=0.0})
	table.insert(blocks,block)
	x = x + 32
	end

end


--	initialize function for editor
function EditorInit()
	blocks = {}
	blocks.dX = 0
	blocks.dY = 0
	blockStash = {}

	--	load table from file
	local temp = loadsave.loadTable("testTable.json",system.DocumentsDirectory)
	loadsave.printTable(temp)

	if temp == nil then
		blocks = {}
		blocks.dX = 0
		blocks.dY = 0
	else
		--	create new blocks from temp table data
		for i,v in ipairs(temp) do
			if v.id == "block" then
				gBlock(v.x,v.y)
			elseif v.id == "foot" then
				FootBlock(v.x,v.y)
			end
		end
		if(temp.dX) then
			blocks.dX = temp.dX
			blocks.dY = temp.dY
		end
	end

end

--	function to save blocks to file
function SaveBlocks()
	local temp = {}
	for i,v in ipairs(blocks) do
		t = {}
		t.id = v.id
		t.x = v.x + blocks.dX
		t.y = v.y + blocks.dY
		table.insert(temp,t)
	end
	print(blocks.dX)
	print(blocks.dY)
	loadsave.saveTable(temp,"testTable.json",system.DocumentsDirectory)

	--	in case mistakes happen uncomment this line to refresh the file
	--loadsave.saveTable({},"testTable.json",system.DocumentsDirectory)

end

--	function to clear blocks from memory
function RemoveBlocks()
	for i,v in ipairs(blocks) do
		v:removeSelf()
		v = nil
	end

	blocks = nil

	for i,v in ipairs(blockStash) do
		v:removeSelf()
		v = nil
	end

	blockStash = nil

end

--	function to check if this block is colliding with any other static object (physics doesn't handle collisions between static objects)
--	may need to look into changing block behaviour
function DeathCol(this,x)

	for i,v in ipairs(blocks) do
		if v.id ~= "dBall" then
			if (this.x  > (v.x + v.width) or
				((this.x + this.width) < v.x) or
				(this.y > (v.y + v.height)) or
				((this.y + this.height) < v.y)) ~= true then
				this.move = this.move * (-1)
				this.x = this.x + this.move
				break
			end
		end
	end
end

--	function to remove blocks entering the left of the screen from the main table
--	could look into adding them back into the table but the level was just to get things
--	started and the later optimization code will be vastly different
function StashBlocks()

	if blocks[1].x < -128 then
		table.insert(blockStash,table.remove(blocks,1))
	end

end

function updateDiff(dx,dy)
	blocks.dX = dx
	blocks.dY = dy

end

-- function to move all blocks by the given x and y coordinates
function editorMoveBlocks(x,y)

		for i,v in ipairs(blocks) do
			v.x = v.x - x
			v.y = v.y - y
		end

end

--	same as other move function but includes logic for blocks to perform actions and adds new blocks to the field
function moveBlocks(x,y,sW,inGame)

	ntimer = ntimer + x

	for i,v in ipairs(blocks) do
		v.x = v.x - x
		v.y = v.y - y
		prevY = v.y
		if v.id == "dBall" and inGame == true then
			v.x = v.x + v.move
			DeathCol(v)
		elseif v.id == "foot" then
			--print("this foot?")
			FootJump(v)
		end

	end

	--	after we've moved a certain amount, add a new block
	if ntimer > 30 then
		AddBlock(sW+64)
		ntimer = 0
	end

	--	get rid of any old blocks
	StashBlocks()

end

--	function to add a random block to the level
function AddBlock(x)

	ranY = math.random(10)
	local y = prevY

	if ranY == 1 then
		expBlock(x,y)
	elseif ranY == 2  and altBlock > 0 then
		FootBlock(x,y)
	elseif ranY == 7 then
		return
	else
		gBlock(x,y)
	end

	--	change the height
	if ranY == 2 then
		y = y + altBlock
		gBlock(x,y)
		if altBlock < 0 then
			DeathBall(x-32,y)
		end
		altBlock = -altBlock

	end
end

--	function to remove a block from the table, also determines if we should add a block
function EditorRemoveBlock(x,y)

	for i,v in ipairs(blocks) do
		if x > v.x and x < v.x + v.width and
			y > v.y and y < v.y + v.height then
				temp = table.remove(blocks,i)
				temp:removeSelf()
				temp = nil
				print("removed a block")
			return false
		end
	end

	return true

end

--	checks if we just removed a block, if not, add a block
function EditorAddBlock(x,y,dX,dY,bType)

	if EditorRemoveBlock(dX,dY) then
		if bType == 1 then
			gBlock(x,y)
		elseif bType == 2 then
			FootBlock(x,y)
		end
	end
end

--	function to add a generic block
function gBlock(x,y)

	local block = display.newImage(imageDir.."block.png",x,y)
	block.id = "block"
	block.x = x
	block.y = y
	physics.addBody(block,"static",{friction=0.5,bounce=0.0})
	prevY = y
	table.insert(blocks,block)

end

--	function to add an exploding block (doesn't explode, just looks different)
function expBlock(x,y)

	local block = display.newImage(imageDir.."expBlock.png",x,y)
	block.id = "expBlock"
	block.x = x
	block.y = y
	physics.addBody(block,"static",{friction=0.5,bounce=0.0})
	prevY = y
	table.insert(blocks,block)

end

--	function to add a death ball (moves across screen)
function DeathBall(x,y)

	local block = display.newSprite(deathBallSheet,deathBallSequences)
	block.x = x+1
	block.y = y+1
	block.move = 2
	block.id = "dBall"
	physics.addBody(block,"static",{friction=0.5,bounce=0.0})
	block:play()
	prevY = y
	table.insert(blocks,block)
end

--	function to make foot blocks jump
function FootJump(this)
	if this.jumping == false then
		print("jumping")
		this:setLinearVelocity(0,-150)
		this.jumping = true
	end
end

--	function to reset foot jump
local function SetJump(event)

	event.source.obj.jumping = false
	timer.cancel(event.source)

end

-- function to time foot to jump again soon
local function onLocalCollision(self,event)

	if event.phase == "began" then
		if self.tm then
			timer.cancel(self.tm)
		end
		tm = timer.performWithDelay(2000,SetJump)
		tm.obj = self
		self.tm = tm
	end
end

--	function to add a foot block (this one jumps)
function FootBlock(x,y)
	local block = display.newImage(imageDir.."Foot.png",x,y)
	block.id = "foot"
	block.x = x
	block.y = y
	block.jumping = false
	physics.addBody(block,{friction=0.5,bounce=0.3})
	block.collision = onLocalCollision
	block:addEventListener("collision",block)
	prevY = y
	table.insert(blocks,block)
end
