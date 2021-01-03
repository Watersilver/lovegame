-- Setup canvases
local ringCanvas = love.graphics.newCanvas()
local drugCanvas = love.graphics.newCanvas()

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
  maxRandomPOHs = 4,
  maxPOHs = 4,
  -- Day and night music breaking points
  music = {
    daySilence = 6,
    dayMusic = 7.5,
    nightSilence = 19.5,
    nightMusic = 21,
    fadeToSilenceSpeed = 0.2
  },
  -- How many rooms to remember?
  rtr = 20,
  defaultScreenEdgeThreshold = 0.1,

  -- First spell message
  fsm = "You found your first spell! You \z
  can see all known spells and their \z
  key bindings in the pause menu. \z
  You can also swap spell key bindings in the pause menu.",

  -- Names n stuff
  money = "rupee",
  moneys = "rupees",
  heroWorld = "Hyrule",
  lakeVillage = "Kidwy",
  flowerVillage = "Anima",
  refugeeVillage = "Ancora",
  shidun = "Shidun",
  npcNames = {
    rescuer = "Tutela",
    mage = "Lethe",
    warrior = "Aite", -- Esmen
    oracle = "Farore" -- clementia
  }
}

-- global variables
gvar = {
  t = 0,
  -- Threshold before screen transitions are triggered
  screenEdgeThreshold = GCON.defaultScreenEdgeThreshold,
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
local shdrs = require "Shaders.shaders"
local dtse = require "drawTimeScreenEffect"
local snd = require "sound"
local text = require "text"
local font = text.font
local dialogue = require "dialogue"
local game = require "game"
local inv = require "inventory"
local trans = require "transitions"
local gsh = require "gamera_shake"
local rm = require("RoomBuilding.room_manager")
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
    -- Menu cursors
    pam.left.initCursors()
    -- Reload skin in case of skin change
    im.reloadPlSprites()
    -- Apply ring effects
    if session.save.equippedRing then
      require("items")[session.save.equippedRing].equip()
    end
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
    session.timescale = 1
    session.latestVisitedRooms = u.newQueue()
  end,
  updateTime = function(hoursPassed)
    local preUpdate = session.checkTimeOfDayForMusic()

    session.save.time = session.save.time + hoursPassed

    -- assume that time only flows forward for now
    while session.save.time >= 24 do
      session.save.time = session.save.time - 24
      session.save.days = session.save.days + 1
    end

    local postUpdate = session.checkTimeOfDayForMusic()
    if preUpdate ~= postUpdate then
      snd.bgmV2.getMusicAndload()
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
  getPohChance = function(dropValue)
    -- Chance of piece of heart as drop
    local rpoh = (session.save.randomPiecesOfHeart or 0)
    if dropValue == "cheapest" then
      return rpoh < 1 and 0.001 or 0
    elseif dropValue == "cheap" then
      return rpoh < 2 and 0.003 or 0
    elseif dropValue == "normal" then
      return rpoh < 4 and 0.005 or 0
    elseif dropValue == "rich" then
      return rpoh < GCON.maxRandomPOHs and 0.01 or 0
    else
      -- Custom chance, check only if there are any left here
      return rpoh < GCON.maxRandomPOHs and 1 or 0
    end
  end,
  getMagicCooldown = function()
    -- 0.3 was default
    return 0.4 - session.save.magicLvl * 0.05
  end,
  getAthlectics = function(getLvl)
    -- return mobility, brakes. Level starts from 0
    local lvl = getLvl or session.save.athleticsLvl
    return 300 + lvl * 100, 6 + lvl
  end,
  getMaxSpeed = function()
    -- maybe also add add temp speedBoosts
    local maxSpeed = session.save.playerMaxSpeed
    -- Modifier due to temp speedBoosts or penalties
    return maxSpeed
  end,
  journalEntryNotification = function()
    local Txtx = assert(love.filesystem.load("GameObjects/overlayText/newNote.lua"))()
    local txtx = Txtx:new()
    o.addToWorld(txtx)
    snd.play(glsounds.journalEntry)
  end,
  startQuest = function(questid, startingStage)
    -- Only start quests that are not active or finished
    if session.save[questid] then return end
    session.journalEntryNotification()
    table.insert(session.save.quests, questid)
    session.save[questid] = startingStage or "stage1"
    if session.save.gotFirstQuest then return end
    session.save.gotFirstQuest = true
    local cc = COLORCONST
    local ctable = {cc * 0.4,cc,cc * 0.6,cc}
    local myText = {
      {{ctable,"You've got your first note."},-1, "left"},
      {{ctable,"Pause and navigate to the journal tag to see it."},-1, "left"},
      {{ctable,"Consult the journal tag if you forget what you're supposed to be doing."},-1, "left"},
    }
    -- do the funcs
    local activateFuncs = {}
    local textsNum = #myText
    for i = 1,textsNum do
      activateFuncs[i] = function (self, dt, textIndex)
        self.typical_activate(self, dt, textIndex)
        self.next = i + 1
        if self.next > textsNum then self.next = "end" end
      end
    end
    local tutDlg = (require "GameObjects.GlobalNpcs.autoActivatedDlg"):new{
      pauseWhenTalkedTo = true,
      keepControllerDisabled = true,
      myText = myText,
      activateFuncs = activateFuncs
    }
    o.addToWorld(tutDlg)
  end,
  updateQuest = function(questid, newStage)
    if newStage then
      session.save[questid] = newStage
      session.journalEntryNotification()
    end
  end,
  finishQuest = function(questid, result)
    -- Set resulting stage and remove from active quests table
    local index = u.getFirstIndexByValue(session.save.quests, questid)
    if not index then return end
    table.remove(session.save.quests, index)
    session.save[questid] = result or true
  end,
  checkItemLim = function(itemid)
    return require("items")[itemid].limit
  end,
  addItem = function(itemid)
    if session.save[itemid] then
      session.save[itemid] = session.save[itemid] + 1
      -- Check if I reached carry limit
      local carryLim = session.checkItemLim(itemid) or 99
      if session.save[itemid] > carryLim then
        session.save[itemid] = carryLim
      end
    else
      session.save[itemid] = 1
      table.insert(session.save.items, itemid)
      table.sort(session.save.items,
        function(a, b)
          return a:upper() < b:upper()
        end
      )
    end
  end,
  removeItem = function(itemid)
    if not session.save[itemid] then return "don't have any" end
    session.save[itemid] = session.save[itemid] - 1
    if session.save[itemid] < 1 then
      session.save[itemid] = nil
      local index = u.getFirstIndexByValue(session.save.items, itemid)
      table.remove(session.save.items, index)
      return "ran out"
    end
  end,
  getMusic = function()
    local music_info = session.musicOverride or game.room.music_info
    if music_info and type(music_info) ~= "string" and music_info.day then
      -- if music_info.day exists, it means that the table
      -- has day & night info so choose appropriate here
      local todForMusic = session.checkTimeOfDayForMusic()
      if todForMusic then
        music_info = music_info[todForMusic]
      else
        music_info = {previousFadeOut = GCON.music.fadeToSilenceSpeed}
      end
    end
    return music_info
  end,
  checkTimeOfDayForMusic = function()
    local time = session.save.time
    if time > GCON.music.dayMusic and time < GCON.music.nightSilence then
      return "day"
    elseif time > GCON.music.nightMusic or time < GCON.music.daySilence then
      return "night"
    end
  end,
  setMusicOverride = function(override_info)
    -- Music that will persist when changing rooms and has to be nilified manually
    session.musicOverride = override_info
  end,
  toMainMenu = function()
    session.drug = nil
    session.ringShader = nil
    game.transition{
      type = "whiteScreen",
      progress = 0,
      roomTarget = "Rooms/main_menu.lua",
      purge = true
    }
  end,
  barrierBounce = function(plaObj, horDir, verDir)
    plaObj.body:setLinearVelocity(200 * horDir, 200 * verDir)
  end,
  saveGame = function()
    -- because Imma moron
    local saveKeysToBeIgnored = {
      hasSword = true, hasJump = true,
      hasMissile = true, hasMark = true,
      hasRecall = true, hasGrip = true,
      swordKey = true, jumpKey = true,
      missileKey = true, markKey = true,
      recallKey = true, gripKey = true,
      playerX = true, playerY = true,
      playerHealth = true
    }
    local saveContent = "local save = {}"
    local saveName = "Saves/" .. session.save.saveName .. ".lua"
    -- write save (except spell slots and coordinates)
    for key, value in pairs(session.save) do
      if not saveKeysToBeIgnored[key] then
        if type(value) == "string" then value = '"' .. value .. '"' end
        if type(value) == "boolean" then value = value and "true" or "false" end

        -- Quests are in a table in session.save. Get them out and save them with a prefix
        if key == "quests" then
          for qindex, questid in ipairs(value) do
            saveContent = saveContent .. "\nsave.__quest__" .. qindex .. ' = "' .. questid .. '"'
          end
        -- Items are in a table in session.save. Get them out and save them with a prefix
        elseif key == "items" then
          for iindex, itemid in ipairs(value) do
            saveContent = saveContent .. "\nsave.__item__" .. iindex .. ' = "' .. itemid .. '"'
          end
        else
        -- Just write the value
          saveContent = saveContent .. "\nsave." .. key .. " = " .. value
        end
      end
    end
    -- write coordinates and roomName
    saveContent = saveContent .. '\nsave.room = "' .. session.latestVisitedRooms[session.latestVisitedRooms.last] .. '"'
    if pl1 then
      saveContent = saveContent .. "\nsave.playerX = " .. pl1.x
      saveContent = saveContent .. "\nsave.playerY = " .. pl1.y
      -- write health
      saveContent = saveContent .. "\nsave.playerHealth = " .. pl1.health
    end
    -- write spel slots
    for i, slot in ipairs(inv.slots) do
      if slot.item then
        saveContent = saveContent .. "\nsave." .. "has" .. u.capitalise(slot.item.name) .. " = " .. '"' .. slot.item.name .. '"'
        saveContent = saveContent .. "\nsave." .. slot.item.name .. "Key = " .. '"' .. slot.key .. '"'
      end
    end
    saveContent = saveContent .. "\nreturn save"
    local success = love.filesystem.write(saveName, saveContent)
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
  secret = {"Effects/Oracle_Secret"},
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
  stairs = {"Effects/Oracle_Stairs"},
  useItem = {"Effects/Oracle_Get_Item"},
  portal = {"Effects/Oracle_Dungeon_Teleport"},
  bomb = {"Effects/Oracle_Bomb_Blow"},
  bombDrop = {"Effects/Oracle_Bomb_Drop"},
  magicDust = {"Effects/Oracle_MakuTree_Leaves"},
  appearVanish = {"Effects/Oracle_AppearVanish"},
  decoy = {"Effects/OOA_Veran_Shapeshift"},
  fire = {"Effects/Oracle_EmberSeed"},
  ice = {"Effects/Oracle_SwordShimmer"},
  stone = {"Effects/Oracle_Rumble2b"},
  plant = {"Effects/Oracle_ScentSeed_Shot"},
  wind = {"Effects/Oracle_GaleSeed"},
  blockFall = {"Effects/Oracle_Block_Fall"},
  enemyJump = {"Effects/Oracle_Enemy_Jump"},
  shieldDeflect = {"Effects/Oracle_Shield_Deflect"},
  journalEntry = {"Effects/journalEntry"},
  -- Harpsounds
  harpad = {"Effects/harp/ad"},
  harpadB = {"Effects/harp/adB"},
  harpbd = {"Effects/harp/bd"},
  harpbdB = {"Effects/harp/bdB"},
  harpcd = {"Effects/harp/cd"},
  harpdd = {"Effects/harp/dd"},
  harpddB = {"Effects/harp/ddB"},
  harped = {"Effects/harp/ed"},
  harpedB = {"Effects/harp/edB"},
  harpfd = {"Effects/harp/fd"},
  harpfdS = {"Effects/harp/fdS"},
  harpgd = {"Effects/harp/gd"},

  harpam = {"Effects/harp/am"},
  harpamB = {"Effects/harp/amB"},
  harpbm = {"Effects/harp/bm"},
  harpbmB = {"Effects/harp/bmB"},
  harpcm = {"Effects/harp/cm"},
  harpdm = {"Effects/harp/dm"},
  harpdmB = {"Effects/harp/dmB"},
  harpem = {"Effects/harp/em"},
  harpemB = {"Effects/harp/emB"},
  harpfm = {"Effects/harp/fm"},
  harpfmS = {"Effects/harp/fmS"},
  harpgm = {"Effects/harp/gm"},

  harpcu = {"Effects/harp/cu"},
  harpdu = {"Effects/harp/du"},
  harpduB = {"Effects/harp/duB"},
}

