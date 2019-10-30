local verh = require "version_handling"
-- Set up save directory
if not verh.fileExists("game_settings.lua") then
  local gsdcontents = love.filesystem.read("game_settings_defaults.lua")
  local newfile = love.filesystem.newFile("game_settings.lua")
  newfile:close()
  local success = love.filesystem.write("game_settings.lua", gsdcontents)
  if not success then love.errhand("Failed to write game_settings") end
end
local success = love.filesystem.createDirectory("Saves")
if not success then love.errhand("Failed to create save directory") end

-- game constants
GCON = {
  -- pieces of heart in world:
  -- 4 random
  maxPOHs = 4
}
-- Load stuff from save directory
local gs = require "game_settings"

local ps = require "physics_settings"
local o = require "GameObjects.objects"
local p = require "GameObjects.BoxTest"
local u = require "utilities"
local sh = require "scaling_handler"
local pam = require "pause_menu"
local inp = require "input"
local im = require "image"
local dtse = require "drawTimeScreenEffect"
local snd = require "sound"
local text = require "text"
local font = text.font
local dialogue = require "dialogue"
local game = require "game"
local inv = require "inventory"
local trans = require "transitions"
local gsh = require "gamera_shake"
local rm = require("Rooms.room_manager")
local ls = require "lightSources"

local gamera = require "gamera.gamera"

-- Create table to save temporary stuff for current session
session = {
  save = {
    playerMobility = nil,
    playerBrakes = nil,
    room = nil,
    playerX = nil,
    playerY = nil,
    walkOnWater = nil,
    swordShader = nil,
    missileShader = nil,
    markShader = nil,
    swordSpeed = nil
  },
  mslQueue = u.newQueue(),
  initialize = function()
    -- save
    session.save.time = session.save.time or 6
    session.save.days = session.save.days or 1
    session.save.rupees = session.save.rupees or 0
    session.save.piecesOfHeart = session.save.piecesOfHeart or 0
    session.save.armorLvl = session.save.armorLvl or 0
    session.save.swordLvl = session.save.swordLvl or 0
    session.save.magicLvl = session.save.magicLvl or 0
    session.save.athleticsLvl = session.save.athleticsLvl or 0
    session.save.playerMaxSpeed = session.save.playerMaxSpeed or 100
    session.save.tunicR = session.save.tunicR or 1
    session.save.tunicG = session.save.tunicG or 0.5
    session.save.tunicB = session.save.tunicB or 0.5
    session.save.swordR = session.save.swordR or 0.5
    session.save.swordG = session.save.swordG or 0.5
    session.save.swordB = session.save.swordB or 1
    session.save.missileR = session.save.missileR or 1
    session.save.missileG = session.save.missileG or 0.5
    session.save.missileB = session.save.missileB or 0.5
    session.save.markR = session.save.markR or 0.5
    session.save.markG = session.save.markG or 0.75
    session.save.markB = session.save.markB or 0.75
    -- session (depends on save, so do after save)
    session.clockAngleTarget = session.getClockAngleTarget()
    session.clockAngle = session.clockAngleTarget
    session.clockHandAngle = session.save.time
  end,
  updateTime = function(hoursPassed)
    session.save.time = session.save.time + hoursPassed

    -- assume that time only flows forward for now
    while session.save.time >= 24 do
      session.save.time = session.save.time - 24
      session.save.days = session.save.days + 1
    end
  end,
  maxMoney = function()
    if session.save.wallet == 1 then -- wallet
      return 200
    elseif session.save.wallet == 2 then -- magic wallet
      return 3000
    elseif session.save.wallet == 3 then -- wallet of holding
      return 9999
    else
      return 50
    end
  end,
  addMoney = function(addedMoney)
    local maxRupees = session.maxMoney()
    session.save.rupees = u.clamp(0, session.save.rupees + addedMoney, maxRupees)
  end,
  getClockAngleTarget = function()
    return (session.save.time > 6 and session.save.time < 18) and 0 or math.pi
  end,
  getArmorDamageReduction = function()
    -- return currentArmor / maxArmor
    if session.save.armorLvl == 1 then
      return 0.3333
    elseif session.save.armorLvl == 2 then
      return 0.6666
    elseif session.save.armorLvl == 3 then
      return 1
    else
      return 0
    end
  end,
  getSwordSpeed = function()
    return inv.sword.time - session.save.swordLvl * 0.05
  end,
  getMagicCooldown = function()
    -- 0.3 was default
    return 0.4 - session.save.magicLvl * 0.05
  end,
  getAthlectics = function()
    -- return mobility, brakes
    return 300 + session.save.athleticsLvl * 100, 6 + session.save.athleticsLvl
  end,
  getMaxSpeed = function()
    -- for now does nothing, but if I add temp speedBoosts will be useful
    return session.save.playerMaxSpeed
  end,
  startQuest = function(questid, startingStage)
    -- Only start quests that are not active or finished
    if session.save[questid] then return end
    table.insert(session.save.quests, questid)
    session.save[questid] = startingStage or "stage1"
  end,
  updateQuest = function(questid, newStage)
    if newStage then session.save[questid] = newStage end
  end,
  finishQuest = function(questid, result)
    -- Set resulting stage and remove from active quests table
    local index = u.getFirstIndexByValue(session.save.quests, questid)
    if not index then return end
    table.remove(session.save.quests, index)
    session.save[questid] = result or true
  end,
}
local session = session

