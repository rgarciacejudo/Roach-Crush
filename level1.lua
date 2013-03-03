-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setGravity( 0, 0 )

--include Module RoachCrushEngine library
local engine = require "modules.roachcrushengine"
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local pathImg = "res/img/"
local crushEngine
local chef 


-- Logic game

function onTouch( event )
	if event.phase == "began" then
        print( "Touch event began" )
        crushEngine:moveChef( event )
        chef.y = event.y
    end
    return true
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background:setFillColor( 128 )
	
	-- make a roach (off-screen), position it, and rotate slightly
	crushEngine = engine.new( 1, 1, screenW, screenH )
	chef = crushEngine.chef

	-- add physics to the roach
	physics.addBody( chef )	
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( chef )
	-- start logic game
	timer.performWithDelay( 1000, generateRoachs, crushEngine.roachNumber )
	timer.performWithDelay( 7000, generateRoachs, crushEngine.roachNumber + 3 )
	timer.performWithDelay( 50, moveRoachs, 0 )
	timer.performWithDelay( 2000, crushRoachs, 0 )

	Runtime:addEventListener( "touch", onTouch )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

function generateRoachs()
	crushEngine:newRoach( physics )
end

function moveRoachs()
	crushEngine:moveRoachs()
end

function crushRoachs()
	crushEngine:throwObjects( physics )
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene