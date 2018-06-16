-- Load global stuff that might be used anywhere
require("global")

require("image")

require("shapes")

require("utilities")

-- Camera library found at https://github.com/kikito/gamera
gamera = require "gamera.gamera"


local scaling_handler = require("scaling_handler")
local input = require("input")

local cam = gamera.new(0, 0, 2800, 2450)
-- Do NOT name cam.x or cam.y. Reserved by gamera.
cam.xt = 0
cam.yt = 0

-- For gamera:setScale.
scaling_handler.calculate_total_scale{game_scale=1}

-- To limit frames per second
local fps_min = 1/60

function love.load()
  -- set physical world for collisions
  physWorld = love.physics.newWorld(0, 600)
  physWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

  --dofile("Rooms/room1.lua")
  assert(love.filesystem.load("Rooms/room1.lua"))()
end

function love.mousepressed(x, y, button, isTouch)
  local pl = require("PlayaTest")
  local element = pl:new()
  element.position = {x = 333, y = 111}
  if element.body then
    element.body:setPosition(element.position.x, element.position.y)
  end
  addToWorld(element)
end

fuck = 0
function beginContact(a, b, coll)

end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
    if a:getUserData().postSolve then
      a:getUserData():postSolve(a, b, coll, normalimpulse, tangentimpulse)
    end
    if b:getUserData().postSolve then
      b:getUserData():postSolve(a, b, coll, normalimpulse, tangentimpulse)
    end
end


function love.update(dt)
  if dt < fps_min then
    love.timer.sleep(fps_min - dt)
  end
  if string.len(debugtxt) > 768 then debugtxt = "" end

  physWorld:update(dt)

  -- get input
  pl1in_previous = pl1in
  pl1in = input.check_input(input.controllers.player1)

  -- determine what effect input has

  -- move stuff to new positions
  if updaters[1] then
    local upnum = #updaters
    for i = 1, upnum do
      updaters[i]:update(dt)
    end
  end
  -- ***Handled by physics***
  -- resolve collisions until no collisions
  -- if colliders[1] then
  --   local colnum = #colliders
  --   for i = 1, colnum do
  --     colliders[i]:collide(dt)
  --   end
  -- end

  -- determine what's drawn and in what order
end

function love.resize( w, h )

  -- Set camera display window size and offset
  cam:setWindow(scaling_handler.calculate_resized_window( w, h ))

  -- Determine camera scale due to window size
  scaling_handler.calculate_total_scale{resized=true}
end

function love.wheelmoved( x, y )
  scaling_handler.calculate_total_scale{
    game_scale = scaling_handler.get_game_scale() + y * 0.01
  }

  removeFromWorld(visibles[1][2])
  -- fuck = #visibles[1]
end

-- draw to screen
function love.draw()
  -- Mandatory line before drawing canvas: Reset colour
  -- love.graphics.setColor(COLORCOST, COLORCOST, COLORCOST, COLORCOST)

  -- Set camera
  cam:setScale(scaling_handler.get_total_scale())
  cam:setPosition(cam.xt, cam.yt)

  -- draw camera
  cam:draw(function(l,t,w,h)
    local camx, camy = cam:getPosition()
    love.graphics.setColor(0, COLORCOST*0.2, 0, COLORCOST)
    love.graphics.rectangle("fill", 22, 22, 2800-44, 2450-44)
    love.graphics.setColor(COLORCOST, 0, 0, COLORCOST)
    love.graphics.rectangle("fill", 22, 22, 800-44, 450-44)
    love.graphics.setColor(COLORCOST, COLORCOST, COLORCOST, COLORCOST)
    love.graphics.print("Hi, I'm gamera."..camx..","..camy)
    love.graphics.rectangle("fill", 11, 11, 33, 33)
    love.graphics.setColor(COLORCOST, COLORCOST, 0, COLORCOST)
    love.graphics.rectangle("fill", 33, 33, 33, 33)
    -- draw stuff..
    --love.graphics.scale(5)
    love.graphics.setColor(COLORCOST, COLORCOST, COLORCOST, COLORCOST)

    if fuck then
      love.graphics.print(fuck, 66, 66)
      love.graphics.print(debugtxt, 66, 99)
    end

    for layer = 1, layers do
      vila = visibles[layer]
      if vila then
        local vinum = #vila
        for i = 1, vinum do
          vila[i]:draw()
        end
      end
    end

  end)
end
-- --Testing if version 11 works
-- function love.draw()
--   love.graphics.rectangle("fill", 10, 10, 10, 10)
--   love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 20, 10)
--   love.graphics.print("Hello World!", 400, 300)
-- end