-- Set up cameras
camWidth = 800
camHeight = 450
mainCamera = gamera.new(0,0,camWidth,camHeight)
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

-- rupee number outline
local rno = 0.6

function love.load()
  ps.pw:setCallbacks(beginContact, endContact, preSolve, postSolve)
  pam.init()
  -- dofile("Rooms/room1.lua")
  -- game.room = assert(love.filesystem.load("Rooms/room0.lua"))()

  -- Normal game
  game.room = game.change_room("Rooms/main_menu.lua")
  rm.build_room(game.room)
  -- snd.bgm:load(game.room.music_info)
  snd.bgmV2.getMusicAndload()
  game.clockInactive = game.room.timeDoesntPass

  -- -- Room Creator
  -- game.room = assert(love.filesystem.load("RoomBuilding/room_editor.lua"))()
  -- sh.calculate_total_scale{game_scale=game.room.game_scale}
  -- session.initialize()
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
  local drugSlomo
  if session.drug then drugSlomo = session.drug.slomo end
  dt = dt * (drugSlomo or session.ringSlomo or 1)
  if pl1 and pl1.exists and pl1.timeFlow then
    dt = dt / pl1.timeFlow
  end

  -- update timers
  gvar.t = gvar.t + dt

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

  -- -- display mouse position
  -- local wmx, wmy = cam:toWorld(moup.x, moup.y)
  -- local wmrx, wmry = math.floor(wmx / 16) * 16 + 8, math.floor(wmy / 16) * 16 + 8
  -- fuck = tostring(wmrx) .. "/" .. tostring(wmry)
  --
  -- -- display room
  -- fuck = fuck .. "\n" .. session.latestVisitedRooms[session.latestVisitedRooms.last]

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

      inp.transing = false

      o.to_be_deleted:remove_all()

      local room = game.room

      local gts = game.transitioning.side
      local horside = gts == "left" and -1 or (gts == "right" and 1 or 0)
      local verside = gts == "up" and -1 or (gts == "down" and 1 or 0)


      -- Store player
      local playaTest = o.identified.PlayaTest
      if playaTest and playaTest[1].x then
        pl1 = playaTest[1]
        -- Die if fall in unsteppable after transition
        -- pl1.xLastSteppable = nil
        -- pl1.yLastSteppable = nil
        if gts then
          if pl1.yLastSteppable then
            pl1.yLastSteppable = pl1.yLastSteppable - verside * room.height
          end
          if pl1.yUnsteppable then
            pl1.yUnsteppable = pl1.yUnsteppable - verside * room.height
          end
          if pl1.xLastSteppable then
            pl1.xLastSteppable = pl1.xLastSteppable - horside * room.width
          end
          if pl1.xUnsteppable then
            pl1.xUnsteppable = pl1.xUnsteppable - horside * room.width
          end
        else
          pl1.xLastSteppable = nil
          pl1.yLastSteppable = nil
        end
        -- instance.xLastSteppable = instance.xUnsteppable
        -- instance.yLastSteppable = instance.yUnsteppable

      else
        pl1 = nil
      end


      local playa = game.transitioning.playa
      if playa and playa.exists then
        if game.transitioning.type == "scrolling" then
          playa.body:setPosition(trans.player_target_coords(playa.x, playa.y))
        else -- White Screen
          -- screenEdgeThreshold
          playa.body:setPosition(game.transitioning.desx, game.transitioning.desy)
          -- Also set spritebody to avoid funkyness
          playa.spritebody:setPosition(game.transitioning.desx, game.transitioning.desy)
        end
        -- reset player veolocity after transition if necessary
        -- playa.body:setLinearVelocity(u.sign(playa.vx), u.sign(playa.vy))
        local sd = game.transitioning.side
        local xsign, ysign
        if sd == "left" then xsign = -1
        elseif sd == "right" then xsign = 1
        elseif sd == "up" then ysign = -1
        elseif sd == "down" then ysign = 1 end
        local xtransvel = u.sign(xsign or playa.vx) * u.clamp(math.abs(horside * 10), math.abs(playa.vx * 0.25), 25)
        local ytransvel = u.sign(ysign or playa.vy) * u.clamp(math.abs(verside * 10), math.abs(playa.vy * 0.25), 25)
        playa.body:setLinearVelocity(xtransvel, ytransvel)
        playa.lastTransSide = sd
        -- playa.body:setLinearVelocity(playa.vx * 0.25, playa.vy * 0.25)
        playa.zvel = 0
      end

      game.paused = false
      game.transitioning = false

      -- snd.bgm:load(newRoom.music_info)
      snd.bgmV2.getMusicAndload()
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
      session.updateTime(dt * 0.08333 * session.timescale)
      -- fuck = session.save.time
    end
    game.clockInactive = game.room.timeDoesntPass

    -- Update drugs
    if session.drug then
      session.drug.duration = session.drug.duration - dt
      if session.drug.duration < 0 then session.drug = nil end
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
    if (inp.current[game.paused.player].start == 1 and inp.previous[game.paused.player].start == 0)
      or (not pam.quitting and inp.cancelPressed and not pam.left.selectedHeader)
      or session.forceCloseInv
    then
      session.forceCloseInv = false
      game.pause(false)
      inv.closeInv()
    end
    pam.left.logic()
    pam.top_menu_logic()
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
      local canTrans = (not playa.disableTransitions) and (not inp.shift)
      -- left
      if playax - halfw < l - gvar.screenEdgeThreshold then
        if (playa.vx < 0 or playa.noVelTrans) and canTrans then
          playa.noVelTrans = false
          local transed = false
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

              transed = true

            end
          end
          if transed then
            if playa.animation_state.state == "respawn" then playa.disableTransitions = true end
            inp.transing = true
          else
            session.barrierBounce(playa, 1, 0)
          end
        end
      -- right
      elseif playax + halfw > w + gvar.screenEdgeThreshold then
        if (playa.vx > 0 or playa.noVelTrans) and canTrans then
          playa.noVelTrans = false
          local transed = false
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

              transed = true

            end
          end
          if transed then
            if playa.animation_state.state == "respawn" then playa.disableTransitions = true end
            inp.transing = true
          else
            session.barrierBounce(playa, -1, 0)
          end
        end
      -- down
      elseif playay + fullh > h + gvar.screenEdgeThreshold then
        if (playa.vy > 0 or playa.noVelTrans) and canTrans then
          playa.noVelTrans = false
          local transed = false
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

              transed = true

            end
          end
          if transed then
            if playa.animation_state.state == "respawn" then playa.disableTransitions = true end
            inp.transing = true
          else
            session.barrierBounce(playa, 0, -1)
          end
        end
      -- up
      elseif playay - fullh < t - gvar.screenEdgeThreshold then
        if (playa.vy < 0 or playa.noVelTrans) and canTrans then
          playa.noVelTrans = false
          local transed = false
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

              transed = true

            end
          end
          if transed then
            if playa.animation_state.state == "respawn" then playa.disableTransitions = true end
            inp.transing = true
          else
            session.barrierBounce(playa, 0, 1)
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
  -- snd.bgm:update(dt)
  snd.bgmV2:update(dt)

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

    end

  end -- if layers > 0

