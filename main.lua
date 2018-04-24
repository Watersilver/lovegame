local draw = require("draw_functions")

function love.load()
  local w = 800
  local h = 450
  main_canvas = love.graphics.newCanvas(w, h)

  -- removes scaled sprite blurriness
  love.graphics.setDefaultFilter("nearest")

  playa = love.graphics.newImage("Sprites/Test.png")
  playax = 11
  playay = 11
end

function love.update(dt)

  -- get input

  -- move stuff to new positions

  -- resolve collisions until no collisions

  -- determine what's drawn and in what order

  -- draw to Canvases
  draw.ToMainCanvas(main_canvas)
end

-- draw to screen
function love.draw()
  -- Mandatory line before drawing canvas: Reset colour
  love.graphics.setColor(COLORCOST, COLORCOST, COLORCOST, COLORCOST)

  love.graphics.draw(main_canvas)
end

-- --Testing if version 11 works
-- function love.draw()
--   love.graphics.rectangle("fill", 10, 10, 10, 10)
--   love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 20, 10)
--   love.graphics.print("Hello World!", 400, 300)
-- end


function love.keypressed(key)
  if key == "right" then
    playax = playax + 1.5
  end
end
