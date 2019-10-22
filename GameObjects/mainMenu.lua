local verh = require "version_handling"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local im = require "image"
local snd = require "sound"
local text = require "text"
local u = require "utilities"
local inp = require "input"
local input = inp

local gs = require "game_settings"

local floor = math.floor
local clamp = u.clamp

local font = text.font
local textScale = 0.5

-- Table that returns what menus to draw based on current menu
local drawMenus = {
  {1}, -- Only draw main body
  {1,2}, -- Main body + Load game
  {1,3}, -- Main body + create new save
  {1,2,4}, -- Main body + Load game + Load game options (load, erase)
  {1,5}, -- Main body + Game Settings
  {1,5,6} -- Main body + Game Settings + Key Config
}

-- Table that returnes which menu you end up on when pressin backspace
local backspaceMenu = {
  -- Format: [Menu after backspace], -- Comment to show menu before backspace
  1, -- Main body
  1, -- Load game
  1, -- Create New Save
  2, -- Load, erase Save
  1, -- Game Settings
  5, -- Key Config
}

local tipboxX, tipboxY, tipboxRepeats, tipboxRepeatsH, tipboxTip =
  9, 222, 0, 0, ""


local function start_game(saveName)
  -- Disable menu music
  snd.bgm:load(snd.silence)
  -- assert(love.filesystem.load instead of require to detect file changes
  local readSave = assert(love.filesystem.load("Saves/" .. saveName .. ".lua"))()
  -- Nilify session (Only values!!!)
  for key, value in pairs(session) do
    if type(value) ~= "table" and type(value) ~= "function" then session[key] = nil end
  end
  -- Nilify save
  for key, value in pairs(session.save) do
    session.save[key] = nil
  end
  -- Load imported save values to save
  session.save.quests = {}
  for key, value in pairs(readSave) do
    -- if saved thing is quest place on different table, minus prefix
    if key:find("__quest__") then
      session.save.quests[string.gsub(key, "__quest__", "")] = value -- key is questname, value quest stage
    else
      session.save[key] = value
    end
  end
  -- initialize certain values
  session.initialize()
  -- Remember which save I am
  session.save.saveName = saveName

  game.transition{
    type = "whiteScreen",
    noFade = true,
    progress = 0,
    roomTarget = "Rooms/room0.lua"
  }
  Hud.visible = true
end

-- Make sure the cursor knows its menu and its items and each item knows its menu
local function handle_relations(menu)
  local cursorExists = menu.cursor

  if cursorExists then
    menu.cursor.menu = menu
    menu.cursor.items = {}
  end

  if menu.items then

    for _, item in ipairs(menu.items) do
      -- If item can be pointed by cursor add it to cursor items
      if item.cursorable then
        table.insert(menu.cursor.items, item)
      end
      item.menu = menu
    end

  end
end

local function load_gs_to_temp(menuHandler, gs)
  menuHandler.tempGs = menuHandler.tempGs or {}
  for setting, value in pairs(gs) do
    menuHandler.tempGs[setting] = value
  end
end

local function change_game_settings(menuHandler)
  menuHandler.currentMenu = 1
  -- Overwrite game_settings file
  local success = love.filesystem.write("game_settings.lua", "local gs = {}\n")
  if not success then love.errhand("Failed to write game_settings first line") end
  -- Variable to store string to be written
  local game_settings_body = ""
  for setting, value in pairs(menuHandler.tempGs) do
    -- Update already loaded table
    gs[setting] = value
    if type(value) == "string" then value = "\'" .. value .. "\'"
    elseif type(value) == "boolean" then
      if value then value = "true" else value = "false" end
    end
    game_settings_body = game_settings_body .. "gs." .. setting .. " = " .. value .. "\n"
  end
  local success = love.filesystem.append("game_settings.lua", game_settings_body .. "return gs\n")
  if not success then love.errhand("Failed to write game_settings body") end
end

local function change_key_config(menuHandler)
  -- Overwrite game_settings file
  local success = love.filesystem.write("key_config.lua", "local kc = {}\nkc.player1 = {\n")
  if not success then love.errhand("Failed to write key_config 1") end
  -- Variable to store string to be written
  local key_config_body = ""
  for keyName, key in pairs(menuHandler.tempKt.player1) do
    key_config_body = key_config_body .. keyName .. " = \"" .. key .. "\",\n"
  end
  local success = love.filesystem.append("key_config.lua", key_config_body .. "}\nreturn kc\n")
  if not success then love.errhand("Failed to write key_config body") end
end

-- function make drawing take less lines
local function typical_drawMe(sprite, image_index, x, y)
  local sprite = im.sprites[sprite]
  local frame = sprite[image_index]
  love.graphics.draw(
  sprite.img, frame, x, y, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
end

local function horizontal_menuBox(self, x, y, repeats)
  local xlast = (repeats + 1) * 16 + x
  self:drawMe(0, x, y - 16)
  for i = 1, repeats do
    self:drawMe(1, x + i * 16, y - 16)
  end
  self:drawMe(2, xlast, y - 16)
  self:drawMe(4, x, y)
  for i = 1, repeats do
    self:drawMe(5, x + i * 16, y)
  end
  self:drawMe(6, xlast, y)
  self:drawMe(8, x, y + 16)
  for i = 1, repeats do
    self:drawMe(9, x + i * 16, y + 16)
  end
  self:drawMe(10, xlast, y + 16)
end

local function normal_menuBox (self, x, y, repeats, repeatsH)
  local xlast = (repeats + 1) * 16 + x
  local ylast = y + repeatsH * 16
  self:drawMe(0, x, y - 16)
  for i = 1, repeats do
    self:drawMe(1, x + i * 16, y - 16)
  end
  self:drawMe(2, xlast, y - 16)

  for j = 0, repeatsH - 1 do
    self:drawMe(4, x, y + j * 16)
    for i = 1, repeats do
      self:drawMe(5, x + i * 16, y + j * 16)
    end
    self:drawMe(6, xlast, y + j * 16)
  end

  self:drawMe(8, x, ylast)
  for i = 1, repeats do
    self:drawMe(9, x + i * 16, ylast)
  end
  self:drawMe(10, xlast, ylast)
end

local function normal_slider(self, x, y, sliderRepeats, xoffset)
  local xoffmin1 = xoffset - 16
  for i = 1, sliderRepeats do
    self:drawMe2(1, x + xoffmin1 + i * 16, y)
  end
  self:drawMe2(0, x + xoffmin1 + 16, y)
  self:drawMe2(3, x + xoffset + self.slider * (self.sliderRepeats - 1) * 16, y)
  self:drawMe2(2, x + xoffmin1 + self.sliderRepeats * 16, y)
end

local function set_up_normal_slider(self, value, min, max)
  self.slider = (value - min)/(max - min)
end

local function typical_slide(self, value, min, max, menuHandler, sliderImpulse)
  self.slider = self.slider + sliderImpulse
  if self.slider > 1 then self.slider = 1
  elseif self.slider < 0 then self.slider = 0
  end
  menuHandler.tempGs[value] = floor(self.slider * (max - min) + min)
end

local function typical_preciseSlide(self, value, min, max, menuHandler, sliderImpulse)
  menuHandler.tempGs[value] = clamp(min, menuHandler.tempGs[value] + sliderImpulse, max)
  self.slider = (menuHandler.tempGs[value] - min)/(max - min)
end

local setFont = love.graphics.setFont

local MainMenu = {}

function MainMenu.initialize(instance)
  instance.sprite_info = {
    {'Menu/SimpleMenuBox', 4, 3, padding = 2, width = 16, height = 16},
    {'Menu/SimpleSliderNTickbox', 6, padding = 2, width = 16, height = 16},
    {'Inventory/InvMissileL1'}
  }
  Hud.visible = false
end

MainMenu.functions = {

load = function (self)
  self.menus = {
    -- Menu1: New Game (draw tipbox), Load Game, Game Settings
    {
      items = {
        {
          -- New Game
          sprite = "Menu/SimpleMenuBox",
          x = 50,
          y = 50,
          scale = textScale,
          image_index = 0,
          -- Whether cursor can point at item and how to point
          -- (left means to the left side of item)
          cursorable = {xoff = - 20, yoff = 0},
          -- What to do when selected
          action = function (self, menuHandler)
            menuHandler.currentMenu = 3 -- Name new save game/confirm new
          end,
          drawMe = function(self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self)
            local x, y = self.x, self.y
            horizontal_menuBox(self, x, y, 5)

            setFont(font.prstartk)
            love.graphics.print("New Game", x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)

            -- TipBox
            if tipboxTip ~= "" then
              normal_menuBox(self, tipboxX, tipboxY, tipboxRepeats, tipboxRepeatsH)
              setFont(font.prstartk)
              love.graphics.print("Tip:\n\n" .. tipboxTip, tipboxX, tipboxY, 0, 0.5, 0.5, 0, 8)
              setFont(font.default)
            end
          end
        },
        {
          -- Load Game
          sprite = "Menu/SimpleMenuBox",
          x = 50,
          y = 100,
          scale = textScale,
          image_index = 1,
          cursorable = {xoff = - 20, yoff = 0},
          -- What to do when selected
          action = function (self, menuHandler)
            local saves = love.filesystem.getDirectoryItems("/Saves")

            if saves[1] then
              menuHandler.currentMenu = 2
              menuHandler.menus[menuHandler.currentMenu]:make_items(menuHandler, saves)
            end
          end,
          drawMe = function(self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self)
            local x, y = self.x, self.y
            horizontal_menuBox(self, x, y, 6)

            setFont(font.prstartk)
            love.graphics.print("Load Game", x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        },
        {
          -- Game Settings
          sprite = "Menu/SimpleMenuBox",
          x = 50,
          y = 150,
          scale = textScale,
          image_index = 1,
          cursorable = {xoff = - 20, yoff = 0},
          -- What to do when selected
          action = function (self, menuHandler)
            menuHandler.currentMenu = 5
          end,
          drawMe = function(self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self)
            local x, y = self.x, self.y
            horizontal_menuBox(self, x, y, 9)

            setFont(font.prstartk)
            love.graphics.print("Game Settings", x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        }
      },
      cursor = {
        pos = 1,
        sprite = "Inventory/InvMissileL1"
      }
    },
    -- Menu2: Save files
    {
      make_items = function (self, menuHandler, saves)
        self.items = self.items or {}
        self.itemDistance = 50
        local itemDistance = self.itemDistance
        for i, saveName in ipairs(saves) do
          saveName = u.utf8_backspace(saveName, 4)
          local saveNameScale = textScale
          local saveX = 250
          insertItem = true
          for _, item in ipairs(self.items) do
            if item.saveName == saveName then insertItem = false end
          end
          if insertItem then
            -- Add item to items
            table.insert(self.items,
            {
              -- Save item
              repeats = math.floor(font.prstartk:getWidth(saveName) * saveNameScale / 16),
              saveName = saveName,
              sprite = "Menu/SimpleMenuBox",
              x = saveX,
              y = itemDistance * (i + 1),
              scale = saveNameScale,
              cursorable = {xoff = - 20, yoff = 0},
              action = function (self)
                menuHandler.currentMenu = 4
                menuHandler.menus[menuHandler.currentMenu].saveName = saveName
              end,
              drawMe = function(self, image_index, x, y)
                typical_drawMe(self.sprite, image_index, x, y)
              end,
              -- Custom Draw
              draw = function (self)
                local gxo, gyo =
                self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
                local x, y = self.x + gxo, self.y + gyo
                horizontal_menuBox(self, x, y, self.repeats)

                setFont(font.prstartk)
                love.graphics.print(saveName, x, y, 0, self.scale, self.scale, 0, 8)
                setFont(font.default)
              end
              }
            )
          else
            -- Or make sure that existing items stay arranged properly
            self.items[i].y = itemDistance * (i + 1)
          end
        -- table.insert(self.items, {
        --   x = saveX,
        --   draw = function (self)
        --     -- If I want to draw a line, it must be at least THAT long (seen below)
        --     --self.menu.maxSaveNameLength + self.x + 16
        --   end
        -- })
        self.maxSaveNameLength = math.max(self.items[i].repeats or 0, self.maxSaveNameLength or 0)
        end
        self.maxSaveNameLength = self.maxSaveNameLength * 16
        handle_relations(self)
      end,
      cursor = {
        update = function (self, menuHandler, dt)
          self.menu.globalXOffset = 0
          self.menu.globalYOffset = (1 - self.pos) * 50
        end,
        pos = 1,
        sprite = "Inventory/InvMissileL1"
      }
    },
    -- Menu3: Confirm New Game/Name new save file
    {
      items = {
        {
          sprite = "Menu/SimpleMenuBox",
          x = 350,
          y = 150,
          repeats = 14,
          repeatsH = 5,
          scale = 0.5,
          text = "Name your save game:",
          feedbackText = "",
          feedbackCounter = 0,
          load = function()
            text.input = ""
            text.inputLim = 19
          end,
          update = function (self, menuHandler, dt)

            if self.feedbackCounter > 0 then
              self.feedbackCounter = self.feedbackCounter - dt
            else
              self.feedbackText = ""
            end

            if menuHandler.enterPressed and text.input ~= "" then
              local saveNameInput = "Saves/" .. text.input .. ".lua"
              -- Check if file exists already
              if verh.fileExists(saveNameInput) then
                self.feedbackText = "\nName already exists!"
                self.feedbackCounter = 1.2
              else
                -- Attempt to create file
                local newFile = love.filesystem.newFile(saveNameInput)
                newFile:close()
                local success = love.filesystem.write(saveNameInput, "local save = {}")
                if not success then
                  self.feedbackText = "\nFailed to make save!"
                  self.feedbackCounter = 1.2
                else
                  love.filesystem.append(saveNameInput, "\nreturn save")
                  -- Go to starting room
                  start_game(text.input)
                end
              end

              -- Make it nil to make sure that next menu doesn't also get activated
              menuHandler.enterPressed = nil
            end
          end,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self)
            local x, y = self.x, self.y
            normal_menuBox (self, x, y, self.repeats, self.repeatsH)

            setFont(font.prstartk)
            love.graphics.print(self.text .. self.feedbackText, x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.prstart)
            love.graphics.print(text.input, x, y + 30, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        }
      }
    },
    -- Menu4: Load save or erase save
    {
      items = {
        {
          -- MenuBox
          sprite = "Menu/SimpleMenuBox",
          x = 300,
          y = 133,
          text = "What do you want to do?",
          feedbackText = "",
          feedbackCounter = 0,
          repeats = 16,
          repeatsH = 8,
          scale = 0.5,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self)
            local x, y = self.x, self.y
            normal_menuBox (self, x, y, self.repeats, self.repeatsH)

            setFont(font.prstartk)
            love.graphics.print(self.text .. self.feedbackText, x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        },
        {
          -- Load Save
          x = 350,
          y = 183,
          text = "Load",
          scale = 0.5,
          cursorable = {xoff = - 20, yoff = 0},
          action = function (self, menuHandler)
            start_game(self.menu.saveName)
          end,
          draw = function (self)
            local x, y = self.x, self.y
            setFont(font.prstartk)
            love.graphics.print(self.text, x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        },
        {
          -- Erase Save
          x = 350,
          y = 233,
          text = "Erase",
          scale = 0.5,
          cursorable = {xoff = - 20, yoff = 0},
          action = function (self, menuHandler)
            menuHandler.currentMenu = 1
            self.menu.cursor.pos = 1
            local loadMenu = menuHandler.menus[2]
            local itemDistance = loadMenu.itemDistance
            for i, item in ipairs(loadMenu.items) do
              if item.saveName == self.menu.saveName then
                table.remove(loadMenu.items, i)
                love.filesystem.remove("Saves/" .. item.saveName .. ".lua")
                loadMenu.cursor.pos = 1
              end
            end
          end,
          draw = function (self)
            local x, y = self.x, self.y
            setFont(font.prstartk)
            love.graphics.print(self.text, x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        }
      },
      cursor = {
        pos = 1,
        sprite = "Inventory/InvMissileL1"
      }
    },
    -- Menu5: Game Settings
    {
      items = {
        {
          -- Game settings loader
          load = function (self, menuHandler)
            load_gs_to_temp(menuHandler, gs)
          end,
          draw = function (self)
          end
        },
        {
          -- Missile limit
          x = 250,
          y = 150,
          scale = 0.5,
          sprite = "Menu/SimpleMenuBox",
          sprite2 = "Menu/SimpleSliderNTickbox",
          repeats = 17,
          sliderRepeats = 4,
          cursorable = {xoff = - 20, yoff = 0},
          slider = 0.5,
          mslLimMin = 10,
          mslLimMax = 700,
          load = function (self, menuHandler)
            set_up_normal_slider(self, menuHandler.tempGs.mslLim, self.mslLimMin, self.mslLimMax)
          end,
          slide = function (self, menuHandler, sliderImpulse)
            typical_slide(self, "mslLim", self.mslLimMin, self.mslLimMax, menuHandler, sliderImpulse)
          end,
          preciseSlide = function (self, menuHandler, sliderImpulse)
            typical_preciseSlide(self, "mslLim", self.mslLimMin, self.mslLimMax, menuHandler, sliderImpulse)
          end,
          drawMe = function(self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          drawMe2 = function(self, image_index, x, y)
            typical_drawMe(self.sprite2, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self, menuHandler)
            local gxo, gyo =
            self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
            local x, y = self.x + gxo, self.y + gyo

            -- MenuBox
            horizontal_menuBox(self, x, y, self.repeats)

            -- Slider
            normal_slider(self, x, y, self.sliderRepeats, 230)

            setFont(font.prstartk)
            love.graphics.print("Bullets limit: " .. menuHandler.tempGs.mslLim, x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        },
        {
          -- Music
          sprite = "Menu/SimpleMenuBox",
          sprite2 = "Menu/SimpleSliderNTickbox",
          cursorable = {xoff = - 20, yoff = 0},
          x = 250,
          y = 200,
          scale = 0.5,
          repeats = 15,
          checkmark = 0, -- 0 = unchecked, 1 = checked
          load = function (self, menuHandler)
            self.checkmark = menuHandler.tempGs.musicOn and 1 or 0
          end,
          action = function (self, menuHandler)
            if menuHandler.tempGs.musicOn then
              menuHandler.tempGs.musicOn = false
            else
              menuHandler.tempGs.musicOn = true
            end
            self.checkmark = menuHandler.tempGs.musicOn and 1 or 0
          end,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          drawMe2 = function (self, image_index, x, y)
            typical_drawMe(self.sprite2, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self, menuHandler)
            local gxo, gyo =
            self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
            local x, y = self.x + gxo, self.y + gyo

            -- MenuBox
            horizontal_menuBox(self, x, y, self.repeats)

            -- Text
            setFont(font.prstartk)
            love.graphics.print("Music: ", x, y, 0, self.scale, self.scale, 0, 8)
            self:drawMe2(4+self.checkmark, x + 250, y)
            setFont(font.default)
          end
        },
        {
          -- Sounds
          sprite = "Menu/SimpleMenuBox",
          sprite2 = "Menu/SimpleSliderNTickbox",
          cursorable = {xoff = - 20, yoff = 0},
          x = 250,
          y = 250,
          scale = 0.5,
          repeats = 15,
          checkmark = 0, -- 0 = unchecked, 1 = checked
          load = function (self, menuHandler)
            self.checkmark = menuHandler.tempGs.soundsOn and 1 or 0
          end,
          action = function (self, menuHandler)
            if menuHandler.tempGs.soundsOn then
              menuHandler.tempGs.soundsOn = false
            else
              menuHandler.tempGs.soundsOn = true
            end
            self.checkmark = menuHandler.tempGs.soundsOn and 1 or 0
          end,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          drawMe2 = function (self, image_index, x, y)
            typical_drawMe(self.sprite2, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self, menuHandler)
            local gxo, gyo =
            self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
            local x, y = self.x + gxo, self.y + gyo

            -- MenuBox
            horizontal_menuBox(self, x, y, self.repeats)

            -- Text
            setFont(font.prstartk)
            love.graphics.print("Sounds: ", x, y, 0, self.scale, self.scale, 0, 8)
            self:drawMe2(4+self.checkmark, x + 250, y)
            setFont(font.default)
          end
        },
        {
          -- Fullscreen
          sprite = "Menu/SimpleMenuBox",
          sprite2 = "Menu/SimpleSliderNTickbox",
          cursorable = {xoff = - 20, yoff = 0},
          x = 250,
          y = 300,
          scale = 0.5,
          repeats = 15,
          checkmark = 0, -- 0 = unchecked, 1 = checked
          tipText =
            "Press F11 to switch\n\z
            between Fullscreen\n\z
            and windowed modes.",
          load = function (self, menuHandler)
            self.checkmark = menuHandler.tempGs.fullscreen and 1 or 0
          end,
          action = function (self, menuHandler)
            if menuHandler.tempGs.fullscreen then
              menuHandler.tempGs.fullscreen = false
            else
              menuHandler.tempGs.fullscreen = true
            end
            self.checkmark = menuHandler.tempGs.fullscreen and 1 or 0
          end,
          tip = function (self)
            if tipboxTip ~= self.tipText then tipboxTip = self.tipText end
            tipboxRepeats = 13
            tipboxRepeatsH = 4
          end,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          drawMe2 = function (self, image_index, x, y)
            typical_drawMe(self.sprite2, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self, menuHandler)
            local gxo, gyo =
            self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
            local x, y = self.x + gxo, self.y + gyo

            -- MenuBox
            horizontal_menuBox(self, x, y, self.repeats)

            -- Text
            setFont(font.prstartk)
            love.graphics.print("Fullscreen on start: ", x, y, 0, self.scale, self.scale, 0, 8)
            self:drawMe2(4+self.checkmark, x + 250, y)
            setFont(font.default)
          end
        },
        {
          -- Key config
          sprite = "Menu/SimpleMenuBox",
          cursorable = {xoff = - 20, yoff = 0},
          x = 250,
          y = 350,
          scale = 0.5,
          repeats = 7,
          action = function (self, menuHandler)
            menuHandler.currentMenu = 6
          end,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self, menuHandler)
            local gxo, gyo =
            self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
            local x, y = self.x + gxo, self.y + gyo

            -- MenuBox
            horizontal_menuBox(self, x, y, self.repeats)

            -- Text
            setFont(font.prstartk)
            love.graphics.print("Key config", x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        },
        {
          -- Restore defaults
          sprite = "Menu/SimpleMenuBox",
          cursorable = {xoff = - 20, yoff = 0},
          x = 250,
          y = 400,
          scale = 0.5,
          repeats = 11,
          action = function (self, menuHandler)
            local gsdefs = require "game_settings_defaults"
            load_gs_to_temp(menuHandler, gsdefs)
            change_game_settings(menuHandler)
          end,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self, menuHandler)
            local gxo, gyo =
            self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
            local x, y = self.x + gxo, self.y + gyo

            -- MenuBox
            horizontal_menuBox(self, x, y, self.repeats)

            -- Text
            setFont(font.prstartk)
            love.graphics.print("Restore Defaults", x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        },
        {
          -- Save Changes
          sprite = "Menu/SimpleMenuBox",
          cursorable = {xoff = - 20, yoff = 0},
          x = 250,
          y = 450,
          scale = 0.5,
          repeats = 8,
          action = function (self, menuHandler)
            change_game_settings(menuHandler)
          end,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self, menuHandler)
            local gxo, gyo =
            self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
            local x, y = self.x + gxo, self.y + gyo

            -- MenuBox
            horizontal_menuBox(self, x, y, self.repeats)

            -- Text
            setFont(font.prstartk)
            love.graphics.print("Save Changes", x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
          end
        }
      },
      cursor = {
        update = function (self, menuHandler, dt)
          self.menu.globalXOffset = 0
          self.menu.globalYOffset = (1 - self.pos) * 50
        end,
        pos = 1,
        sprite = "Inventory/InvMissileL1"
      }
    },
    -- Menu6: Key config
    {
      items = {
        {
          sprite = "Menu/SimpleMenuBox",
          x = 250,
          y = 177,
          repeats = 19,
          scale = 0.5,
          keyNameTable = {"Up: ", "Right: ", "Left: ", "Down: ", "Start (aka space): ",
            "Item1 (aka a): ", "Item2 (aka s): ", "Item3 (aka d): ",
            "Item4 (aka z): ", "Item5 (aka x): ", "Item6 (aka c): "},
          keyTable = {"up", "right", "left", "down", "start",
            "a", "s", "d",
            "z", "x", "c"},
          load = function (self, menuHandler)
            text.key = ""
            self.keyCounter = 1
            self.instructionText = "Press Return to confirm key"
            self.currentKeyText = self.keyNameTable[self.keyCounter]
            self.repeatsH = 5
            menuHandler.tempKt = menuHandler.tempKt or {}
            menuHandler.tempKt.player1 = menuHandler.tempKt.player1 or {}
          end,
          update = function (self, menuHandler, dt)
            if self.keyCounter <= #self.keyTable then
              if menuHandler.enterPressed and text.key ~= "" then
                menuHandler.tempKt.player1[self.keyTable[self.keyCounter]] = text.key
                self.keyCounter = self.keyCounter + 1
                self.currentKeyText = self.keyNameTable[self.keyCounter]
                text.key = ""
                if not self.currentKeyText then self.currentKeyText = "" end
              end
            else
              self.currentKeyText = nil
              self.repeatsH = 2
              self.instructionText = "Save keys?\nYes:[Return]  No:[Escape]"
              if menuHandler.enterPressed then
                change_key_config(menuHandler)
                menuHandler.currentMenu = 5
                inp.set_input(menuHandler.tempKt.player1)
              end
            end
          end,
          drawMe = function (self, image_index, x, y)
            typical_drawMe(self.sprite, image_index, x, y)
          end,
          -- Custom Draw
          draw = function (self, menuHandler)
            local x, y = self.x, self.y
            normal_menuBox (self, x, y, self.repeats, self.repeatsH)

            setFont(font.prstartk)
            love.graphics.print(self.instructionText, x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.prstart)
            if self.currentKeyText then
              love.graphics.print(self.currentKeyText .. text.key, x, y + 60, 0, self.scale, self.scale, 0, 8)
            end
            setFont(font.default)
          end
        }
      }
    }
  } -- Menus
  self.loadMenu = {}
  self.currentMenu = 1

  -- Find which Items the cursor can cycle through
  -- Go through each item of each menu, add stuff when needed
  for _, menu in ipairs(self.menus) do
    handle_relations(menu)
  end
end,

update = function (self, dt)
  -- Determine menu we're working on
  local currMenu = self.menus[self.currentMenu]
  if not currMenu then return end

  for _, item in ipairs(currMenu.items) do
    if item.update then
      item:update(self, dt)
    end
  end

  -- Check input
  self.prevUp = input.upPrevious
  self.up = input.up
  self.upPressed = input.upPressed

  self.prevDown = input.downPrevious
  self.down = input.down
  self.downPressed = input.downPressed

  self.prevLeft = input.leftPrevious
  self.left = input.left
  self.leftPressed = input.leftPressed

  self.prevRight = input.rightPrevious
  self.right = input.right
  self.rightPressed = input.rightPressed

  self.prevShift = self.shift
  self.shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
  self.shiftPressed = self.shift == true and self.shift ~= self.prevShift

  self.prevEnter = input.enterPrevious
  self.enter = input.enter
  self.enterPressed = input.enterPressed

  self.prevEscape = input.escapePrevious
  self.escape = input.escape
  self.escapePressed = input.escapePressed

  -- Act on input
  if self.escapePressed then
    self.currentMenu = backspaceMenu[self.currentMenu]
  end
  if currMenu.cursor then
    if currMenu.cursor.items[currMenu.cursor.pos].tip then
      currMenu.cursor.items[currMenu.cursor.pos]:tip(self)
    else
      tipboxTip = ""
    end
    if self.upPressed then
      currMenu.cursor.pos = currMenu.cursor.pos - 1
      if currMenu.cursor.pos < 1 then currMenu.cursor.pos = #currMenu.cursor.items end
    end
    if self.downPressed then
      currMenu.cursor.pos = currMenu.cursor.pos + 1
      if currMenu.cursor.pos > #currMenu.cursor.items then currMenu.cursor.pos = 1 end
    end
    if self.enterPressed then
      -- The following weird thing is just calling the
      -- action function of the item the cursor is pointing at
      if currMenu.cursor.items[currMenu.cursor.pos].action then
        currMenu.cursor.items[currMenu.cursor.pos]:action(self)
        -- Make it nil to make sure that next menu doesn't also get activated
        self.enterPressed = nil
        -- fuck = fuck + 1
      end
    end

    if not self.shift then
      if self.left or self.right then
        local sliderImpulse = 0
        if self.left then sliderImpulse = sliderImpulse - dt end
        if self.right then sliderImpulse = sliderImpulse + dt end
        -- The following weird thing is just calling the
        -- action function of the item the cursor is pointing at
        if currMenu.cursor.items[currMenu.cursor.pos].slide then
          currMenu.cursor.items[currMenu.cursor.pos]:slide(self, sliderImpulse)
        end
      end
    else
      if self.leftPressed or self.rightPressed then
        local sliderImpulse = 0
        if self.leftPressed then sliderImpulse = sliderImpulse - 1 end
        if self.rightPressed then sliderImpulse = sliderImpulse + 1 end
        -- The following weird thing is just calling the
        -- action function of the item the cursor is pointing at
        if currMenu.cursor.items[currMenu.cursor.pos].preciseSlide then
          currMenu.cursor.items[currMenu.cursor.pos]:preciseSlide(self, sliderImpulse)
        end
      end
    end

    if currMenu.cursor.update then currMenu.cursor:update(self, dt) end
  end

  -- Store which menus were being drawn
  self.menus_to_be_drawn_previous = self.menus_to_be_drawn
  -- Determine which menus are drawn
  self.menus_to_be_drawn = drawMenus[self.currentMenu]
end,

draw = function (self)
  for menuIndex, menu in ipairs(self.menus_to_be_drawn) do

    -- Determine which menus just started getting drawn
    self.loadMenu[menuIndex] = true
    if self.menus_to_be_drawn_previous then
      for _, prevMenu in ipairs(self.menus_to_be_drawn_previous) do
        if menu == prevMenu then self.loadMenu[menuIndex] = false end
      end
    end
    local drawMenu = self.menus[menu]

    -- Draw and load each item
    for _, item in ipairs(drawMenu.items) do

      if self.loadMenu[menuIndex] and item.load then
        item:load(self)
      end

      if not item.draw then
        local sprite = im.sprites[item.sprite]
        local frame = sprite[item.image_index]
        if sprite then
          love.graphics.draw(
          sprite.img, frame, item.x, item.y, item.angle or 0,
          sprite.res_x_scale, sprite.res_y_scale,
          sprite.cx, sprite.cy)
        end
      else
        item:draw(self)
      end
    end

    -- Draw cursor
    local drawCursor = drawMenu.cursor
    if drawCursor then
      local curItem = drawCursor.items[drawCursor.pos]
      local sprite = im.sprites[drawCursor.sprite]
      local frame = sprite[drawCursor.image_index or 0]

      local xoff, yoff = curItem.cursorable.xoff, curItem.cursorable.yoff
      local gxo, gyo =
      drawMenu.globalXOffset or 0, drawMenu.globalYOffset or 0

      love.graphics.draw(
      sprite.img, frame,
      curItem.x + xoff + gxo, curItem.y + yoff + gyo, curItem.angle or 0,
      sprite.res_x_scale, sprite.res_y_scale,
      sprite.cx, sprite.cy)
    end

  end
end,

trans_draw = function (self)
end
}

function MainMenu:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(MainMenu, instance, init) -- add own functions and fields
  return instance
end

return MainMenu