end
local function afterScreenEffects(l,t,w,h)
  if not game.transitioning or
  (game.transitioning and not game.transitioning.startedTransition) then
    local onum = #o.overlays
    if onum > 0 then
      for i = 1, onum do
        o.overlays[i]:draw_overlay(cam)
      end
    end
  elseif game.transitioning.type == "whiteScreen" then
    -- Draw Whitescreen
    love.graphics.setColor(COLORCONST*0.9, COLORCONST*0.9, COLORCONST*0.9, COLORCONST)
    -- love.graphics.rectangle("fill", 0, 0, 800, 450)
    local wl, lt = cam:toWorld(0, 0)
    local ww, wh = cam:toWorld(love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.rectangle("fill", wl, lt, ww-wl, wh-lt)
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
  end
end
local function hudDraw(l,t,w,h)
  local transing = game.transitioning
  if pl1 and not (transing and transing.type == "whiteScreen") then
    local hpspr = im.sprites["health"]
    -- Draw as many filled hearts as player has health
    for i = 1, pl1.maxHealth do
      local healthFrame

      if pl1.health <= i - 1 then
        healthFrame = hpspr[4]
      elseif pl1.health <= i - 0.75 then
        healthFrame = hpspr[3]
      elseif pl1.health <= i - 0.5 then
        healthFrame = hpspr[2]
      elseif pl1.health <= i - 0.25 then
        healthFrame = hpspr[1]
      else
        healthFrame = hpspr[0]
      end

      love.graphics.draw(hpspr.img, healthFrame, i*16-8, 5, 0, hpspr.res_x_scale, hpspr.res_y_scale, hpspr.cx, hpspr.cy)

    end

    local pr, pg, pb, pa = love.graphics.getColor()

    -- Draw rupees
    local maxMoney = session.maxMoney()
    local rupeeDigits = u.countIntDigits(maxMoney)
    local rupees = string.format("%0"..rupeeDigits.."d", (session.save.rupees or 0))
    local rspr = im.sprites["rupees"]
    love.graphics.draw(rspr.img, rspr[0], w-9, h-9,  0, rspr.res_x_scale, rspr.res_y_scale)
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

    -- Draw bombs
    if session.save.hasBomb then
      love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
      local maxBombs = session.checkItemLim("mateBlastSeed")
      local bombs = string.format("%02d", (session.save.mateBlastSeed or 0))
      local bspr = im.sprites["Drops/blastSeed"]
      love.graphics.draw(bspr.img, bspr[0], 2, h-9,  0, bspr.res_x_scale, bspr.res_y_scale)
      love.graphics.setColor(0, 0, 0, COLORCONST)
      local bombOffset = 12
      local bombYBase = h-6.8
      love.graphics.print(bombs, bombOffset + rno, bombYBase, 0, 0.255)
      love.graphics.print(bombs, bombOffset - rno, bombYBase, 0, 0.255)
      love.graphics.print(bombs, bombOffset, bombYBase + rno, 0, 0.255)
      love.graphics.print(bombs, bombOffset, bombYBase - rno, 0, 0.255)
      if maxBombs == session.save.mateBlastSeed then
        love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST * 0.2, COLORCONST)
      else
        love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
      end
      love.graphics.print(bombs, bombOffset, bombYBase, 0, 0.255)
    end

    -- Draw magic dust
    if session.save.hasMystery then
      love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
      local maxDust = session.checkItemLim("mateMagicDust")
      local dust = string.format("%02d", (session.save.mateMagicDust or 0))
      local dupr = im.sprites["Drops/magicDust"]
      love.graphics.draw(dupr.img, dupr[0], 2, h-27,  0, dupr.res_x_scale, dupr.res_y_scale)
      love.graphics.setColor(0, 0, 0, COLORCONST)
      local dustOffset = 12
      local dustYBase = h-20.4
      love.graphics.print(dust, dustOffset + rno, dustYBase, 0, 0.255)
      love.graphics.print(dust, dustOffset - rno, dustYBase, 0, 0.255)
      love.graphics.print(dust, dustOffset, dustYBase + rno, 0, 0.255)
      love.graphics.print(dust, dustOffset, dustYBase - rno, 0, 0.255)
      if maxDust == session.save.mateMagicDust then
        love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST * 0.2, COLORCONST)
      else
        love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
      end
      love.graphics.print(dust, dustOffset, dustYBase, 0, 0.255)
    end

    love.graphics.setColor(pr, pg, pb, pa)


    -- Draw pause menu
    if game.paused and not transing and not game.cutscene then
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
  -- drug effects
  if session.drug and session.drug.shader then
    -- delete following lines and the resetting of canvas below to disable drug canvas
    love.graphics.setCanvas(drugCanvas)
    love.graphics.clear()

    cam:setScale(sh.get_total_scale())
    -- local l, t, w, h = cam:getWindow()
    -- cam:setWindow(cam.noisel,cam.noiset,w,h)
    local l, t, w, h = sh.get_current_window()
    cam:setWindow(cam.noisel + l,cam.noiset + t,w,h)
    cam:setPosition(cam.xt, cam.yt)
    cam:draw(mainCameraDraw)

    -- Draw screen effect due to game time
    dtse.draw()

    cam:draw(afterScreenEffects)

    -- delete following lines and the setting of canvas above to disable drug canvas
    love.graphics.setCanvas()

    -- delete following lines and the resetting of canvas below to disable ring canvas
    love.graphics.setCanvas(ringCanvas)
    love.graphics.clear()
    -- set drug shader
    session.drug.shader:send("invScale", 0.9 + 0.1*math.cos(session.drug.duration - session.drug.maxDuration))
    love.graphics.setShader(session.drug.shader)
    love.graphics.draw(drugCanvas)
    -- Disable drug shader
    love.graphics.setShader()
    love.graphics.setCanvas()

    -- set ring shader
    love.graphics.setShader(session.ringShader)
    love.graphics.draw(ringCanvas)
    -- Disable ring shader
    love.graphics.setShader()
  else
    -- normal effects
    -- delete following lines and the resetting of canvas below to disable drug canvas
    love.graphics.setCanvas(ringCanvas)
    love.graphics.clear()

    cam:setScale(sh.get_total_scale())
    -- local l, t, w, h = cam:getWindow()
    -- cam:setWindow(cam.noisel,cam.noiset,w,h)
    local l, t, w, h = sh.get_current_window()
    cam:setWindow(cam.noisel + l,cam.noiset + t,w,h)
    cam:setPosition(cam.xt, cam.yt)
    cam:draw(mainCameraDraw)

    -- Draw screen effect due to game time
    dtse.draw()

    cam:draw(afterScreenEffects)

    -- delete following lines and the setting of canvas above to disable drug canvas
    love.graphics.setCanvas()

    -- set ring shader
    love.graphics.setShader(session.ringShader)
    love.graphics.draw(ringCanvas)
    -- Disable ring shader
    love.graphics.setShader()
  end

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

  -- debug
  love.graphics.print("FPS: " .. love.timer.getFPS(),love.graphics.getWidth()-200,love.graphics.getHeight()-77)
  if currentEnemyName then love.graphics.print(currentEnemyName, 0, love.graphics.getHeight()-77) end
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

