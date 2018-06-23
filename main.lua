local ps = require "physics_settings"
local o = require "GameObjects.objects"
local p = require "GameObjects.BoxTest"
local u = require "utilities"
local sh = require "scaling_handler"
local inp = require "input"
local im = require "image"

local gamera = require "gamera.gamera"


local cam = gamera.new(0,0,800,450)
sh.calculate_total_scale{game_scale=1}
cam.xt = 0
cam.yt = 0


fuck = 0


function love.load()
  ps.pw:setCallbacks(beginContact, endContact, preSolve, postSolve)

  --dofile("Rooms/room1.lua")
  assert(love.filesystem.load("Rooms/room1.lua"))()
end


function preSolve(a, b, coll)
    local apreSolve = a:getBody():getUserData().preSolve
    if apreSolve then
      apreSolve(a, b, coll)
    end
    local bpreSolve = b:getBody():getUserData().preSolve
    if bpreSolve then
      bpreSolve(a, b, coll)
    end
end


function love.update(dt)
fuck = #o.colliders
  if o.to_be_added[1] then
    o.to_be_added:add_all()
  end

  inp.check_input()

  local upnum = #o.updaters
  if upnum > 0 then
    for i = 1, upnum do
      o.updaters[i]:update(dt)
    end
  end

  ps.pw:update(dt)

  if o.to_be_deleted[1] then
    o.to_be_deleted:remove_all()
  end

end


function love.draw()

  cam:setScale(sh.get_total_scale())
  cam:setPosition(cam.xt, cam.yt)

  cam:draw(function(l,t,w,h)

    local curcol = love.graphics.getColor()
    love.graphics.setColor(155, 155, 155, 255)
    love.graphics.rectangle("fill", 0, 0, 800, 450)
    love.graphics.setColor(255, 255, 255, 255)

    local layers = #o.draw_layers
    if layers > 0 then
      for layer = 1, layers do
        local drawnum = #o.draw_layers[layer]
        for i = 1, drawnum do
          o.draw_layers[layer][i]:draw()
        end
      end
    end

    love.graphics.print(love.timer.getFPS())
    love.graphics.print(fuck, 0, 13)
  end)

end


function love.mousepressed(x, y, button, isTouch)
  x, y = cam:toWorld(x, y)
  u.push(o.to_be_added, p:new{xstart=x, ystart=y})
end


function love.resize( w, h )

  -- Set camera display window size and offset
  cam:setWindow(sh.calculate_resized_window( w, h ))

  -- Determine camera scale due to window size
  sh.calculate_total_scale{resized=true}
end


-- main function with main loop
-- function love.run()
--
-- 	if love.math then
-- 		love.math.setRandomSeed(os.time())
-- 	end
--
-- 	if love.load then love.load(arg) end
--
-- 	-- We don't want the first frame's dt to include time taken by love.load.
-- 	if love.timer then love.timer.step() end
--
-- 	local dt = 0
--
-- 	-- Main loop time.
-- 	while true do
-- 		-- Process events.
-- 		if love.event then
-- 			love.event.pump()
-- 			for name, a,b,c,d,e,f in love.event.poll() do
-- 				if name == "quit" then
-- 					if not love.quit or not love.quit() then
-- 						return a
-- 					end
-- 				end
-- 				love.handlers[name](a,b,c,d,e,f)
-- 			end
-- 		end
--
-- 		-- Update dt, as we'll be passing it to update
-- 		if love.timer then
-- 			love.timer.step()
-- 			dt = love.timer.getDelta()
-- 		end
--
-- 		-- Call update and draw
-- 		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
--
-- 		if love.graphics and love.graphics.isActive() then
-- 			love.graphics.clear(love.graphics.getBackgroundColor())
-- 			love.graphics.origin()
-- 			if love.draw then love.draw() end
-- 			love.graphics.present()
-- 		end
--
-- 		if love.timer then love.timer.sleep(0.001) end
-- 	end
--
-- end
