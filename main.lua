delta_time = 0

local verh = require "version_handling"

local function saveGameSettings()
  local game_settings = require 'game_settings'
  -- Overwrite game_settings file
  local success = love.filesystem.write("game_settings.lua", "local gs = {}\n")
  ---@diagnostic disable-next-line: undefined-field
  if not success then love.errorhandler("Failed to write game_settings first line") end
  local game_settings_body = ""
  for setting, value in pairs(game_settings) do
    -- Update already loaded table
    game_settings[setting] = value
    if type(value) == "string" then value = "\'" .. value .. "\'"
    elseif type(value) == "boolean" then
      if value then value = "true" else value = "false" end
    end
    game_settings_body = game_settings_body .. "gs." .. setting .. " = " .. value .. "\n"
  end
  success = love.filesystem.append("game_settings.lua", game_settings_body .. "return gs\n")
  if not success then love.errorhandler("Failed to write game_settings body") end
end

-- Set up save directory
if not verh.fileExists("game_settings.lua") then
  local gsdcontents = love.filesystem.read("game_settings_defaults.lua")
  local newfile = love.filesystem.newFile("game_settings.lua")
  newfile:close()
  local success = love.filesystem.write("game_settings.lua", gsdcontents)
---@diagnostic disable-next-line: undefined-field
  if not success then love.errorhandler("Failed to write game_settings") end
else
  -- Fill empty defaults
  local game_settings = require 'game_settings'
  local gsd = require 'game_settings_defaults'
  for setting, value in pairs(gsd) do
    if game_settings[setting] == nil then
      game_settings[setting] = value
    end
  end
  saveGameSettings()
end
local success = love.filesystem.createDirectory("Saves")
---@diagnostic disable-next-line: undefined-field
if not success then love.errorhandler("Failed to create save directory") end

-- game constants
GCON = {
  maxRandomPOHs = 4, -- Random drop pieces of heart
  maxPOHs = 84, -- Number of existing pieces of heart in world
  -- Day and night music time(in 24 hour clock) breaking points
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
  money = "lek",
  moneys = "lekë",
  heroWorld = "Tollaw",
  lakeVillage = "Kidwy",
  flowerVillage = "Anima",
  refugeeVillage = "Ancora",
  shidun = "Shidun",
  ---@param options? {capitalize?: boolean;}
  lostWoods = function(options)
    if options then
      if options.capitalize then
        return "The red forest"
      end
    end
    return "the red forest"
  end,
  npcNames = {
    rescuer = "Tutela",
    mage = "Lethe",
    warrior = "Aite", -- Esmen
    oracle = "Clementia" -- clementia
  },

  -- Contains magic dust method/type/other ids and tables thereof (uses empty tables as ids)
  md = {
    -- Magic dust reaction method ids
    reaction = {
      fire = {}, -- A flame that burns what it touches
      wind = {}, -- A small tornado that blows things away
      ice = {}, -- Freezes stuff solid
      stone = {}, -- Turns stuff to stone
      plant = {}, -- Turns stuff to plants
      bomb = {}, -- Turns stuff to bombs
      heart = {}, -- Conjures heart
      fairy = {}, -- Conjures fairy
      block = {}, -- Conjures block
      boom = {}, -- Blows up
      kaboom = {}, -- Chain reaction of expolosions
      decoy = {}, -- Creates a decoy, making user invisible
      disappear = {}, -- Makes target disappear
      nothing = {}, -- Nothing happens
    },

    choose = {}, -- Choice function. Returns reaction id. All reactives must have one.
    focus = {}, -- Special reaction to focus for when default focus id does not suffice
    cascade = {}, -- Determine if chosen reaction will cascade to targetless if target doesn't react with it.
  },

  MAX_DT = 0.03333333,
  MAX_PHYSICS_DT = 0.03333333,
}

-- global variables
gvar = {
  t = 0,
  -- Threshold before screen transitions are triggered
  screenEdgeThreshold = GCON.defaultScreenEdgeThreshold,
}

-- Global Parameters
GPAR = {
  walk_anim_speed_factor = 0.13,
  walk_anim_max_speed = 0.29,
  default_dlg_letter_delay = 0.01,
  dlg_scroll_speed_factor = 50
}

-- Debug
Debug = {
  cursor = 2,
  bodiesRenderMode = 0,
  freeze_screen = false
}

-- Load stuff from save directory
local gs = require "game_settings"

require "async"

local ps = require "physics_settings"
local o = require "GameObjects.objects"
-- local p = require "GameObjects.BoxTest"
local u = require "utilities"
local sh = require "scaling_handler"
local pam = require "pause_menu"
local inp = require "input"
local im = require "image"
local snd = require "sound"
local text = require "text"
local dialogue = require "dialogue"
local game = require "game"
local inv = require "inventory"
local trans = require "transitions"
local gsh = require "gamera_shake"
local rm = require("RoomBuilding.room_manager")

local gamera = require "gamera.gamera"

