local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local im = require "image"

local MainMenu = {}

function MainMenu.initialize(instance)
  instance.sprite_info = {
    {'MainMenu/WhatAmI', 2, padding = 2},
    {'Inventory/InvMissileL1'}
  }
end

MainMenu.functions = {

load = function (self)
  self.menus = {
    -- Menu1
    {
      items = {
        {
          -- New Game
          sprite = "MainMenu/WhatAmI",
          x = 50,
          y = 50,
          image_index = 0,
          -- Whether cursor can point at item and how to point
          -- (left means to the left side of item)
          cursorable = "left",
          -- What to do when selected
          action = function ()
            -- game.room = assert(love.filesystem.load("Rooms/room0.lua"))()
            game.transition{
              type = "whiteScreen",
              progress = 0,
              roomTarget = "Rooms/room0.lua"
            }
          end
        },
        {
          -- Other
          sprite = "MainMenu/WhatAmI",
          x = 50,
          y = 100,
          image_index = 1,
          cursorable = "left"
        }
      },
      cursor = {
        pos = 1,
        sprite = "Inventory/InvMissileL1"
      }
    }
  }
  self.currentMenu = 1

  -- Find which Items the cursor can cycle through
  -- Go through each item of each menu
  for _, menu in ipairs(self.menus) do
    menu.cursor.items = {}
    for _, item in ipairs(menu.items) do

      -- If item can be pointed by cursor add it to cursor items
      if item.cursorable then
        table.insert(menu.cursor.items, item)
      end

    end
  end
end,

update = function (self, dt)
  -- Determine menu we're working on
  local currMenu = self.menus[self.currentMenu]

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

  -- Act on input
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
      currMenu.cursor.items[currMenu.cursor.pos].action()
    end
  end
end,

draw = function (self)
  for menu = 1, self.currentMenu do
    local drawMenu = self.menus[self.currentMenu]

    -- Draw each item
    for _, item in ipairs(drawMenu.items) do
      local sprite = im.sprites[item.sprite]
      local frame = sprite[item.image_index]
      if sprite then
        love.graphics.draw(
        sprite.img, frame, item.x, item.y, item.angle or 0,
        sprite.res_x_scale, sprite.res_y_scale,
        sprite.cx, sprite.cy)
      end
    end

    -- Draw cursor
    local drawCursor = drawMenu.cursor
    local curItem = drawCursor.items[drawCursor.pos]
    local sprite = im.sprites[drawCursor.sprite]
    local frame = sprite[drawCursor.image_index or 0]

    local xoffset, yoffset = 0, 0
    if curItem.cursorable == "left" then
      xoffset = - 20
    end

    love.graphics.draw(
    sprite.img, frame,
    curItem.x + xoffset, curItem.y + yoffset, curItem.angle or 0,
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
