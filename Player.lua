
--	turn this into a module
module(..., package.seeall)
--	add particleDesigner
local particleDesigner = require("particleDesigner")

local mover = {false,false}
local player
local maxSpeed = 3.8

local imageDir = "Images/"

--	create sequence sheet options and sequneces
local sheetOptions =
{
	width = 20,
	height = 32,
	numFrames = 64
}
local sheet_player = graphics.newImageSheet(imageDir.."plr.png",sheetOptions)
local sequences_player = {

	{
		name = "standing",
		start = 1,
		count = 8,
		time = 800,
		loopCount = 0,
		loopDirection = "forward"
	},

	{
		name = "runRight",
		start = 9,
		count = 8,
		time = 500,
		loopCount = 0,
		loopDirection = "forward"
	},

	{
		name = "runLeft",
		start = 17,
		count = 8,
		time = 500,
		loopCount = 0,
		loopDirection = "forward"
	},

	{
		name = "jumpRight",
		start = 25,
		count = 6,
		time = 600,
		loopCount = 0,
		loopDirection = "forward"
	},

	{
		name = "jumpLeft",
		start = 33,
		count = 6,
		time = 600,
		loopCount = 0,
		loopDirection = "forward"
	},

	{
		name = "attackRight",
		start = 41,
		count = 8,
		time = 600,
		loopCount = 0,
		loopDirection = "forward"
	},

	{
		name = "attackLeft",
		start = 49,
		count = 8,
		time = 600,
		loopCount = 0,
		loopDirection = "forward"
	}
}

--	function to determine which player sequence should run
local function NewSequence(self)
	--	by default we are standing
	local seq = "standing"

	--	check which way I'm facing
	if self.facing == 1 then
		--	check if I'm attacking
		if self.attack == true then
			seq = "attackRight"
		--	or if I'm jumping
		elseif self.jumping == true then
			seq = "jumpRight"
		--	otherwise I'm just running
		else
			seq = "runRight"
		end
	--	other test for left side
	else
		if self.attack == true then
			seq = "attackLeft"
		elseif self.jumping == true then
			seq = "jumpLeft"
		else
			seq = "runLeft"
		end
	end

	--	update if not already my current sequence
	if self.sequence ~= seq then
		self:setSequence(seq)
		self:play()
	end
end

--	add collision event handler
local function onLocalCollision(self,event)
	--	if I collide with anything let me jump again
	if event.phase == "began" then
		self.jumping = false
		player:NewSequence()
	end
end

--	initialize player attributes
function CreatePlayer()

	--	give player sprite sheet
	player = display.newSprite(sheet_player,sequences_player)
	player:play()

	--	make dinamic physics body
	physics.addBody(player,{density=6.0,friction=0.5,bounce=0.0})
	--	do not rotate
	player.isFixedRotation = true
	--	give a general location (will update as parameters)
	player.x = 100
	player.y = display.viewableContentHeight/3
	--	give him an id for reference
	player.id = "player"
	--	make him a little slimmer
	player.xScale = 0.8
	--	we're not jumping or attacking or moving
	player.jumping = false
	player.attack = false
	player.acc = 0
	--	we're facing right  (need to review facing/moving)
	player.facing = 1

	--	add player blast particle effect (need to add left effect)
	player.blast = particleDesigner.newEmitter("fire.json")
	player.blast.x = player.x+(player.width/2)
	player.blast.y = player.y
	player.blast:stop()

	-- add methods and event handlers
	player.NewSequence = NewSequence
	player.collision = onLocalCollision
	player:addEventListener("collision",player)

end

--	function to remove the player from memory
function RemovePlayer()

	player:removeSelf()
	player = nil

end

--	main function to determine how the player moves

function playerLogic(screenW,screenH)

	-- these variables are returned to the level to determine how much to
	--	move the map objects
	xDiff = 0.0
	yDiff = 0.0

	--	logic for when player is moving right
	if mover[1] == true then
		player.facing = 1
		--	if I'm not going my fastest, increase my acceleration, otherwise decrease my acceleration
		if player.acc < maxSpeed then
			player.acc = player.acc + 0.2
		else
			player.acc = player.acc - 0.2
		end
	--	logic for player moving left
	elseif mover[2] == true then
		player.facing = 0
		if player.acc > -maxSpeed then
			player.acc = player.acc - 0.2
		else
			player.acc = player.acc + 0.2
		end
	--	logic for when I'm not actively moving
	else
		--	reduce my acceleration until I've stopped
		if player.acc >= 0.2 then
			player.acc = player.acc - 0.2
		elseif player.acc <= -0.2 then
			player.acc = player.acc + 0.2
		else
			--	reset acc to 0 to account for tiny left overs
			player.acc = 0
			---[[
			if player.sequence ~= "standing" and player.jumping ~= true and player.attack ~= true then
				player:setSequence("standing")
				player:play()
			end
			--]]
		end
	end

	-- update player xPos
	player.x = player.x + player.acc

	--	reset player xPos if outside boundary and update xDiff
	if player.x >= screenW/2  or player.x <= 20 then
		player.x = player.x - player.acc
		xDiff = player.acc
	end

	--	likewise for play yPos
	if player.y > screenH/2 then
		yDiff = player.y - (screenH/2)
		player.y = screenH/2
	elseif player.y < screenH/3 then
		yDiff = player.y - screenH/3
		player.y = screenH/3
	end

	--	update player blast
	player.blast.x = player.x+(player.width/2)
	player.blast.y = player.y

	--	return difference
	return	xDiff, yDiff
end

--	function for player to jump
function playerJump()

	if player.jumping == false then
			player:setLinearVelocity(0,-200)
			player.jumping = true
			player:NewSequence()
		end

end

--	event handler for player to move right
function moveRight(event)

	local phase = event.phase

	if phase == "began" then
		mover[1] = true
		if player.jumping ~= true then
			player:NewSequence()
		end
	elseif phase == "ended" then
		mover[1] = false
	end
end

--	event handler for player to move left
function moveLeft(event)

	local phase = event.phase

	if phase == "began" then
		mover[2] = true
		if player.jumping ~= true then
			player:NewSequence()
		end
	elseif phase == "ended" then
		mover[2] = false
	end
end

--	event handler for player to attack (will likely need to update this to account for damage)
function attack(event)

	if event.phase == "began" and player.attack == false then
		player.attack = true
		maxSpeed = 2
		player:NewSequence()
		player.blast:start()
	elseif event.phase == "ended" then
		maxSpeed = 4
		player.blast:stop()
		player.attack = false
		player:NewSequence()
	end
end
