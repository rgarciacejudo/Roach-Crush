-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start()
physics.setGravity( 0, 0 )

--include Module RoachCrushEngine library
local engine = require "modules.roachcrushengine"
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local pathImg = "res/img/"
local crushEngine
local chef 
local foodTable = {}
local score
local time
local isPaused = false

background2 = display.newImageRect( pathImg .. "background.jpg", display.contentWidth, display.contentHeight )
background2:setReferencePoint( display.TopLeftReferencePoint )
background2.x, background2.y = 0, 0
background2.isVisible = false
	
-- create/position logo/title image on upper-half of the screen
titleLogo2 = display.newImageRect( pathImg .. "logo.png", 264, 42 )
titleLogo2:setReferencePoint( display.CenterReferencePoint )
titleLogo2.x = display.contentWidth * 0.5
titleLogo2.y = 100
titleLogo2.isVisible = false

-- Logic game

function onTouch( event )
	if event.phase == "began" then
		if event.y < math.round( screenH*0.07 ) + 31 then
			crushEngine:moveChef( math.round( screenH*0.07 ) + 31 )
			chef.y = math.round( screenH*0.07 ) + 31
        elseif event.y >= math.round( screenH*0.07 ) + ( 7 * 31 + 31) then
        	crushEngine:moveChef( math.round( screenH*0.07 ) + ( 7 * 31 + 31)  )
        	chef.y = math.round( screenH*0.07 ) + ( 7 * 31 + 31) 
        else
        	crushEngine:moveChef( event.y )
        	chef.y = event.y
        end
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

	physics.start()
	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background:setFillColor( 128 )
	
	-- make a roach (off-screen), position it, and rotate slightly
	crushEngine = engine.new( 4, 4, 20000, physics )
	chef = crushEngine.chef
	foodTable = crushEngine.foodTable
	score = crushEngine.lblScore
	time = crushEngine.lblTime

	-- add physics to the roach
	physics.addBody( chef )	
	physics.setDrawMode( "hybrid" )
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( chef )
	group:insert( score )
	group:insert( time )
	for i=1,#crushEngine.foodTable do
		group:insert( crushEngine.foodTable[i] )
	end
	-- start logic game
	genTimer = timer.performWithDelay( 2000, generateRoachs, crushEngine.roachNumber)
	moveTimer = timer.performWithDelay( 50, moveRoachs, 0 )
	crushTimer = timer.performWithDelay( 750, crushRoachs, 0 )
	timer.performWithDelay( crushEngine.time + 1000, timeOver)
	timer.performWithDelay( 1000, elapsedTime, crushEngine.time / 1000 + 1)

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
	if not isPaused then
		crushEngine:moveRoachs()
	end
end

function crushRoachs()
	if not isPaused then
		crushEngine:throwObjects( physics )
	end
end

function timeOver()
	timer.cancel( genTimer )
	timer.cancel( moveTimer )
	timer.cancel( crushTimer )
    background2.isVisible = true
	titleLogo2.isVisible = true
	timer.performWithDelay( 2000, nextLevel )
end

function nextLevel()
	crushEngine:nextLevel( physics )
	background2.isVisible = false
	titleLogo2.isVisible = false
	genTimer = timer.performWithDelay( 2000, generateRoachs, crushEngine.roachNumber)
	moveTimer = timer.performWithDelay( 50, moveRoachs, 0 )
	crushTimer = timer.performWithDelay( 750, crushRoachs, 0 )
	timer.performWithDelay( crushEngine.time + 1000, timeOver)
	timer.performWithDelay( 1000, elapsedTime, crushEngine.time / 1000 + 1)
end

function elapsedTime()
	crushEngine:elapsedTime()
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