-- Store mouse button info
mouseB = {}
local moub = mouseB
mouseP = {x = 0, y = 0}
local moup = mouseP

-- global sounds
glsounds = snd.load_sounds{
  wingFlap = {"Effects/Wing_flap"},
  pauseOpen = {"Effects/Oracle_PauseMenu_Open"},
  pauseClose = {"Effects/Oracle_PauseMenu_Close"},
  select = {"Effects/Oracle_Menu_Select"},
  deselect = {"Effects/Oracle_Menu_Cursor_low_pitch"},
  error = {"Effects/Oracle_Error"},
  letter = {"Effects/Oracle_Text_Letter"},
  textDone = {"Effects/Oracle_Text_Done"},
  cursor = {"Effects/Oracle_Menu_Cursor"},
  getHeart = {"Effects/Oracle_Get_Heart"},
  getRupee = {"Effects/Oracle_Get_Rupee"},
  getRupee5 = {"Effects/Oracle_Get_Rupee5"},
  getRupee20 = {"Effects/Oracle_Get_Rupee20"},
  fanfareItem = {"Effects/Oracle_Fanfare_Item"},
  open = {"Effects/Oracle_Chest"},
  heartContainer = {"Effects/Oracle_HeartContainer"},
  stairs = {"Effects/Oracle_Stairs"}
}

-- Set up cameras
mainCamera = gamera.new(0,0,800,450)
local cam = mainCamera
cam.xt = 0
cam.yt = 0
cam.noisel = 0
cam.noiset = 0

if gs.fullscreen then
  love.window.setFullscreen(true)
end

HudWidth = 400
HudHeight = 225
Hud = gamera.new(0,0,HudWidth,HudHeight)
local hud = Hud
hud.xt = 0
hud.yt = 0

local textCam = gamera.new(0,0,400,90)
textCam.xt = 0
textCam.yt = 0
textCam:setWindow(sh.get_resized_text_window( love.graphics.getWidth(), love.graphics.getHeight() ))
dialogue.textBox.l, dialogue.textBox.t, dialogue.textBox.w, dialogue.textBox.h =
  200,337.5,400,90


sh.calculate_total_scale{game_scale=1}

if not fuck then fuck = 0 end
-- love.keyboard.setTextInput(false)

-- Threshold before screen transitions are triggered
local screenEdgeThreshold = 0.1

-- rupee number outline
local rno = 0.6

function love.load()
  ps.pw:setCallbacks(beginContact, endContact, preSolve, postSolve)
  pam.init()
  -- dofile("Rooms/room1.lua")
  -- game.room = assert(love.filesystem.load("Rooms/room0.lua"))()

  -- Normal game
  game.room = assert(love.filesystem.load("Rooms/main_menu.lua"))()
  rm.build_room(game.room)
  snd.bgm:load(game.room.music_info)
  game.clockInactive = game.room.timeDoesntPass

  -- Room Creator
  -- game.room = assert(love.filesystem.load("Rooms/room_editor.lua"))()
  -- sh.calculate_total_scale{game_scale=game.room.game_scale}
end

function love.textinput(t)
  if string.len(text.input) > text.inputLim then return end
  text.input = text.input .. t
end

function love.keypressed(key, scancode)
  if key == "backspace" then
    text.input = u.utf8_backspace(text.input, 1)
  elseif key == "f11" then
    love.window.setFullscreen(not love.window.getFullscreen())
  end
  -- if key == "c" then collectgarbage(); fuck = collectgarbage("count") end
  text.key = scancode ~= "return" and scancode or text.key
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
      if aob.zo and bob.zo then
        apos = apos - aob.zo
        bpos = bpos - bob.zo
      end
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