-- Get enemy list
-- Avoid enemies that crash if they don't have a creator
local avoid = {
  ["shooterTemplate.lua"] = true,
  ["blueHand.lua"] = true,
  ["redHand.lua"] = true,
  ["robe.lua"] = true,
  ["leever.lua"] = true,
  ["zora.lua"] = true,
  -- ["swarm.lua"] = true,
}
local enemyPaths = {}
local enemiesSubfolders = {}
local enemiesPath = "/GameObjects/enemies/"
local enemyNames = love.filesystem.getDirectoryItems(enemiesPath)
for _, name in ipairs(enemyNames) do
  if not avoid[name] then
    if string.sub(name, -4) == ".lua" then
      table.insert(enemyPaths, enemiesPath .. name)
    else
      table.insert(enemiesSubfolders, enemiesPath .. name .. "/")
    end
  end
end
for _, path in ipairs(enemiesSubfolders) do
  local names = love.filesystem.getDirectoryItems(path)
  for _, name in ipairs(names) do
    if not avoid[name] then table.insert(enemyPaths, path .. name) end
  end
end
local cursor
local startingCursor = 1
for i, path in ipairs(enemyPaths) do
  if "/GameObjects/enemies/shooters/redRockBug.lua" == path then
    startingCursor = i
  end
