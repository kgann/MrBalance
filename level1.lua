-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.setDrawMode("hybrid")
physics.start(); physics.setGravity(0, 10); physics.pause()


-- gameUI
local gameUI = require("gameUI")
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-----------------------------------------------------------------------------------------
-- Mr. Balance
-----------------------------------------------------------------------------------------

local num_balls = 0
local max_balls = 3
local previousBody = nil

local function localDrag(e)
  gameUI.dragBody(e, {maxForce = 6, frequency = 2, center = true})
end

local function createJoint(prev, new)
  print("joint")
  -- physics.newJoint("pivot", prev, new, prev.x, prev.y)
end

local function trackBall(ball)
  num_balls = num_balls + 1
end

local function dropBall()
  print("ball")
  ball = display.newCircle(math.random(10, screenW-10), -100, 20, 100)
  ball.ball = true
  physics.addBody(ball, {friction = 0.8, bounce = 0.1})
  trackBall(ball)
end

local function onCollision(e)
  if(e.phase == "began" and e.object2.ball and (e.object1.stick or e.object1.ball)) then
    print("joint")
    local clj = function() return createJoint(e.object1, e.object2) end
    timer.performWithDelay(1, clj, 1)
    previousBody = ball
  end
  return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background:setFillColor( 128 )
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW, 82 )
	grass:setReferencePoint( display.BottomLeftReferencePoint )
	grass.x, grass.y = 0, screenH
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	
	-- create stick
	stick = display.newRect((screenW/2)-10, -100, 20, 100)
	physics.addBody(stick, {friction=0.6, bounce=0.2 })
	stick.isFixedRotation = true
	stick.stick = true
	stick:addEventListener("touch", localDrag)
	previousBody = stick

  -- setup colision detection
  Runtime:addEventListener( "collision", onCollision )

  -- fire timer to drop balls
  timer.performWithDelay(5000, dropBall, max_balls)

	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( grass)
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

-----------------------------------------------------------------------------------------
-- Mr. Balance
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