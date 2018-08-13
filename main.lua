local ps = require "physics_settings"
local o = require "GameObjects.objects"
local p = require "GameObjects.BoxTest"
local u = require "utilities"
local sh = require "scaling_handler"
local inp = require "input"
local im = require "image"
local game = require "game"
local inv = require "inventory"

local gamera = require "gamera.gamera"


local cam = gamera.new(0,0,800,450)
cam.xt = 0
cam.yt = 0

local hud = gamera.new(0,0,400,225)
hud.xt = 0
hud.yt = 0

sh.calculate_total_scale{game_scale=2}


fuck = 0


function love.load()
  ps.pw:setCallbacks(beginContact, endContact, preSolve, postSolve)

  --dofile("Rooms/room1.lua")
  assert(love.filesystem.load("Rooms/room1.lua"))()
end

function beginContact(a, b, coll)
    -- If it's a sprite depth dispute solve
    if a:getCategory() == SPRITECAT then
      return
    end

    -- Store the objects that collided
    local aob = a:getBody():getUserData()
    local bob = b:getBody():getUserData()

    if aob.beginContact then
      aob:beginContact(a, b, coll, aob, bob)
    end
    if bob.beginContact then
      bob:beginContact(a, b, coll, aob, bob)
    end
end

function endContact(a, b, coll)
    -- If it's a sprite depth dispute solve
    if a:getCategory() == SPRITECAT then
      return
    end

    -- Store the objects that collided
    local aob = a:getBody():getUserData()
    local bob = b:getBody():getUserData()

    if aob.endContact then
      aob:endContact(a, b, coll, aob, bob)
    end
    if bob.endContact then
      bob:endContact(a, b, coll, aob, bob)
    end
end

function preSolve(a, b, coll)
    -- If it's a sprite depth dispute solve
    if a:getCategory() == SPRITECAT then
      coll:setEnabled(false)
      local abod, bbod = a:getBody(), b:getBody()
      local _, apos = abod:getPosition()
      local _, bpos = bbod:getPosition()
      local aob, bob = abod:getUserData(), bbod:getUserData()
      if aob.layer == bob.layer and (apos > bpos and aob.drawable < bob.drawable) or
      (apos < bpos and aob.drawable > bob.drawable) then
        u.swap(o.draw_layers[aob.layer], aob.drawable, bob.drawable)
      end
      return
    end

    -- Store the objects that collided
    local aob = a:getBody():getUserData()
    local bob = b:getBody():getUserData()

    if aob.preSolve then
      aob:preSolve(a, b, coll, aob, bob)
    end
    if bob.preSolve then
      bob:preSolve(a, b, coll, aob, bob)
    end
end


function love.update(dt)
  if o.to_be_added[1] then
    o.to_be_added:add_all()
  end

  inp.check_input()


  if not game.paused then

    local eUpnum = #o.earlyUpdaters
    if eUpnum > 0 then
      for i = 1, eUpnum do
        o.earlyUpdaters[i]:early_update(dt)
      end
    end

    ps.pw:update(dt)

    local upnum = #o.updaters
    if upnum > 0 then
      for i = 1, upnum do
        o.updaters[i]:update(dt)
      end
    end

  else

    inv.manage(game.paused)
    if inp.current[game.paused.player].start == 1 and inp.previous[game.paused.player].start == 0 then
      game.pause(false)
    end

  end


  if o.to_be_deleted[1] then
    o.to_be_deleted:remove_all()
  end


  local playaTest = o.identified.PlayaTest
  if playaTest and playaTest[1].x then
    cam.xt = playaTest[1].x or 0
    cam.yt = playaTest[1].y + playaTest[1].zo or 0
  end

end


function love.draw()

  cam:setScale(sh.get_total_scale())
  cam:setPosition(cam.xt, cam.yt)

  cam:draw(function(l,t,w,h)

    local curcol = love.graphics.getColor()
    love.graphics.setColor(COLORCONST*0.6, COLORCONST*0.6, COLORCONST*0.6, COLORCONST)
    love.graphics.rectangle("fill", 0, 0, 800, 450)
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)

    local layers = #o.draw_layers
    if layers > 0 then
      for layer = 1, layers do
        local drawnum = #o.draw_layers[layer]
        for i = 1, drawnum do
          o.draw_layers[layer][i]:draw()
        end
      end
    end

  end)

  hud:setScale(sh.get_window_scale()*2)
  hud:setPosition(hud.xt, hud.yt)

  hud:draw(function(l,t,w,h)
    if im.sprites["GuyWalk"] then
      love.graphics.draw(im.sprites["GuyWalk"].img, 0, 0)
      if game.paused then
        local pr, pg, pb, pa = love.graphics.getColor()
        love.graphics.setColor(0, 0, 0, COLORCONST * 0.5)
        love.graphics.rectangle("fill", l, t, w, h)
        love.graphics.setColor(pr, pg, pb, pa)
        inv.draw()
      end
    end
  end)

  love.graphics.print(love.timer.getFPS())
  if fuck then love.graphics.print(fuck, 0, 13) end
  local debiter = 0
  if triggersdebug then
    for trigger, _ in pairs(triggersdebug) do
      debiter = debiter + 10
      love.graphics.print(trigger, 0, 20+debiter)
    end
  end

end


function love.mousepressed(x, y, button, isTouch)
  x, y = cam:toWorld(x, y)
  if button == 2 then
    o.removeFromWorld(o.updaters[2])
    return
  end
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
