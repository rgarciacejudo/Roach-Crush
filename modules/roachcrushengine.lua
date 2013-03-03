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

-----------------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
-----------------------------------------------------------------------------------------

-- Chef Functions

local function new_chef( xPos, yPos )
	local newChef = display.newImage( pathImg .. "chef.png" )
	newChef.x = xPos
	newChef.y = yPos
	return newChef
end

function roachcrushengine:moveChef( event )
	self.chef.y = event.y
end

-- Roach Functions

local function move_roach( roach )
	roach.x = roach.x + roach.speed
end

function onCollision( self, event )
	if event.other.id == "objThrowed" then
		self:removeSelf()
		self = nil
		event.other:removeSelf()
		event.other = nil
	end
end


-----------------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------------------

function roachcrushengine.new( roachNumber, speed, width, height )  --constructor
	local newroachcrushengine = {
		roachNumber = roachNumber,
		roachTable = {},
		speed = speed,
		chef = new_chef( width*0.9, height*0.5 )
	}
	return setmetatable( newroachcrushengine, roachcrushengine_mt )
end 

function roachcrushengine:newRoach( physics )
	local roach = display.newImage( pathImg .. "roach.png" )
	roach.x = -32
	roach.y = math.random( 0, 320)
	roach.speed = self.speed
	roach.collision = onCollision
	roach:addEventListener( "collision", roach )
	physics.addBody( roach, { isSensor = true } )
	table.insert( self.roachTable, roach )
end

function roachcrushengine:moveRoachs()
	for i=1,#self.roachTable do
		if self.roachTable[i].isVisible then
			if self.roachTable[i].x >= 400 then
				self.roachTable[i]:removeSelf()
				self.roachTable[i] = nil
				print("Llego al otro lado")
			else
				move_roach( self.roachTable[i] )		
			end
		end
	end
end

function roachcrushengine:throwObjects( physics )
	local objId = math.random( 1, 12 )
	local objName = "cake_" .. objId .. ".png"
	local obj = display.newImage( pathImg .. objName )
	obj.x = self.chef.x - 100
	obj.y = self.chef.y
	obj.id = "objThrowed"
	physics.addBody( obj, { density = 1, friction = 0.3, radius = 15 } )
	obj:applyAngularImpulse( -10 )
	obj:applyLinearImpulse( -10, 0, obj.x, obj.y )

end

return roachcrushengine