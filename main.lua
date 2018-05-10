-- Load global stuff that might be used anywhere
require("global")

-- Camera library found at https://github.com/kikito/gamera
gamera = require "gamera.gamera"
-- Collision detection library found at https://github.com/vrld/HC
HC = require "HC"


local scaling_handler = require("scaling_handler")
input = require("input")

--dofile("Rooms/room1.lua")
assert(love.filesystem.load("Rooms/room1.lua"))()

local cam = gamera.new(0, 0, 2800, 2450)
cam.x = 0
cam.y = 0

-- For gamera:setScale. Don't change directly
local total_scale = scaling_handler.calculate_total_scale{game_scale=1}

function love.load()

end

function love.update(dt)

  -- get input
  pl1in_previous = pl1in
  pl1in = input.check_input(input.controllers.player1)

  -- determine what effect input has

  -- move stuff to new positions
  if updaters[1] then
    local upnum = #updaters
    for i = 1, upnum do
      updaters[i]:update()
    end
  end

  -- resolve collisions until no collisions

  -- determine what's drawn and in what order

end

function love.resize( w, h )

  -- Set camera display window size and offset
  cam:setWindow(scaling_handler.resize_calculate_dimensions( w, h ))

  -- Determine camera scale due to window size
  total_scale = scaling_handler.calculate_total_scale{resized=true}

end

-- draw to screen
function love.draw()
  -- Mandatory line before drawing canvas: Reset colour
  -- love.graphics.setColor(COLORCOST, COLORCOST, COLORCOST, COLORCOST)

  -- Set camera
  cam:setScale(total_scale)
  cam:setPosition(cam.x, cam.y)

  -- draw camera
  cam:draw(function(l,t,w,h)
    local camx, camy = cam:getPosition()
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
    end

    fuck = #visibles[1]

    for layer = 1, layers do
      vila = visibles[layer]
      if vila then
        local vinum = #vila
        for i = 1, vinum do
          love.graphics.draw(
          vila[i].draw.sprite,
          vila[i].position.x,
          vila[i].position.y)
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
