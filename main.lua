local scaling_handler = require("scaling_handler")
local gamera = require "gamera.gamera"

local cam = gamera.new(0, 0, 800, 450)

-- For gamera:setScale. Don't change directly
local total_scale = scaling_handler.calculate_total_scale{}

function love.load()

  -- removes scaled sprite blurriness
  love.graphics.setDefaultFilter("nearest")

  playa = love.graphics.newImage("Sprites/Test.png")
  playax = 11
  playay = 11
end

function love.update(dt)

  playax = playax + 2
  -- get input

  -- move stuff to new positions

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
  cam:setPosition(0, 0)

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
    love.graphics.draw(playa, playax, playay)
  end)
end

-- --Testing if version 11 works
-- function love.draw()
--   love.graphics.rectangle("fill", 10, 10, 10, 10)
--   love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 20, 10)
--   love.graphics.print("Hello World!", 400, 300)
-- end