local imports = {
  particles = require "GameObjects.misc.particles",
  screenEffects = require "screenEffects",
  lighting = require "ScreenEffects.lighting.lighting",
  healthDisplay = require "HUD.health",
  shdrs = require 'Shaders.shaders'
}

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
    swordSpeed = nil,
    bombs = 0,
    maxBombs = 1,
    bombsCooldown = 0,
    dust = 0,
    maxDust = 1,
    dustCooldown = 0
  },
  mslQueue = u.newQueue(),
  initialize = function()
    require("GameObjects.weather"):create()

    inv.initialize()
    -- Menu cursors
    pam.left.initCursors()
    -- Reload skin in case of skin change
    im.reloadPlSprites()
    -- Apply ring effects
    if session.save.equippedRing then
      require("items")[session.save.equippedRing].equip()
    end
    -- save
    session.save.bombs = session.save.bombs or 0
    session.save.maxBombs = session.save.maxBombs or 1
    session.save.bombsCooldown = session.save.bombsCooldown or 0
    session.save.dust = session.save.dust or 0
    session.save.maxDust = session.save.maxDust or 1
    session.save.dustCooldown = session.save.dustCooldown or 0
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
    session.latestVisitedRooms = u.newQueue(GCON.rtr)
    session.deadEnemies = u.newFastAccessQueue(20)
    session.delta_hours = 0
    session.sleeping_danger = false
    session.prevRupees = session.save.rupees

    -- add global objects
    session.particles = imports.particles:new()
    o.addToWorld(session.particles)

  end,
  toMainMenu = function()
    session.drug = nil
    session.ringShader = nil
    session.sleeping_danger = false

    -- remove/clean global objects
    if session.particles and session.particles.exists then
      o.removeFromWorld(session.particles)
    end
    session.particles = nil

    game.transition{
      type = "whiteScreen",
      progress = 0,
      roomTarget = "Rooms/main_menu.lua",
      purge = true
    }
  end,
  ---@param obj table
  ---@param to number
  ---@param from? number
  -- Transitions a value from 'from' to 'to' if object comes from
  -- the next room or the opposite if it was on the previous room
  transitionValue = function(obj, to, from)
    if obj.onPreviousRoom then
      return 0.5 * (1 - game.transitioning.progress)
    else
      return 0.5 * game.transitioning.progress
    end
  end,
  updateTime = function(hoursPassed)

    session.delta_hours = hoursPassed

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
  ---@return "full" | "half" | "new"
  getMoonPhase = function()
    local adjustment = session.save.time < 12 and -1 or 0

    --     v V v
    -- 4 5 6 7 1 2 3
    local cyclePosition = math.floor(session.save.days + 6 + adjustment) % 7
    if (cyclePosition == 6) then return "full" end
    if (cyclePosition == 5 or cyclePosition == 0) then return "half" end
    return "new"
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
    session.prevRupees = session.save.rupees
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
    -- TODO: Spray and pray ring that makes this 0.1
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
  canMarkPersist = function()
    if game.room.blockTeleport then return false end

    -- Check if from or to cursed forest
    if not session.save.forestCurseLifted then
      if session.latestVisitedRooms:getLast():find("cursedForest") then return false end

      -- If in forest fake exit / secret truth lie path, cannot mark or recall
      if game.lastSide == "up" and session.latestVisitedRooms:getLast():find("Rooms/w096x102.lua") then
        return false
      end
    end

    return true
  end,
  canRecallOtherRoom = function()
    return session.canMarkPersist()
  end,
  journalEntryNotification = function()
    -- local Txtx = assert(love.filesystem.load("GameObjects/overlayText/newNote.lua"))()
    local Txtx = require "GameObjects.overlayText.overplayer"
    Txtx.createNew("Journal entry added")
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
    local ctable = {0.4,1,0.6,1}
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
    local lim = require("items")[itemid].limit
    if type(lim) == "function" then lim = lim() end
    return lim
  end,
  hasItem = function(itemid)
    return type(session.save[itemid]) == "number"
  end,

  -- If no focus is specified return true if any focus is equipped,
  -- else return true if the particular focus given is equipped.
  ---@param focus? string
  hasFocusEquipped = function(focus)
    if session.save.focus and not session.hasItem(session.save.focus) then
      session.save.focus = nil
      return false
    end

    if type(focus) ~= "string" then
      return session.save.focus ~= nil
    end

    return session.save.focus == focus
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
  -- Removes specified amount of items or fails if there are not enough items.
  -- If amount is decimal it gets floored.
  removeItems = function(itemid, amount)
    if not session.save[itemid] then return false end
    amount = math.floor(amount)
    if session.save[itemid] > amount then
      session.save[itemid] = session.save[itemid] - amount
      return true
    end
    if session.save[itemid] == amount then
      session.save[itemid] = nil
      local index = u.getFirstIndexByValue(session.save.items, itemid)
      table.remove(session.save.items, index)
      return true
    end
    return false
  end,
  removeItem = function(itemid)
    if not session.save[itemid] then return -1 end
    session.save[itemid] = session.save[itemid] - 1
    if session.save[itemid] < 1 then
      session.save[itemid] = nil
      local index = u.getFirstIndexByValue(session.save.items, itemid)
      table.remove(session.save.items, index)
    end
    return session.save[itemid] or 0
  end,
  ---@param music MusicInfo
  setRoomMusic = function(music)
    game.room.music_info = music
    snd.bgmV2.getMusicAndload()
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
  barrierBounce = function(plaObj, horDir, verDir)
    plaObj.body:setLinearVelocity(200 * horDir, 200 * verDir)
  end,
  ---@param n number
  addBombs = function(n)
    session.save.bombs = session.save.bombs + n
    if session.save.bombs > session.save.maxBombs then
      session.save.bombs = session.save.maxBombs
    elseif session.save.bombs < 0 then
      session.save.bombs = 0
    end
  end,
  ---@param n number
  addDust = function(n)
    session.save.dust = session.save.dust + n
    if session.save.dust > session.save.maxDust then
      session.save.dust = session.save.maxDust
    elseif session.save.dust < 0 then
      session.save.dust = 0
    end
  end,
  saveGame = function()
    saveGameSettings()
    -- local game_settings = require 'game_settings'
    -- -- Overwrite game_settings file
    -- success = love.filesystem.write("game_settings.lua", "local gs = {}\n")
    -- ---@diagnostic disable-next-line: undefined-field
    -- if not success then love.errorhandler("Failed to write game_settings first line") end
    -- local game_settings_body = ""
    -- for setting, value in pairs(game_settings) do
    --   -- Update already loaded table
    --   gs[setting] = value
    --   if type(value) == "string" then value = "\'" .. value .. "\'"
    --   elseif type(value) == "boolean" then
    --     if value then value = "true" else value = "false" end
    --   end
    --   game_settings_body = game_settings_body .. "gs." .. setting .. " = " .. value .. "\n"
    -- end
    -- success = love.filesystem.append("game_settings.lua", game_settings_body .. "return gs\n")
    -- if not success then love.errorhandler("Failed to write game_settings body") end

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
        if key == "quests" and type(value) == "table" then
          for qindex, questid in ipairs(value) do
            saveContent = saveContent .. "\nsave.__quest__" .. qindex .. ' = "' .. questid .. '"'
          end
        -- Items are in a table in session.save. Get them out and save them with a prefix
        elseif key == "items" and type(value) == "table" then
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
    saveContent = saveContent .. '\nsave.room = "' .. session.latestVisitedRooms:getLast() .. '"'
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
    success = love.filesystem.write(saveName, saveContent)
  end,
  placeEnemies = function (room, enemiesList)
    -- room name and enemiesList index can be
    -- used to uniquely identify enemy.
    -- This can only be done if a) this runs immediatelly after
    -- the manuallyPlacedObjects of the room has been created (if it exists)
    -- and BEFORE any conditionally manually placed objects.

    room.manuallyPlacedObjects = room.manuallyPlacedObjects or {}

    for enemyIndex, enemyInfo in ipairs(enemiesList) do
      -- Determine enemy id
      local enemyId = (session.latestVisitedRooms:getLast() or "") .. enemyIndex

      if not session.deadEnemies:has(enemyId) then
        enemyInfo.n = enemyInfo.n or {}
        enemyInfo.n.enemyId = enemyId

        -- Determine x, y if given area or areas
        if enemyInfo.spawnArea then
          enemyInfo.x, enemyInfo.y = u.randomPointFromTriangulatedPolygon(enemyInfo.spawnArea)
        elseif enemyInfo.spawnAreas then
          local area = u.chooseFromChanceTable(enemyInfo.spawnAreas)
          enemyInfo.x, enemyInfo.y = u.randomPointFromTriangulatedPolygon(area)
        end

        table.insert(room.manuallyPlacedObjects, enemyInfo)
      end
    end

  end,

  ---@param id string
  setInstanceId = function(instance, id)
    instance.ids[#instance.ids+1] = id
  end,

}
local session = session

-- Store mouse button info
mouseB = {}
local moub = mouseB
mouseP = {x = 0, y = 0}
local moup = mouseP

