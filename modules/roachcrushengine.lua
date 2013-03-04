-----------------------------------------------------------------------------------------
--
-- roachcrushengine.lua
--
-----------------------------------------------------------------------------------------

-- forward declarations and other locals
local roachcrushengine = {}
local roachcrushengine_mt = { __index = roachcrushengine }

-- engine declarations
local pathImg = "res/img/"
local pathSound = "res/sound/"
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local portionH = 0.07
local score = 0
local lblScore
local elapTime = 0
local mTime
local lblTime
--local eatSound = audio.loadSound( pathSound .. "eat.mp3" )

-----------------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
-----------------------------------------------------------------------------------------

-- Food Functions

local function new_food( physics )
	local t = {}
	local objId
	local objName
	local food
	local x, y = screenW*0.95, math.round( screenH*portionH ) + 31
	for i=1, 8 do
		objId = math.random( 1, 12 )
		objName = "cake_" .. objId .. ".png"
		food = display.newImageRect( pathImg .. objName, 30, 30 )
		food.x = x
		food.y = y
		print ( food.y .. " :y")
		food.id = "food"
		food.n = i
		physics.addBody( food, { density = 1, friction = 0.3 } )
		table.insert( t, food)
		y = y + 31
	end
	return t
end

function startedFood( obj )
	local eatSound = audio.loadSound( pathSound .. "eat.mp3" )
	audio.play( eatSound, { duration=5000} )
end

function finishedFood( obj )
	if obj ~= nil then
		obj:removeSelf()
		obj = nil
	end
end

-- Chef Functions

local function new_chef( xPos, yPos )
	local newChef = display.newImage( pathImg .. "chef.png" )
	newChef.x = xPos
	newChef.y = yPos
	return newChef
end

-- Roach Functions

local function move_roach( roach )
	if roach.x then	
		roach.x = roach.x + roach.speed
	end
end

function onCollision( self, event )
	if event.other.id == "objThrowed" then
		-- Increment score
		increment_score()
		lblScore.text = get_score()
		self:removeSelf()
		self = nil
		event.other:removeSelf()
		event.other = nil
	elseif event.other.id == "food" then
		-- Eat performance
		self:removeSelf()
		self = nil
		if not event.other.isEated then
			event.other.isEated = true
			transition.to( event.other, { time=5000, alpha=0, onStart=startedFood, onComplete=finishedFood } )
		end
	end
end

-- Score & Time Functions
function increment_score()
	score = score + 50
end

function get_score()
	return "Score: " .. score .. "pts"
end

local function init_score()
	lblScore = display.newText( get_score(), screenW*0.8, 0, "OrganicFridays", 16 )
	return lblScore
end

local function init_time( mlTime )
	lblTime = display.newText( "Time: " .. (mlTime/1000 - elapTime) .. "secs" , screenW*0.05, 0, "OrganicFridays", 16 )
	return lblTime
end

function get_time()
	return "Time: " .. (mTime/1000 - elapTime) .. "secs"
end

function roachcrushengine:elapsedTime()
	elapTime = elapTime + 1
	lblTime.text = get_time() 
end

-----------------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------------------

-- Chef Functions

function roachcrushengine:moveChef( yPos )
	self.chef.y = yPos
end

-- Engine Functions

function roachcrushengine.new( roachNumber, speed, time, physics )  --constructor
	local newroachcrushengine = {
		roachNumber = roachNumber,
		roachTable = {},
		foodTable = new_food( physics ),
		speed = speed,
		lblTime = init_time( time ),
		time = time,
		lblScore = init_score(),
		chef = new_chef( screenW*0.84, screenH*0.5 )
	}
	mTime = newroachcrushengine.time
	return setmetatable( newroachcrushengine, roachcrushengine_mt )
end 

function roachcrushengine:nextLevel( physics )
	elapTime = 0
	self.roachNumber = self.roachNumber + 1
	self.roachTable = {}
	self.speed = self.speed + 1
	self.lblTime.text = get_time()
	time = self.time
	self.score = lblScore
end

-- Roach Functions

function roachcrushengine:newRoach( physics )
	local roach = display.newImageRect( pathImg .. "roach.png", 28, 28 )
	roach.x = -10
	roach.y = math.round( screenH*portionH ) + ( math.random( 1, 7) * 31 + 31) 
	print ( "y: " .. roach.y )
	roach.speed = self.speed
	roach.isMovable = true
	roach.isEated = false
	roach.collision = onCollision
	roach:addEventListener( "collision", roach )
	physics.addBody( roach, { isSensor = true } )
	table.insert( self.roachTable, roach )
end

function roachcrushengine:moveRoachs()
	for i=1,#self.roachTable do
		if self.roachTable[i] and self.roachTable[i].isMovable then
			move_roach( self.roachTable[i] )		
		end
	end
end

-- Crush Functions

function roachcrushengine:throwObjects( physics )
	local objId = math.random( 1, 12 )
	local objName = "cake_" .. objId .. ".png"
	local obj = display.newImageRect( pathImg .. objName, 30, 30 )
	obj.x = self.chef.x - 40
	obj.y = self.chef.y
	obj.id = "objThrowed"
	physics.addBody( obj, { density = 1, friction = 0.3, radius = 15 } )
	if obj ~= nil then
		obj:applyAngularImpulse( -10 )
		obj:applyLinearImpulse( -10, 0, obj.x, obj.y )
	end
end

return roachcrushengine