end
function love.mousepressed(x, y, button, isTouch)
  -- x, y = cam:toWorld(x, y)
  -- if button == 2 then
  --   o.removeFromWorld(o.updaters[2])
  --   return
  -- end
  -- u.push(o.to_be_added, p:new{xstart=x, ystart=y})

  -- if button == 2 then
  --   if cursor then
  --     cursor = cursor + 1
  --   else
  --     cursor = startingCursor
  --   end
  --   if cursor > #enemyPaths then
  --     cursor = 1
  --   end
  --   currentEnemyName = enemyPaths[cursor]
  -- else
  --   if currentEnemyName then
  --     local enemClass = assert(love.filesystem.load(currentEnemyName))()
  --     local enem = enemClass:new()
  --     local wx, wy = cam:toWorld(x, y)
  --     enem.x, enem.y = wx, wy
  --     enem.xstart, enem.ystart = enem.x, enem.y
  --     o.addToWorld(enem)
  --   else
  --     -- -- local enemClass = assert(love.filesystem.load("/GameObjects/DialogueBubble/DialogueControl.lua"))()
  --     -- local enemClass = assert(love.filesystem.load("/GameObjects/npcTest3.lua"))()
  --     -- local enem = enemClass:new()
  --     -- local wx, wy = cam:toWorld(x, y)
  --     -- enem.x, enem.y = wx, wy
  --     -- enem.xstart, enem.ystart = enem.x, enem.y
  --     -- o.addToWorld(enem)
  --   end
  -- end

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

  -- Reset Canvases
  ringCanvas = love.graphics.newCanvas(w, h)
  drugCanvas = love.graphics.newCanvas(w, h)

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