function postSolve(a, b, coll)

    if a:getCategory() == SPRITECAT then return end

    -- Store the objects that collided
    local aob = a:getBody():getUserData()
    local bob = b:getBody():getUserData()

    if aob.postSolve then
      aob:postSolve(a, b, coll, aob, bob)
    end
    if bob.postSolve then
      bob:postSolve(a, b, coll, aob, bob)
    end
end

function love.update(dt)
	dt = math.min(0.03333333, dt)
  -- Store mouse input
  moub["1press"] = moub[1] and not moub["1prev"]
  moub["2press"] = moub[2] and not moub["2prev"]
  moub["1prev"] = moub[1]
  moub["2prev"] = moub[2]
  moup.x, moup.y = love.mouse.getX(), love.mouse.getY()

  -- Determine screen effect due to game time
  if game.timeScreenEffect then
    dtse.logic(game.timeScreenEffect, dt)
  end

  -- Calculate clock stuff
  if session.clockAngleTarget then
    session.clockAngleTarget = session.getClockAngleTarget()
    if session.clockAngle ~= session.clockAngleTarget then
      session.clockAngle = u.gradualAdjust(dt, session.clockAngle, session.clockAngleTarget)
    end
  end

  -- display mouse position
  -- local wmx, wmy = cam:toWorld(moup.x, moup.y)
  -- local wmrx, wmry = math.floor(wmx / 16) * 16, math.floor(wmy / 16) * 16
  -- fuck = tostring(wmrx) .. "/" .. tostring(wmry)

  if o.to_be_added[1] then
    o.to_be_added:add_all()
  end
  if o.to_be_deleted[1] and not game.transitioning then
    o.to_be_deleted:remove_all()
  end
  -- fuck = collectgarbage("count")

  -- Store player
  local playaTest = o.identified.PlayaTest

  if playaTest and playaTest[1].x then
    pl1 = playaTest[1]
  else
    pl1 = nil
  end

  inp.check_input()

  -- manage transition
  if game.transitioning then

    if not game.transitioning.startedTransition then

      if game.transitioning.type == "whiteScreen" then

        -- Don't draw a time screen effect over white screen
        game.timeScreenEffect = nil

        -- holster sword when changing rooms like this
        if pl1 and pl1.sword then
          o.removeFromWorld(pl1.sword)
          pl1.sword = nil
          pl1.spinCharged = nil
        end
      end
      trans.remove_from_world_previous_room()
      local prevWidth = game.room.width
      local prevHeight = game.room.height
      -- game.room = assert(love.filesystem.load(game.transitioning.roomTarget))()
      game.room = game.change_room(game.transitioning.roomTarget)
      mainCamera:setWorld(0, 0, game.room.width, game.room.height)
      rm.build_room(game.room)
      game.room.prevWidth = prevWidth
      game.room.prevHeight = prevHeight
      trans.caml, trans.camu, trans.camw, trans.camh = cam:getVisible()
      trans.determine_coordinates_transformation()

    elseif game.transitioning.progress < 1 then
      game.transitioning.progress = game.transitioning.progress + 1 * dt
      if game.transitioning.progress > 1 then game.transitioning.progress = 1 end
      trans.determine_coordinates_transformation()
    else

      o.to_be_deleted:remove_all()
      -- Store player
      local playaTest = o.identified.PlayaTest
      if playaTest and playaTest[1].x then
        pl1 = playaTest[1]
      else
        pl1 = nil
      end

      local room = game.room


      local playa = game.transitioning.playa
      if playa and playa.exists then
        if game.transitioning.type == "scrolling" then
          playa.body:setPosition(trans.player_target_coords(playa.x, playa.y))
        else -- White Screen
          playa.body:setPosition(game.transitioning.desx, game.transitioning.desy)
          -- Also set spritebody to avoid funkyness
          playa.spritebody:setPosition(game.transitioning.desx, game.transitioning.desy)
        end
        playa.body:setLinearVelocity(u.sign(playa.vx), u.sign(playa.vy))
        playa.zvel = 0
      end

      game.paused = false
      game.transitioning = false

      snd.bgm:load(newRoom.music_info)
      game.timeScreenEffect = room.timeScreenEffect
      game.clockInactive = room.timeDoesntPass

      for __, layer in ipairs(o.draw_layers) do
        for _, object in ipairs(layer) do
          -- turn off onPreviousRoom because the transition is over
          -- It needs to be false for the next trans to function correctly
          object.onPreviousRoom = false
        end
      end

      sh.calculate_total_scale{game_scale=room.game_scale}

    end

  end

  if not game.transitioning then
    -- Run unpausable_update methods
    -- (note they don't run on transitions so name is a bit misleading)
    local uUpnum = #o.unpausableUpdaters
    if uUpnum > 0 then
      for i = 1, uUpnum do
        o.unpausableUpdaters[i]:unpausable_update(dt)
      end
    end
  end

  if not game.paused then
    -- Make sure missiles don't exceed mslLim game setting
    if session.mslQueue.length > gs.mslLim then
      local removedMsl = session.mslQueue:remove()
      removedMsl.pastMslLim = true
    end

    -- Image indexes for background animations
    im.updateGlobalImageIndexes(dt)

    -- Update time
    if not game.room.timeDoesntPass then
      -- dt * 0.08333 = ocarina of time
      session.updateTime(dt * 0.08333)
      -- fuck = session.save.time
    end

    -- Run early_update methods
    local eUpnum = #o.earlyUpdaters
    if eUpnum > 0 then
      for i = 1, eUpnum do
        o.earlyUpdaters[i]:early_update(dt)
      end
    end

    -- update physical world
    ps.pw:update(dt)

    -- Run update methods
    local upnum = #o.updaters
    if upnum > 0 then
      for i = 1, upnum do
        o.updaters[i]:update(dt)
      end
    end

    -- Run late_update methods
    local lUpnum = #o.lateUpdaters
    if lUpnum > 0 then
      for i = 1, lUpnum do
        o.lateUpdaters[i]:late_update(dt)
      end
    end

  elseif not game.transitioning and not game.cutscene then -- not game.paused

    inv.manage(game.paused)
    if inp.current[game.paused.player].start == 1 and inp.previous[game.paused.player].start == 0 then
      game.pause(false)
      inv.closeInv()
    end
    pam.top_menu_logic()
    pam.left.logic()
  end

  -- Handle dialogues
  if dialogue.enable then dialogue.enabled = true; dialogue.enable = false end
  if dialogue.enabled then
    dialogue.currentMethod.logic(dt)

    if dialogue.currentChoice then
      dialogue.currentChoice.logic(dt)
    end
  end


  -- if o.to_be_deleted[1] and not game.transitioning then
  --   o.to_be_deleted:remove_all()
  -- end

  -- Check edge transitions
  if pl1 then

    if not game.transitioning then

      local playa = pl1
      local playax = playa.x
      local playay = playa.y
      local halfw = playa.width * 0.5
      local fullh = playa.height
      local l, t, w, h = cam:getWorld()
      local room = game.room

      cam.xt = playax or cam.xt
      cam.yt = playay + playa.fo or cam.yt

      -- check if a screen edge transition will happen
      -- left
      if playax - halfw < l - screenEdgeThreshold then
        if playa.vx < 0 then
          for _, transInfo in ipairs(room.leftTrans) do
            if playay > transInfo.yupper and playay < transInfo.ylower then

              game.transition{
                type = "scrolling",
                progress = 0,
                side = "left",
                playa = playa,
                xmod = transInfo.xmod,
                ymod = transInfo.ymod,
                roomTarget = transInfo.roomTarget
              }

              cam.xt = 0
              cam.yt = playay + playa.fo or cam.yt

            end
          end
        end
      -- right
      elseif playax + halfw > w + screenEdgeThreshold then
        if playa.vx > 0 then
          for _, transInfo in ipairs(room.rightTrans) do
            if playay > transInfo.yupper and playay < transInfo.ylower then

              game.transition{
                type = "scrolling",
                progress = 0,
                side = "right",
                playa = playa,
                xmod = transInfo.xmod,
                ymod = transInfo.ymod,
                roomTarget = transInfo.roomTarget
              }

              cam.xt = game.room.width
              cam.yt = playay + playa.fo or cam.yt

            end
          end
        end
      -- down
      elseif playay + fullh > h + screenEdgeThreshold then
        if playa.vy > 0 then
          for _, transInfo in ipairs(room.downTrans) do
            if playax > transInfo.xleftmost and playax < transInfo.xrightmost then

              game.transition{
                type = "scrolling",
                progress = 0,
                side = "down",
                playa = playa,
                xmod = transInfo.xmod,
                ymod = transInfo.ymod,
                roomTarget = transInfo.roomTarget
              }

            end
          end
        end
      -- up
      elseif playay - fullh < t - screenEdgeThreshold then
        if playa.vy < 0 then
          for _, transInfo in ipairs(room.upTrans) do
            if playax > transInfo.xleftmost and playax < transInfo.xrightmost then

              game.transition{
                type = "scrolling",
                progress = 0,
                side = "up",
                playa = playa,
                xmod = transInfo.xmod,
                ymod = transInfo.ymod,
                roomTarget = transInfo.roomTarget
              }

            end
          end
        end
      end

    else -- game.transitioning
      local camxtmod, camytmod = trans.camera_modification()
      cam.xt, cam.yt = cam.xt + camxtmod, cam.yt + camytmod
    end -- game.transitioning

  end

  -- Play sounds.
  snd.play_soundsToBePlayed()

  -- Update music
  snd.bgm:update(dt)

  -- Shake camera
  gsh.shake(cam, dt)

end


-- Functions to be used in love.draw
local function mainCameraDraw(l,t,w,h)

  -- local curcol = love.graphics.getColor()
  -- love.graphics.setColor(COLORCONST*0.6, COLORCONST*0.6, COLORCONST*0.6, COLORCONST)
  -- love.graphics.rectangle("fill", 0, 0, 800, 450)
  love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)

  local layers = #o.draw_layers
  if layers > 0 then

    -- Normal drawing mode
    if not game.transitioning or
    (game.transitioning and not game.transitioning.startedTransition) then

      for layer = 1, layers do
        local drawnum = #o.draw_layers[layer]
        for i = 1, drawnum do
          o.draw_layers[layer][i]:draw()
        end
      end

    -- Transition drawing mode
    elseif game.transitioning.type == "scrolling" then

      for layer = 1, layers do
        local drawnum = #o.draw_layers[layer]
        for i = 1, drawnum do
          o.draw_layers[layer][i]:trans_draw()
        end
      end

    else -- White screen

      -- for layer = 1, layers do
      --   local drawnum = #o.draw_layers[layer]
      --   for i = 1, drawnum do
      --     local obj = o.draw_layers[layer][i]
      --     if obj.onPreviousRoom then
      --       obj:draw()
      --     end
      --   end
      -- end
      love.graphics.setColor(COLORCONST*0.9, COLORCONST*0.9, COLORCONST*0.9, COLORCONST)
      -- love.graphics.rectangle("fill", 0, 0, 800, 450)
      local wl, lt = cam:toWorld(0, 0)
      local ww, wh = cam:toWorld(love.graphics.getWidth(), love.graphics.getHeight())
      love.graphics.rectangle("fill", wl, lt, ww-wl, wh-lt)
      love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)

    end

  end -- if layers > 0