---@param button number
local function createMouseButton(button)

  local function getNormalPos()
    local x, y = love.mouse.getPosition()
    local realW, realH = sh.fit_in_aspect_ratio(love.graphics.getWidth(), love.graphics.getHeight())
    local deadW, deadH = sh.get_deadspace(love.graphics.getWidth(), love.graphics.getHeight())

    local clickX = x - deadW
    local clickY = y - deadH

    local normalX = -1
    local normalY = -1

    if not (clickX < 0 or clickX > realW) then
      normalX = clickX / realW
    end
    if not (clickY < 0 or clickY > realH) then
      normalY = clickY / realH
    end

    return normalX, normalY
  end

  local pressed = false
  local released = false
  local down = false
  local downPrev = false
  local normPressedX = -1
  local normPressedY = -1

  ---@class MouseButton
  local mb = {
    getPosition = function() return love.mouse.getPosition() end,
    getNormalViewportPos = function() return getNormalPos() end,
    getPressed = function() return pressed end,
    getReleased = function() return released end,
    getLastClickNormalViewportPos = function() return normPressedX, normPressedY end
  }
  mb.update = function()
    downPrev = down
    down = love.mouse.isDown(button)

    pressed = down and not downPrev
    released = not down and downPrev

    if pressed then
      normPressedX, normPressedY = getNormalPos()
    end
  end
  return mb
end

Pointer = {
  left = createMouseButton(1),
  right = createMouseButton(2)
}

