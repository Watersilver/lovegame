local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local im = require "image"
local font = require "font"

local textScale = 0.5

-- Table that returns what menus to draw based on current menu
local drawMenus = {{1}, {1,2}}

-- Table that returnes which menu you end up on when pressin backspace
local backspaceMenu = {1, 1}

local function handle_relations(menu)
  menu.cursor.menu = menu

  menu.cursor.items = {}
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

local setFont = love.graphics.setFont

local MainMenu = {}

function MainMenu.initialize(instance)
  instance.sprite_info = {
    {'Menu/SimpleMenuBox', 4, 3, padding = 2, width = 16, height = 16},
    {'Inventory/InvMissileL1'}
  }
end

MainMenu.functions = {

load = function (self)
  self.menus = {
    -- Menu1: New Game, Load Game, Game Settings
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
          action = function ()
            -- game.room = assert(love.filesystem.load("Rooms/room0.lua"))()
            game.transition{
              type = "whiteScreen",
              progress = 0,
              roomTarget = "Rooms/room0.lua"
            }
          end,
          drawMe = function(self, image_index, x, y)
            local sprite = im.sprites[self.sprite]
            local frame = sprite[image_index]
            love.graphics.draw(
            sprite.img, frame, x, y, 0,
            sprite.res_x_scale, sprite.res_y_scale,
            sprite.cx, sprite.cy)
          end,
          -- Custom Draw
          draw = function (self)
            local x, y = self.x, self.y
            local repeats = 5
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

            setFont(font.prstartk)
            love.graphics.print("New Game", x, y, 0, self.scale, self.scale, 0, 8)
            setFont(font.default)
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
            local sprite = im.sprites[self.sprite]
            local frame = sprite[image_index]
            love.graphics.draw(
            sprite.img, frame, x, y, 0,
            sprite.res_x_scale, sprite.res_y_scale,
            sprite.cx, sprite.cy)
          end,
          -- Custom Draw
          draw = function (self)
            local x, y = self.x, self.y
            local repeats = 6
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
          drawMe = function(self, image_index, x, y)
            local sprite = im.sprites[self.sprite]
            local frame = sprite[image_index]
            love.graphics.draw(
            sprite.img, frame, x, y, 0,
            sprite.res_x_scale, sprite.res_y_scale,
            sprite.cx, sprite.cy)
          end,
          -- Custom Draw
          draw = function (self)
            local x, y = self.x, self.y
            local repeats = 9
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
        self.items = {}
        for i, saveName in ipairs(saves) do
          local saveNameScale = textScale
          local saveX = 250
          table.insert(self.items,
          {
            -- Save item
            repeats = math.floor(font.prstartk:getWidth(saveName) * saveNameScale / 16),
            saveName = saveName,
            sprite = "Menu/SimpleMenuBox",
            x = saveX,
            y = 50 * (i + 1),
            scale = saveNameScale,
            cursorable = {xoff = - 20, yoff = 0},
            drawMe = function(self, image_index, x, y)
              local sprite = im.sprites[self.sprite]
              local frame = sprite[image_index]
              love.graphics.draw(
              sprite.img, frame, x, y, 0,
              sprite.res_x_scale, sprite.res_y_scale,
              sprite.cx, sprite.cy)
            end,
            -- Custom Draw
            draw = function (self)
              local gxo, gyo =
              self.menu.globalXOffset or 0, self.menu.globalYOffset or 0
              local x, y = self.x + gxo, self.y + gyo
              local repeats = self.repeats
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

              setFont(font.prstartk)
              love.graphics.print(saveName, x, y, 0, self.scale, self.scale, 0, 8)
              setFont(font.default)
            end
          }
        )
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
    }
  }
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

  -- Check input
  self.prevUp = self.up
  self.up = love.keyboard.isDown("up")
  self.upPressed = self.up == true and self.up ~= self.prevUp

  self.prevDown = self.down
  self.down = love.keyboard.isDown("down")
  self.downPressed = self.down == true and self.down ~= self.prevDown

  self.prevEnter = self.enter
  self.enter = love.keyboard.isDown("return")
  self.enterPressed = self.enter == true and self.enter ~= self.prevEnter

  self.prevBackspace = self.backspace
  self.backspace = love.keyboard.isDown("backspace")
  self.backspacePressed = self.backspace == true and self.backspace ~= self.prevBackspace

  -- Act on input
  if self.backspacePressed then
    self.currentMenu = backspaceMenu[self.currentMenu]
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
    end
  end

  if currMenu.cursor.update then currMenu.cursor:update(self, dt) end

  self.menus_to_be_drawn = drawMenus[self.currentMenu]
end,

draw = function (self)
  for _, menu in ipairs(self.menus_to_be_drawn) do
    local drawMenu = self.menus[menu]

    -- Draw each item
    for _, item in ipairs(drawMenu.items) do
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