end
local function hudDraw(l,t,w,h)
  local hpspr = im.sprites["health"]
  if hpspr then
    -- Draw as many filled hearts as player has health
    for i = 1, pl1.maxHealth do
      local healthFrame
      if pl1.health < i then
        if pl1.health <= i - 1 then
          healthFrame = hpspr[4]
        elseif pl1.health <= i - 0.75 then
          healthFrame = hpspr[3]
        elseif pl1.health <= i - 0.5 then
          healthFrame = hpspr[2]
        elseif pl1.health <= i - 0.25 then
          healthFrame = hpspr[1]
        end
      else
        healthFrame = hpspr[0]
      end
      love.graphics.draw(hpspr.img, healthFrame, i*16-8, 5, 0, hpspr.res_x_scale, hpspr.res_y_scale)
    end

    -- Draw rupees
    local maxMoney = session.maxMoney()
    local rupeeDigits = u.countIntDigits(maxMoney)
    local rupees = string.format("%0"..rupeeDigits.."d", (session.save.rupees or 0))
    local rspr = im.sprites["rupees"]
    love.graphics.draw(rspr.img, rspr[0], w-9, h-9,  0, rspr.res_x_scale, rspr.res_y_scale)
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, COLORCONST)
    local rupeeOffset = rupeeDigits * 6.1 + 10
    local rupeeYBase = h-7.5
    love.graphics.print(rupees, w - rupeeOffset + rno, rupeeYBase, 0, 0.255)
    love.graphics.print(rupees, w - rupeeOffset - rno, rupeeYBase, 0, 0.255)
    love.graphics.print(rupees, w - rupeeOffset, rupeeYBase + rno, 0, 0.255)
    love.graphics.print(rupees, w - rupeeOffset, rupeeYBase - rno, 0, 0.255)
    if maxMoney == session.save.rupees then
      love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST * 0.2, COLORCONST)
    else
      love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
    end
    love.graphics.print(rupees, w - rupeeOffset, rupeeYBase, 0, 0.255)

    -- Draw clock
    if game.clockInactive then
      love.graphics.setColor(COLORCONST, 0.3*COLORCONST, 0.3*COLORCONST, COLORCONST)
      love.graphics.setColor(0.3*COLORCONST, COLORCONST, COLORCONST, COLORCONST)
    else
      love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
    end
    local cspr = im.sprites["clock"]
    local clockX = w * 0.9 - ((rupeeDigits < 4) and 0 or 6.1)
    love.graphics.draw(cspr.img, cspr[0], clockX, h, session.clockAngle, cspr.res_x_scale, cspr.res_y_scale, cspr.cx, cspr.cy)
    local chspr = im.sprites["clockHand"]
    love.graphics.draw(chspr.img, chspr[session.clockAngleTarget == 0 and 0 or 1], clockX, h, -session.clockAngle + session.save.time * math.pi / 12, chspr.res_x_scale, chspr.res_y_scale, chspr.cx, chspr.cy)
    love.graphics.setColor(pr, pg, pb, pa)


    -- Draw pause menu
    if game.paused and not game.transitioning and not game.cutscene then
      -- local pr, pg, pb, pa = love.graphics.getColor()
      love.graphics.setColor(0, 0, 0, COLORCONST * 0.5)
      love.graphics.rectangle("fill", l, t, w, h)
      love.graphics.setColor(pr, pg, pb, pa)
      love.graphics.print("Day " .. session.save.days, w*0.05, h*0.1, 0, 0.5)
      inv.draw(l,t,w,h)
      pam.middle.draw(l,t,w,h)
      pam.left.draw(l, t, w, h)
      pam.top_menu_draw(l,t,w,h)
    end
  end