-- global sounds
---@class GlobalSFX
glsounds = {
  footsteps = {
    dirtrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_07", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_09", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_DirtyGround_Run/Footsteps_DirtyGround_Run_10", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_01"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_02"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_03"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_04"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_05"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_06"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_07"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_08"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_09"},
      snd.load_sound{"Effects/Footsteps_DirtyGround_Run_10"},
    },
    rockrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_07", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_09", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Rock_Run/Footsteps_Rock_Run_10", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_Rock_Run_01"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_02"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_03"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_04"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_05"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_06"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_07"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_08"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_09"},
      snd.load_sound{"Effects/Footsteps_Rock_Run_10"},
    },
    grassrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_07", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_09", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_10", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_11", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_12", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_13", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_14", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Run/Footsteps_Grass_Run_15", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_Grass_Run_01"},
      snd.load_sound{"Effects/Footsteps_Grass_Run_02"},
      snd.load_sound{"Effects/Footsteps_Grass_Run_03"},
      snd.load_sound{"Effects/Footsteps_Grass_Run_04"},
      snd.load_sound{"Effects/Footsteps_Grass_Run_05"},
      snd.load_sound{"Effects/Footsteps_Grass_Run_06"},
      snd.load_sound{"Effects/Footsteps_Grass_Run_07"},
      -- snd.load_sound{"Effects/Footsteps_Grass_Run_08"},
      snd.load_sound{"Effects/Footsteps_Grass_Run_09"},
      -- snd.load_sound{"Effects/Footsteps_Grass_Run_10"},
      -- snd.load_sound{"Effects/Footsteps_Grass_Run_11"},
      snd.load_sound{"Effects/Footsteps_Grass_Run_12"},
      -- snd.load_sound{"Effects/Footsteps_Grass_Run_13"},
      -- snd.load_sound{"Effects/Footsteps_Grass_Run_14"},
      -- snd.load_sound{"Effects/Footsteps_Grass_Run_15"},
    },
    grasswalk = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_01", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_02", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_03", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_04", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_05", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_06", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_07", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_08", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_09", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_10", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_11", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_12", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_13", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_14", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_15", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_16", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_17", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_18", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_19", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_20", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_21", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_22", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_23", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_24", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_25", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_26", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_27", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_28", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_29", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_30", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_31", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_32", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_33", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_34", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_35", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_36", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_37", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_38", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_39", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_40", extension = ".wav"},
      -- -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_41", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_42", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_43", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_44", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_45", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_46", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_47", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_48", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_49", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_50", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_01"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_02"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_03"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_04"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_05"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_06"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_07"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_08"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_09"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_10"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_11"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_12"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_13"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_14"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_15"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_16"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_17"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_18"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_19"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_20"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_21"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_22"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_23"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_24"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_25"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_26"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_27"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_28"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_29"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_30"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_31"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_32"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_33"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_34"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_35"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_36"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_37"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_38"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_39"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_40"},
      -- snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_41"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_42"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_43"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_44"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_45"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_46"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_47"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_48"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_49"},
      snd.load_sound{"Effects/Footsteps_Walk_Grass_Mono_50"},
    },
    gravelrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_07", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_09", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Gravel_Run/Footsteps_Gravel_Run_10", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_Gravel_Run_01"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_02"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_03"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_04"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_05"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_06"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_07"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_08"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_09"},
      snd.load_sound{"Effects/Footsteps_Gravel_Run_10"},
    },
    woodrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_07", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_09", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Wood_Run/Footsteps_Wood_Run_10", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_Wood_Run_01"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_02"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_03"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_04"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_05"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_06"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_07"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_08"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_09"},
      snd.load_sound{"Effects/Footsteps_Wood_Run_10"},
    },
    tilerun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Tile_Run/Footsteps_Tile_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Tile_Run/Footsteps_Tile_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Tile_Run/Footsteps_Tile_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Tile_Run/Footsteps_Tile_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Tile_Run/Footsteps_Tile_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Tile_Run/Footsteps_Tile_Run_06", extension = ".wav"},
      snd.load_sound{"Effects/Footsteps_Tile_Run_01"},
      snd.load_sound{"Effects/Footsteps_Tile_Run_02"},
      snd.load_sound{"Effects/Footsteps_Tile_Run_03"},
      snd.load_sound{"Effects/Footsteps_Tile_Run_04"},
      snd.load_sound{"Effects/Footsteps_Tile_Run_05"},
      snd.load_sound{"Effects/Footsteps_Tile_Run_06"},
    },
    -- leavesrun = {
    --   snd.load_sound{"Effects/footsteps/Footsteps_Leaves_Run/Footsteps_Leaves_Run_01", extension = ".wav"},
    --   snd.load_sound{"Effects/footsteps/Footsteps_Leaves_Run/Footsteps_Leaves_Run_02", extension = ".wav"},
    --   snd.load_sound{"Effects/footsteps/Footsteps_Leaves_Run/Footsteps_Leaves_Run_03", extension = ".wav"},
    --   snd.load_sound{"Effects/footsteps/Footsteps_Leaves_Run/Footsteps_Leaves_Run_04", extension = ".wav"},
    --   snd.load_sound{"Effects/footsteps/Footsteps_Leaves_Run/Footsteps_Leaves_Run_05", extension = ".wav"},
    --   snd.load_sound{"Effects/footsteps/Footsteps_Leaves_Run/Footsteps_Leaves_Run_06", extension = ".wav"},

    --   snd.load_sound{"Effects/Footsteps_Leaves_Run_01"},
    --   snd.load_sound{"Effects/Footsteps_Leaves_Run_02"},
    --   snd.load_sound{"Effects/Footsteps_Leaves_Run_03"},
    --   snd.load_sound{"Effects/Footsteps_Leaves_Run_04"},
    --   snd.load_sound{"Effects/Footsteps_Leaves_Run_05"},
    --   snd.load_sound{"Effects/Footsteps_Leaves_Run_06"},
    -- },
    mudrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Mud_Run/Footsteps_Mud_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Mud_Run/Footsteps_Mud_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Mud_Run/Footsteps_Mud_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Mud_Run/Footsteps_Mud_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Mud_Run/Footsteps_Mud_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Mud_Run/Footsteps_Mud_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Mud_Run/Footsteps_Mud_Run_07", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_Mud_Run_01"},
      snd.load_sound{"Effects/Footsteps_Mud_Run_02"},
      snd.load_sound{"Effects/Footsteps_Mud_Run_03"},
      snd.load_sound{"Effects/Footsteps_Mud_Run_04"},
      snd.load_sound{"Effects/Footsteps_Mud_Run_05"},
      snd.load_sound{"Effects/Footsteps_Mud_Run_06"},
      snd.load_sound{"Effects/Footsteps_Mud_Run_07"},
    },
    waterwalk = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_07", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_09", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_10", extension = ".wav"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_01"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_02"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_03"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_04"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_05"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_06"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_07"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_08"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_09"},
      snd.load_sound{"Effects/Footsteps_WaterV1_Walk_10"},
    },
    waterjumplight = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Jump/Footsteps_Water_Jump_Light_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Jump/Footsteps_Water_Jump_Light_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Jump/Footsteps_Water_Jump_Light_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Jump/Footsteps_Water_Jump_Light_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Jump/Footsteps_Water_Jump_Light_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Water_Jump/Footsteps_Water_Jump_Light_06", extension = ".wav"},
      snd.load_sound{"Effects/Footsteps_Water_Jump_Light_01"},
      snd.load_sound{"Effects/Footsteps_Water_Jump_Light_02"},
      snd.load_sound{"Effects/Footsteps_Water_Jump_Light_03"},
      snd.load_sound{"Effects/Footsteps_Water_Jump_Light_04"},
      snd.load_sound{"Effects/Footsteps_Water_Jump_Light_05"},
      snd.load_sound{"Effects/Footsteps_Water_Jump_Light_06"},
    },
    snowsoftrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_07", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_09", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Run_10", extension = ".wav"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_01"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_02"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_03"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_04"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_05"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_06"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_07"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_08"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_09"},
      snd.load_sound{"Effects/Footsteps_Snow_Run_10"},
    },
    snowhardrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_07", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_09", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Snow_Run/Footsteps_Snow_Hard_Run_10", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_01"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_02"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_03"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_04"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_05"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_06"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_07"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_08"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_09"},
      snd.load_sound{"Effects/Footsteps_Snow_Hard_Run_10"},
    },
    sandrun = {
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_01", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_02", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_03", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_04", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_05", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_06", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_07", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_08", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_09", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_10", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_11", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_12", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_13", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_14", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_15", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_16", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_17", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_18", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_19", extension = ".wav"},
      -- snd.load_sound{"Effects/footsteps/Footsteps_Sand_Run/Footsteps_Sand_Run_20", extension = ".wav"},

      snd.load_sound{"Effects/Footsteps_Sand_Run_01"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_02"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_03"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_04"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_05"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_06"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_07"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_08"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_09"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_10"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_11"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_12"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_13"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_14"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_15"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_16"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_17"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_18"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_19"},
      snd.load_sound{"Effects/Footsteps_Sand_Run_20"},
    }
  },
  lasersword = snd.load_sound{"Effects/lasersword"},
  hard_step = snd.load_sound{"Effects/hard_step"},
  jagoburonLaugh = snd.load_sound{"Effects/jagoburonLaugh"},
  wingFlap = snd.load_sound{"Effects/Wing_flap"},
  dragonWingFlap = snd.load_sound{"Effects/OOS_OnoxDragon_Fly"},
  dragonRoar = snd.load_sound{"Effects/OOS_Dodongo_Roar"},
  dragonWalk = snd.load_sound{"Effects/OOS_Aquamentus_Walk"},
  smallBoom = snd.load_sound{"Effects/Oracle_Barrier"},
  bigBoom = snd.load_sound{"Effects/Oracle_Boss_BigBoom"},
  pauseOpen = snd.load_sound{"Effects/Oracle_PauseMenu_Open"},
  pauseClose = snd.load_sound{"Effects/Oracle_PauseMenu_Close"},
  secret = snd.load_sound{"Effects/Oracle_Secret"},
  select = snd.load_sound{"Effects/Oracle_Menu_Select"},
  deselect = snd.load_sound{"Effects/Oracle_Menu_Cursor_low_pitch"},
  error = snd.load_sound{"Effects/Oracle_Error"},
  letter = snd.load_sound{"Effects/Oracle_Text_Letter"},
  textDone = snd.load_sound{"Effects/Oracle_Text_Done"},
  cursor = snd.load_sound{"Effects/Oracle_Menu_Cursor"},
  getHeart = snd.load_sound{"Effects/Oracle_Get_Heart"},
  getRupee = snd.load_sound{"Effects/Oracle_Get_Rupee"},
  getRupee5 = snd.load_sound{"Effects/Oracle_Get_Rupee5"},
  getRupee20 = snd.load_sound{"Effects/Oracle_Get_Rupee20"},
  fanfareItem = snd.load_sound{"Effects/Oracle_Fanfare_Item"},
  open = snd.load_sound{"Effects/Oracle_Chest"},
  heartContainer = snd.load_sound{"Effects/Oracle_HeartContainer"},
  stairs = snd.load_sound{"Effects/Oracle_Stairs"},
  useItem = snd.load_sound{"Effects/Oracle_Get_Item"},
  portal = snd.load_sound{"Effects/Oracle_Dungeon_Teleport"},
  bomb = snd.load_sound{"Effects/Oracle_Bomb_Blow"},
  bombDrop = snd.load_sound{"Effects/Oracle_Bomb_Drop"},
  magicDust = snd.load_sound{"Effects/Oracle_MakuTree_Leaves"},
  appearVanish = snd.load_sound{"Effects/Oracle_AppearVanish"},
  decoy = snd.load_sound{"Effects/OOA_Veran_Shapeshift"},
  fire = snd.load_sound{"Effects/Oracle_EmberSeed"},
  ice = snd.load_sound{"Effects/Oracle_SwordShimmer"},
  stone = snd.load_sound{"Effects/Oracle_Rumble2b"},
  boing = snd.load_sound{"Effects/Oracle_ScentSeed"},
  plant = snd.load_sound{"Effects/Oracle_ScentSeed_Shot"},
  wind = snd.load_sound{"Effects/Oracle_GaleSeed"},
  blockFall = snd.load_sound{"Effects/Oracle_Block_Fall"},
  enemyJump = snd.load_sound{"Effects/Oracle_Enemy_Jump"},
  shieldDeflect = snd.load_sound{"Effects/Oracle_Shield_Deflect"},
  swordShimmer = snd.load_sound{"Effects/Oracle_SwordShimmer"},
  supercharge = snd.load_sound{"Effects/Oracle_BiggoronsSword"},
  journalEntry = snd.load_sound{"Effects/journalEntry"},
  bell = snd.load_sound{"Effects/bell"},

  -- Mundane
  bushCut = snd.load_sound{"Effects/Oracle_Bush_Cut"},
  uproot = snd.load_sound{"Effects/Bush_Uproot"},
  dungeonDoor = snd.load_sound{"Effects/Oracle_Dungeon_Door"},

  -- Feedback
  runOut = snd.load_sound{"Effects/run_out"},
  runningLow = snd.load_sound{"Effects/running_low"},

  -- Harpsounds
  harpad = snd.load_sound{"Effects/harp/ad"},
  harpadB = snd.load_sound{"Effects/harp/adB"},
  harpbd = snd.load_sound{"Effects/harp/bd"},
  harpbdB = snd.load_sound{"Effects/harp/bdB"},
  harpcd = snd.load_sound{"Effects/harp/cd"},
  harpdd = snd.load_sound{"Effects/harp/dd"},
  harpddB = snd.load_sound{"Effects/harp/ddB"},
  harped = snd.load_sound{"Effects/harp/ed"},
  harpedB = snd.load_sound{"Effects/harp/edB"},
  harpfd = snd.load_sound{"Effects/harp/fd"},
  harpfdS = snd.load_sound{"Effects/harp/fdS"},
  harpgd = snd.load_sound{"Effects/harp/gd"},

  harpam = snd.load_sound{"Effects/harp/am"},
  harpamB = snd.load_sound{"Effects/harp/amB"},
  harpbm = snd.load_sound{"Effects/harp/bm"},
  harpbmB = snd.load_sound{"Effects/harp/bmB"},
  harpcm = snd.load_sound{"Effects/harp/cm"},
  harpdm = snd.load_sound{"Effects/harp/dm"},
  harpdmB = snd.load_sound{"Effects/harp/dmB"},
  harpem = snd.load_sound{"Effects/harp/em"},
  harpemB = snd.load_sound{"Effects/harp/emB"},
  harpfm = snd.load_sound{"Effects/harp/fm"},
  harpfmS = snd.load_sound{"Effects/harp/fmS"},
  harpgm = snd.load_sound{"Effects/harp/gm"},

  harpcu = snd.load_sound{"Effects/harp/cu"},
  harpdu = snd.load_sound{"Effects/harp/du"},
  harpduB = snd.load_sound{"Effects/harp/duB"},
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
  love.window.setFullscreen(true, "desktop")
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