end
function love.draw()

  cam:setScale(sh.get_total_scale())
  -- local l, t, w, h = cam:getWindow()
  -- cam:setWindow(cam.noisel,cam.noiset,w,h)
  local l, t, w, h = sh.get_current_window()
  cam:setWindow(cam.noisel + l,cam.noiset + t,w,h)
  cam:setPosition(cam.xt, cam.yt)
  cam:draw(mainCameraDraw)

  -- Draw screen effect due to game time
  dtse.draw()

  hud:setScale(sh.get_window_scale()*2)
  hud:setPosition(hud.xt, hud.yt)

  if hud.visible and pl1 then
    hud:draw(hudDraw)
  end

  -- Print dialogues, signs, and generally, in-game text stuff
  if dialogue.enabled then
    textCam:setScale(sh.get_window_scale())

    dialogue.currentMethod.draw(textCam)

    if dialogue.currentChoice then
      dialogue.currentChoice.draw(cam:getWindow())
    end
  end

  love.graphics.print("FPS: " .. love.timer.getFPS(),love.graphics.getWidth()-200,love.graphics.getHeight()-77)
  if fuck then love.graphics.print(fuck, 0, 177+120) end
  local debiter = 0
  if triggersdebug then
    for trigger, _ in pairs(triggersdebug) do
      debiter = debiter + 24
      love.graphics.print(trigger, 0, 20+debiter+120)
    end
  end

  local nocamdnum = #o.noCamDrawables
  if nocamdnum > 0 then
    for i = 1, nocamdnum do
      o.noCamDrawables[i]:noCamDraw()
    end
  end

end


function love.mousepressed(x, y, button, isTouch)
  -- x, y = cam:toWorld(x, y)
  -- if button == 2 then
  --   o.removeFromWorld(o.updaters[2])
  --   return
  -- end
  -- u.push(o.to_be_added, p:new{xstart=x, ystart=y})
  moub[button] = true
end

function love.mousereleased(x, y, button, isTouch)
  moub[button] = false
end


function love.resize( w, h )

  -- Set camera display window size and offset
  cam:setWindow(sh.calculate_resized_window( w, h ))
  hud:setWindow(sh.get_resized_window( w, h ))
  textCam:setWindow(sh.get_resized_text_window( w, h ))

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