currentCamera = nil
caml, camt, camw, camh = nil, nil, nil, nil
local function setCurrentCam(curcam)
  currentCamera = curcam
  if not currentCamera then
    caml, camt, camw, camh = nil, nil, nil, nil
    return
  end
  caml, camt, camw, camh = currentCamera:getVisible()
end

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
  local FC = require("GameObjects.InRooms.cursedForest.forestCurse")
  o.addToWorld(FC:new())

  -- -- Room Creator
  -- -- 25 width 15 visible height (last tile mostly obscured) for zoom 2
  -- game.room = assert(love.filesystem.load("RoomBuilding/room_editor.lua"))()
  -- sh.calculate_total_scale{game_scale=game.room.game_scale}
  -- session.initialize()
end

function love.textinput(t)
  if string.len(text.input) > text.inputLim then return end
  text.input = text.input .. t
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
      if aob.spriteOffset then apos = apos + aob.spriteOffset end
      if bob.spriteOffset then bpos = bpos + bob.spriteOffset end
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
  Pointer.left.update()
  Pointer.right.update()

  -- Run async functions before messing with the timeflow (dt)
  async.realTimeUpdate(dt)

	dt = math.min(GCON.MAX_DT, dt)

  if session.sleeping_danger then
    dt = 0.1
  end

  delta_time = dt

  local drugSlomo
  if session.drug then drugSlomo = session.drug.slomo end
  dt = dt * (drugSlomo or session.ringSlomo or 1)
  if pl1 and pl1.exists and pl1.timeFlow then
    dt = dt / pl1.timeFlow
  end

  -- Run async functions after messing with the timeflow (dt)
  async.gameTimeUpdate(dt)

  -- update timers
  gvar.t = gvar.t + dt

  -- Store mouse input
  moub["1press"] = moub[1] and not moub["1prev"]
  moub["2press"] = moub[2] and not moub["2prev"]
  moub["1prev"] = moub[1]
  moub["2prev"] = moub[2]
  moup.x, moup.y = love.mouse.getX(), love.mouse.getY()

  -- Calculate clock stuff
  if session.clockAngleTarget then
    session.clockAngleTarget = session.getClockAngleTarget()
    if session.clockAngle ~= session.clockAngleTarget then
      session.clockAngle = u.gradualAdjust(dt, session.clockAngle, session.clockAngleTarget)
    end
  end

  -- fuck = session.save.time

  -- -- display mouse position
  local wmx, wmy = cam:toWorld(moup.x, moup.y)
  wmx, wmy = math.floor(wmx / 16) * 16 + 8, math.floor(wmy / 16) * 16 + 8
  fuck = tostring(wmx) .. "/" .. tostring(wmy)

  -- -- display room
  -- fuck = fuck .. "\n" .. (session.latestVisitedRooms and session.latestVisitedRooms:getLast() or "")
  -- if not fook then fook = {} end
  -- fook[session.latestVisitedRooms and session.latestVisitedRooms:getLast() or ""] = true
  -- fuck = ""
  -- for room in pairs(fook) do
  --   fuck = fuck .. room .. "\n"
  -- end

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

  game.finishedTransition = false
  -- manage transition
  if game.transitioning then

    game.transitioning.firstFrame = false
    if not game.transitioning.startedTransition then
      game.transitioning.firstFrame = true
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
      -- local transSpeed = 1
      -- if game.transitioning.type ~= 'whiteScreen' then transSpeed = 0.1 end
      if game.transitioning.type == 'scrolling' then
        game.transitioning.progress = game.transitioning.progress + 6 * (1.02 - game.transitioning.progress) * (game.transitioning.speed or 1) * dt
      else
        game.transitioning.progress = game.transitioning.progress + (game.transitioning.speed or 1) * dt
      end
      if game.transitioning.progress > 1 then game.transitioning.progress = 1 end
      trans.determine_coordinates_transformation()
    else
      inp.transing = false

      o.to_be_deleted:remove_all()

      local room = game.room

      local gts = game.transitioning.side
      local horside = gts == "left" and -1 or (gts == "right" and 1 or 0)
      local verside = gts == "up" and -1 or (gts == "down" and 1 or 0)


      -- Store player (if this isn't here, followingif statement will crash for some reason)
      local playaTest2 = o.identified.PlayaTest
      if playaTest2 and playaTest2[1].x then
        pl1 = playaTest2[1]
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

          session.save.lastWhitescreenScreenName = game.transitioning.roomTarget
          session.save.lastWhitescreenScreenX = game.transitioning.desx
          session.save.lastWhitescreenScreenY = game.transitioning.desy
        end
        -- reset player veolocity after transition if necessary
        -- playa.body:setLinearVelocity(u.sign(playa.vx), u.sign(playa.vy))
        local sd = game.transitioning.side
        local xsign, ysign
        if sd == "left" then xsign = -1
        elseif sd == "right" then xsign = 1
        elseif sd == "up" then ysign = -1
        elseif sd == "down" then ysign = 1 end
        playa.lastTransSide = sd
        local xtransvel = u.sign(xsign or playa.vx) * u.clamp(math.abs(horside * 10), math.abs(playa.vx * 0.25), 25)
        local ytransvel = u.sign(ysign or playa.vy) * u.clamp(math.abs(verside * 10), math.abs(playa.vy * 0.25), 25)
        playa.body:setLinearVelocity(xtransvel, ytransvel)
        -- playa.body:setLinearVelocity(playa.vx * 0.25, playa.vy * 0.25)
        playa.zvel = 0
      end

      game.paused = false
      game.transitioning = false
      game.finishedTransition = true

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

  local justPaused = type(game.paused) == 'table' and (not game.paused_prev ~= not game.paused)
  local justUnpaused = type(game.paused_prev) == 'table' and (not game.paused_prev ~= not game.paused)
  game.paused_prev = game.paused

  if justPaused then
    pam.open()
  end

  if justUnpaused then
    pam.close()
  end

  if not Debug.freeze_screen then
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
        local m = session.sleeping_danger and 0.2 or 0.08333
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
      local dtpart = dt
      while dtpart > GCON.MAX_PHYSICS_DT do
        ps.pw:update(GCON.MAX_PHYSICS_DT)
        dtpart = dtpart - GCON.MAX_PHYSICS_DT
      end
      ps.pw:update(dtpart)

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
      pam.left.logic()
      pam.top_menu_logic()
      if game.paused ~= true and (inp.current[game.paused.player].start == 1 and inp.previous[game.paused.player].start == 0)
        or (not pam.quitting and inp.cancelPressed and not pam.left.selectedHeader)
        or session.forceCloseInv
      then
        game.pause(false)
        inv.closeInv()
        session.forceCloseInv = false
      end
    end
  end

  -- If unpausable_update doesn't run after physics and/or(?) the other updates,
  -- pausing during an unpausable update after transition causes wrong positioning.
  -- See when adding the first journal entry durning a scrolling transition
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

  -- Run unstoppable_update methods
  local usUpnum = #o.unstoppableUpdaters
  if usUpnum > 0 then
    for i = 1, usUpnum do
      o.unstoppableUpdaters[i]:unstoppable_update(dt)
    end
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
  -- love.graphics.setColor(0.6, 0.6, 0.6, 1)
  -- love.graphics.rectangle("fill", 0, 0, 800, 450)
  love.graphics.setColor(1, 1, 1, 1)

  local layers = #o.draw_layers
  if layers > 0 then

    local prevMode = trans.mode

    -- Normal drawing mode
    if not game.transitioning or
    (game.transitioning and not game.transitioning.startedTransition) then

      trans.mode = 'none'

      if prevMode == 'scrolling' and prevMode ~= trans.mode then
        trans.just_stopped_scrolling = true
      else
        trans.just_stopped_scrolling = false
      end

      for layer = 1, layers do
        local drawnum = #o.draw_layers[layer]
        for i = 1, drawnum do
          o.draw_layers[layer][i]:draw()
        end
      end

    -- Transition drawing mode
    elseif game.transitioning.type == "scrolling" then

      trans.mode = 'scrolling'
      for layer = 1, layers do
        local drawnum = #o.draw_layers[layer]
        for i = 1, drawnum do
          o.draw_layers[layer][i]:trans_draw()
        end
      end

    end

  end -- if layers > 0

  -- -- Enemarea code
  -- enemarea = enemarea or {}
  -- triangles = triangles or {}
  -- if enemarea[1] then
  --   -- Polygon
  --   if #enemarea == 2 then
  --     love.graphics.points(enemarea)
  --   elseif #enemarea == 4 then
  --     love.graphics.line(enemarea)
  --   elseif #enemarea >= 6 then
  --     love.graphics.polygon("line", enemarea)
  --   end
  -- end
  -- -- Triangles
  -- for _, triangle in ipairs(triangles) do
  --   -- love.graphics.polygon("line", triangle)
  --
  --   local resetColour = u.storeColour()
  --   u.changeColour{"white", a = 0.5}
  --   love.graphics.polygon("fill", triangle)
  --   resetColour()
  -- end

  love.graphics.setColor(1, 0, 1, 1)
  if Debug.bodiesRenderMode == 1 then
    local bs = ps.pw:getBodies()
    ---@param b love.Body
    for _, b in ipairs(bs) do
      local fis = b:getFixtures()
      for _, fi in ipairs(fis) do
        local sha = fi:getShape()
        if sha:getType() == 'circle' then
          local x, y = b:getPosition()
          love.graphics.circle("line", x, y, sha:getRadius())
        elseif sha:getType() == 'polygon' then
          love.graphics.polygon("line", b:getWorldPoints(sha:getPoints()))
        end
      end
    end
  elseif Debug.bodiesRenderMode == 2 then
    local bs = ps.pw:getBodies()
    ---@param b love.Body
    for _, b in ipairs(bs) do
      if b:getType() ~= 'static' then
        local fis = b:getFixtures()
        for _, fi in ipairs(fis) do
          local sha = fi:getShape()
          if sha:getType() == 'circle' then
            local x, y = b:getPosition()
            love.graphics.circle("line", x, y, sha:getRadius())
          elseif sha:getType() == 'polygon' then
            love.graphics.polygon("line", b:getWorldPoints(sha:getPoints()))
          end
        end
      end
    end
  end
  love.graphics.setColor(1, 1, 1, 1)

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
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    -- love.graphics.rectangle("fill", 0, 0, 800, 450)
    local wl, lt = cam:toWorld(0, 0)
    local ww, wh = cam:toWorld(love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.rectangle("fill", wl, lt, ww-wl, wh-lt)
    love.graphics.setColor(1, 1, 1, 1)
  end
end
local function noEffectsDraw()
  -- The lights must be drawn either here
  -- or below. When drawn here there is
  -- a delay because the camera moves after
  -- they are drawn. However if they are
  -- not drawn here at the moment that a
  -- scrolling transition ends there's a blink!
  -- This check determines where the lights will
  -- be drawn.
  -- It's a total hack but don't touch it or all will be lost!
  if game.finishedTransition then
    imports.lighting.draw()
  end

  cam:setScale(sh.get_total_scale())
  -- local l, t, w, h = cam:getWindow()
  -- cam:setWindow(cam.noisel,cam.noiset,w,h)
  local l, t, w, h = sh.get_current_window()
  cam:setWindow(cam.noisel + l,cam.noiset + t,w,h)

  local camxt = cam.xt
  local camyt = cam.yt

  cam:setPosition(camxt, camyt)
  setCurrentCam(mainCamera)

  if not game.finishedTransition then
    imports.lighting.draw()
  end

  cam:draw(mainCameraDraw)
end
local function hudDraw(l,t,w,h)

  imports.healthDisplay.draw(l,t,w,h)

  local transing = game.transitioning
  if pl1 and not (transing and transing.type == "whiteScreen") then
    local pr, pg, pb, pa = love.graphics.getColor()

    -- Draw rupees
    local maxMoney = session.maxMoney()
    local rupeeDigits = u.countIntDigits(maxMoney)
    local rupees = string.format("%0"..rupeeDigits.."d", (session.save.rupees or 0))
    local rspr = im.sprites["rupees"]
    love.graphics.draw(rspr.img, rspr[0], w-9, h-9,  0, rspr.res_x_scale, rspr.res_y_scale)
    love.graphics.setColor(0, 0, 0, 1)
    local rupeeOffset = rupeeDigits * 6.1 + 10
    local rupeeYBase = h-7.5
    love.graphics.print(rupees, w - rupeeOffset + rno, rupeeYBase, 0, 0.255)
    love.graphics.print(rupees, w - rupeeOffset - rno, rupeeYBase, 0, 0.255)
    love.graphics.print(rupees, w - rupeeOffset, rupeeYBase + rno, 0, 0.255)
    love.graphics.print(rupees, w - rupeeOffset, rupeeYBase - rno, 0, 0.255)
    if maxMoney == session.save.rupees then
      love.graphics.setColor(1, 1, 0.2, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.print(rupees, w - rupeeOffset, rupeeYBase, 0, 0.255)

    -- Draw clock
    if game.clockInactive then
      love.graphics.setColor(1, 0.3, 0.3, 1)
      love.graphics.setColor(0.3, 1, 1, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end
    local cspr = im.sprites["clock"]
    local clockX = w * 0.9 - ((rupeeDigits < 4) and 0 or 6.1)
    love.graphics.draw(cspr.img, cspr[0], clockX, h, session.clockAngle, cspr.res_x_scale, cspr.res_y_scale, cspr.cx, cspr.cy)
    local chspr = im.sprites["clockHand"]
    love.graphics.draw(chspr.img, chspr[session.clockAngleTarget == 0 and 0 or 1], clockX, h, -session.clockAngle + session.save.time * math.pi / 12, chspr.res_x_scale, chspr.res_y_scale, chspr.cx, chspr.cy)

    love.graphics.setColor(pr, pg, pb, pa)


    -- Draw pause menu
    if game.paused and not transing and not game.cutscene then
      -- local pr, pg, pb, pa = love.graphics.getColor()
      love.graphics.setColor(0, 0, 0, 0.5)
      love.graphics.rectangle("fill", l, t, w, h)
      love.graphics.setColor(pr, pg, pb, pa)
      inv.draw(l,t,w,h)
      pam.middle.draw(l,t,w,h)
      pam.left.draw(l, t, w, h)
      pam.top_menu_draw(l,t,w,h)
    end
  end
end
local prevs = {
  firstDraw = true,
  drug = "uninitialised",
  ring = "uninitialised"
}
function love.draw()
  gamera.start()

  local resetScreenEffects = false

  if prevs.firstDraw then resetScreenEffects = true end
  if prevs.drug ~= (session.drug and session.drug.shader) then resetScreenEffects = true end
  if prevs.ring ~= session.ringShader then resetScreenEffects = true end

  prevs.firstDraw = false
  prevs.drug = session.drug and session.drug.shader
  prevs.ring = session.ringShader

  if resetScreenEffects then
    imports.screenEffects.clear()
    imports.lighting.pushScreenEffect()
    if session.drug and session.drug.shader then
      imports.screenEffects.push(session.drug.shader, function(s) s:send("invScale", 0.9 + 0.1*math.cos(session.drug.duration - session.drug.maxDuration)) end)
    end
    if session.ringShader then
      imports.screenEffects.push(session.ringShader)
    end
    imports.screenEffects.push(imports.shdrs.vignette)
  end

  noEffectsDraw()
  imports.screenEffects.apply(gamera.getCanvas())

  cam:draw(afterScreenEffects)

  hud:setScale(sh.get_window_scale()*2)
  hud:setPosition(hud.xt, hud.yt)
  setCurrentCam(hud)

  if hud.visible and pl1 then
    hud:draw(hudDraw)
  end

  -- Print dialogues, signs, and generally in-game text stuff
  if dialogue.enabled then
    textCam:setScale(sh.get_window_scale())
    setCurrentCam(textCam)

    dialogue.currentMethod.draw(textCam)

    if dialogue.currentChoice then
      dialogue.currentChoice.draw(cam:getWindow())
    end
  end

  setCurrentCam()

  gamera.stop()

  -- debug
  love.graphics.print("FPS: " .. love.timer.getFPS(),love.graphics.getWidth()-200,love.graphics.getHeight()-77)

  local restore_col = u.storeColour()
  love.graphics.circle('fill', 10, love.graphics.getHeight()-100 + 10 - Debug.cursor * 30, 5)

  if Debug.cursor == 0 then u.changeColour{r = 1, g = 1, b = 1} else u.changeColour{r = 0.5, g = 0.5, b = 0.5} end
  love.graphics.print("Enemy: ", 20, love.graphics.getHeight()-100)
---@diagnostic disable-next-line: undefined-global
  if currentEnemyName then
    love.graphics.print(currentEnemyName, 150 + 20, love.graphics.getHeight()-100)
  end
  -- if Debug.cursor == 1 then u.changeColour{r = 1, g = 1, b = 1} else u.changeColour{r = 0.5, g = 0.5, b = 0.5} end
  -- love.graphics.print("Walk Anim Max Speed: " .. tostring(GPAR.walk_anim_max_speed), 20, love.graphics.getHeight()-100 - 30)
  -- if Debug.cursor == 2 then u.changeColour{r = 1, g = 1, b = 1} else u.changeColour{r = 0.5, g = 0.5, b = 0.5} end
  -- love.graphics.print("Walk Anim Speed Factor: " .. tostring(GPAR.walk_anim_speed_factor), 20, love.graphics.getHeight()-100 - 60)
  restore_col()
  if fuck then love.graphics.print(tostring(fuck), 0, 177+120) end
  local debiter = 0
---@diagnostic disable-next-line: undefined-global
  if triggersdebug then
---@diagnostic disable-next-line: undefined-global
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
  -- ["blueHand.lua"] = true,
  -- ["redHand.lua"] = true,
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
    if u.utf8_sub(name, -4) == ".lua" then
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

function love.wheelmoved(_, y)

  local move = 0
  if y > 0 then
    -- Mouse wheel moved up
    move = 1
  elseif y < 0 then
    -- Mouse wheel moved down
    move = -1
  end

  if Debug.cursor == 0 then
    if cursor then
      cursor = cursor + move
    else
      cursor = startingCursor
    end
    if cursor > #enemyPaths then
      cursor = 1
    elseif cursor < 1 then
      cursor = #enemyPaths
    end
    currentEnemyName = enemyPaths[cursor]
  elseif Debug.cursor == 1 then
    GPAR.walk_anim_max_speed = GPAR.walk_anim_max_speed + move * 0.01
  elseif Debug.cursor == 2 then
    GPAR.walk_anim_speed_factor = GPAR.walk_anim_speed_factor + move * 0.01
  end
end

function love.mousepressed(x, y, button, isTouch)
  -- x, y = cam:toWorld(x, y)

  -- local DynBrick = require("GameObjects.dynamicBrick")
  -- local brick = DynBrick:new{x = x, y = y, xstart = x, ystart = y}
  -- o.addToWorld(brick)

  if Debug.cursor == 0 then
    if currentEnemyName then
      local enemClass = assert(love.filesystem.load(currentEnemyName))()
      local enem = enemClass:new()
      local wx, wy = cam:toWorld(x, y)
      enem.x, enem.y = wx, wy
      enem.xstart, enem.ystart = enem.x, enem.y
      o.addToWorld(enem)
    else
      -- local enemClass = assert(love.filesystem.load("/GameObjects/DialogueBubble/DialogueControl.lua"))()
      -- local enemClass = assert(love.filesystem.load("/GameObjects/misc/chess/pawn.lua"))()
      -- local enem = enemClass:new()
      -- local wx, wy = cam:toWorld(x, y)
      -- enem.x, enem.y = wx, wy
      -- enem.xstart, enem.ystart = enem.x, enem.y
      -- o.addToWorld(enem)

      -- u.printTable('graphics stats', love.graphics.getStats(), 1)
    end
  end

  -- -- Enemarea code
  -- if type(enemarea[1]) == "table" then enemarea = {} end
  -- x, y = cam:toWorld(x, y)
  -- table.insert(enemarea, x)
  -- table.insert(enemarea, y)

  moub[button] = true

  -- local realW, realH = sh.fit_in_aspect_ratio(love.graphics.getWidth(), love.graphics.getHeight())
  -- local deadW, deadH = sh.get_deadspace(love.graphics.getWidth(), love.graphics.getHeight())

  -- if button == 1 then
  --   Pointer.left.clicked = true

  --   local clickX = x - deadW
  --   local clickY = y - deadH

  --   if clickX < 0 or clickX > realW then
  --     Pointer.left.viewport.position.normal.x = -1
  --   else
  --     Pointer.left.viewport.position.normal.x = clickX / realW
  --   end
  --   if clickY < 0 or clickY > realH then
  --     Pointer.left.viewport.position.normal.y = -1
  --   else
  --     Pointer.left.viewport.position.normal.y = clickY / realH
  --   end
  -- elseif button == 2 then
  --   Pointer.right.clicked = true

  --   local clickX = x - deadW
  --   local clickY = y - deadH

  --   if clickX < 0 or clickX > realW then
  --     Pointer.right.viewport.position.normal.x = -1
  --   else
  --     Pointer.right.viewport.position.normal.x = clickX / realW
  --   end
  --   if clickY < 0 or clickY > realH then
  --     Pointer.right.viewport.position.normal.y = -1
  --   else
  --     Pointer.right.viewport.position.normal.y = clickY / realH
  --   end
  -- end
end

function love.mousereleased(x, y, button, isTouch)
  moub[button] = false

  -- if button == 1 then
  --   Pointer.left.clicked = false
  -- elseif button == 2 then
  --   Pointer.right.clicked = false
  -- end
end

function love.keypressed(key, scancode)
  if key == "backspace" then
    text.input = u.utf8_backspace(text.input, 1)
  elseif key == "f11" then
    local isFull = love.window.getFullscreen()
    love.window.setFullscreen(not isFull, "desktop")
  elseif key == ',' or key == '<' then
    Debug.cursor = Debug.cursor + 1
  elseif key == '.' or key == '>' then
    Debug.cursor = Debug.cursor - 1
  elseif key == 'p' then
    Debug.freeze_screen = not Debug.freeze_screen
  end
  if Debug.cursor < 0 then
    Debug.cursor = 2
  elseif Debug.cursor > 2 then
    Debug.cursor = 0
  end

  if key == 't' then
    Debug.bodiesRenderMode = Debug.bodiesRenderMode + 1
    if Debug.bodiesRenderMode > 2 then
      Debug.bodiesRenderMode = 0
    else
      print('================')
      print('Body stuff start')
      print('================')
    end

    ---@param b love.Body
    local shitfuckcrapass = function(b)
      local x, y = b:getPosition()
      local wmx, wmy = cam:toWorld(moup.x, moup.y)
      if u.distanceSqared2d(wmx, wmy, x, y) < 256 then
        print('--------------')
        print('Body user Data')
        print('--------------')
        print('userdata ref: ', b:getUserData())
        print('userdata exists: ', b:getUserData().exists)
        u.printTable('userdata', b:getUserData(), 2)
      end
    end

    if Debug.bodiesRenderMode == 1 then
      local bs = ps.pw:getBodies()
      for _, b in ipairs(bs) do
        shitfuckcrapass(b)
      end
    elseif Debug.bodiesRenderMode == 2 then
      local bs = ps.pw:getBodies()
      for _, b in ipairs(bs) do
        if b:getType() ~= 'static' then
          shitfuckcrapass(b)
        end
      end
    end
  end

  -- -- Enemarea code
  -- if key == "f" then
  --   if #enemarea > 4 then
  --     for _, triangle in ipairs(love.math.triangulate(enemarea)) do
  --       table.insert(triangles, triangle)
  --     end
  --   end
  --   enemarea = {}
  -- elseif key == "g" then
  --   enemarea = {}
  --   triangles = {}
  -- elseif key == "h" then
  --   -- local areaData = "{\n"
  --
  --   -- no whitespace
  --   local areaData = "{"
  --   local delim = ""
  --   -- Find total area
  --   local totalArea = 0
  --   for _, triangle in ipairs(triangles) do
  --     totalArea = totalArea + u.getTriangleArea(triangle)
  --   end
  --   for _, triangle in ipairs(triangles) do
  --
  --     -- areaData = areaData..delim.."  {\n"..
  --     -- "    value = {"..
  --     -- triangle[1]..", "..triangle[2]..", "..
  --     -- triangle[3]..", "..triangle[4]..", "..
  --     -- triangle[5]..", "..triangle[6].."},\n"..
  --     -- "    chance = "..(u.getTriangleArea(triangle) / totalArea).."\n"..
  --     -- "  }"
  --     --
  --     -- delim = ",\n"
  --
  --     -- no whitespace
  --     areaData = areaData..delim.."{"..
  --     "value={"..
  --     triangle[1]..","..triangle[2]..","..
  --     triangle[3]..","..triangle[4]..","..
  --     triangle[5]..","..triangle[6].."},"..
  --     "chance="..(u.getTriangleArea(triangle) / totalArea)..
  --     "}"
  --
  --     delim = ","
  --
  --   end
  --   -- areaData = areaData.."\n}\n"
  --   -- no whitespace
  --   areaData = areaData.."}"
  --   love.filesystem.write("enemarea.txt", areaData)
  -- end

  -- if key == "c" then collectgarbage(); fuck = collectgarbage("count") end
  text.key = scancode ~= "return" and scancode or text.key
end

function love.resize( w, h )
  sh.calculate_resized_window( w, h )
  gamera.resize()

  -- Set camera display window size and offset
  cam:setWindow(sh.getCachedWindow())
  hud:setWindow(sh.getCachedWindow())
  textCam:setWindow(sh.getCachedTextWindow())
  -- textCam:setWindow(sh.getCachedTextWindow())

  imports.screenEffects.resize(w, h)

  -- Determine camera scale due to window size
  sh.calculate_total_scale{resized=true}

  imports.lighting.resize(w, h)
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
