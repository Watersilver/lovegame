-- This is a unique "room". It's not built like the others. It's more like an obj
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local im = require "image"
local text = require "text"
local sh = require "scaling_handler"

-- Input
local up, down, left, right, s, sP, spr, enter, ernterP, enterpr, n, nP, npr,
  plus, minus, g, gP, gpr, r, rP, rpr

-- Feedback text
local fbTxt, fbTxtpr, fbTxtCounter = "", "", 0

-- Mouse
local mouseX, mouseY, tileMouseX, tileMouseY, worldMouseX, worldMouseY, mouseIndex
local moub = mouseB

local grid = true

local camscale = 1

local sprites = {
  im.spriteSettings.floorOutside,
  im.spriteSettings.solidsOutside
}
local sprCounter = 1

-- prepare room
local room = {room_parts = {}}
local currentRoomPart

-- Functions always below vars, so they can recognise them

local function newRoomPart(partInfo)
  local room_part = {}
  room_part.x_that_I_start = partInfo[1] or 0
  room_part.y_that_I_start = partInfo[2] or 0
  room_part.tile_width = 16
  room_part.row_length = math.ceil(partInfo[3] / room_part.tile_width) or 1
  room_part.col_length = math.ceil(partInfo[4] / room_part.tile_width) or 1
  room_part.length = room_part.row_length * room_part.col_length
  room_part.init = partInfo.init
  room_part.tileset = sprites[sprCounter]
  room_part.tileset_index_table = {}
  table.insert(room.room_parts, room_part)
  return room_part
end

-- Return x, y and worldSlice of tile of mouse
local function mousePosRoomPartIndex()
  if not currentRoomPart then return end
  local rpx = worldMouseX - currentRoomPart.x_that_I_start
  local rpy = worldMouseY - currentRoomPart.y_that_I_start
  local row = math.ceil(rpx / currentRoomPart.tile_width)
  local col = math.ceil(rpy / currentRoomPart.tile_width)
  local index = (currentRoomPart.row_length * (col - 1)) + row
  return index
end

local states = {
  initial = {
    update = function (self, dt)
      self.state = "getW"
    end
  },

  getW = {
    update = function (self, dt)
      if enterP then
        self.state = "getH"
        room.width = tonumber(text.input)
        text.input = ""
        fbTxt = "room.width set to " .. room.width
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(text.input, 400, 50)
      love.graphics.print(fbTxt, 400)
    end
  },

  getH = {
    update = function (self, dt)
      if enterP then
        self.state = "building"
        room.height = tonumber(text.input)
        text.input = ""
        fbTxt = "room.height set to " .. room.height
        mainCamera:setWorld(0, 0, room.width, room.height)
        currentRoomPart = newRoomPart{0, 0, room.width, room.height}
        currentRoomPart.first = true
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(text.input, 400, 50)
      love.graphics.print(fbTxt, 400)
    end
  },

  building = {
    update = function (self, dt)
      if rP then self.state = "addRoomPart" end
    end,

    noCamDraw = function (self)
      love.graphics.print(fbTxt, 400)
    end
  },
}

local Re = {}

function Re.initialize(instance)
  instance.sprite_info = sprites
  instance.state = "initial"
end

Re.functions = {
  load = function (self)
    self.tilesetW = self.sprite.img:getWidth()
    self.tilesetH = self.sprite.img:getHeight()
  end,

  update = function (self, dt)
    -- Handle feedback text
    if fbTxtpr ~= fbTxt then fbTxtCounter = 0 end
    fbTxtpr = fbTxt
    fbTxtCounter = fbTxtCounter + dt

    -- Handle Main camera
    if plus then camscale = camscale + dt end
    if minus then camscale = camscale - dt end
    sh.__set_total_scale(camscale)

    -- Store mouse position
    mouseX, mouseY = love.mouse.getPosition()
    worldMouseX, worldMouseY = mainCamera:toWorld(mouseX, mouseY)
    tileMouseX, tileMouseY = worldMouseX, worldMouseY
    mouseIndex = mousePosRoomPartIndex()

    if fbTxtCounter > 5 then fbTxt = "" end
    -- input
    if love.keyboard.isDown("up") then up = true else up = false end
    if love.keyboard.isDown("left") then left = true else left = false end
    if love.keyboard.isDown("down") then down = true else down = false end
    if love.keyboard.isDown("right") then right = true else right = false end
    if love.keyboard.isDown("=") then plus = true else plus = false end
    if love.keyboard.isDown("-") then minus = true else minus = false end
    if love.keyboard.isDown("s") then s = true else s = false end
    sP = s and not spr
    spr = s
    if love.keyboard.isDown("return") then enter = true else enter = false end
    enterP = enter and not enterpr
    enterpr = enter
    if love.keyboard.isDown("n") then n = true else n = false end
    nP = n and not npr
    npr = n
    if love.keyboard.isDown("g") then g = true else g = false end
    gP = g and not gpr
    gpr = g
    if love.keyboard.isDown("r") then r = true else r = false end
    rP = r and not rpr
    rpr = r

    -- act on input
    if sP then
      sprCounter = sprCounter + 1
      if sprCounter > #sprites then sprCounter = 1 end
      self.sprite = im.load_sprite({sprites[sprCounter][1]})
      local sprite = self.sprite
      self.tilesetW = sprite.img:getWidth()
      self.tilesetH = sprite.img:getHeight()
    end
    if gP then grid = not grid end
    if moub["1press"] then
      -- if position is filled with tile then
      --  remove tile
      -- else
      --  add tile
    end
    if moub["2press"] then
      mainCamera.xt, mainCamera.yt = mainCamera:toWorld(love.mouse.getPosition())
    end

    if states[self.state].update then states[self.state].update(self, dt) end
  end,

  draw = function (self)
    if currentRoomPart and grid then
      for j = 1, currentRoomPart.col_length do
        love.graphics.line(
          currentRoomPart.x_that_I_start,
          currentRoomPart.y_that_I_start + j * currentRoomPart.tile_width,
          currentRoomPart.row_length * currentRoomPart.tile_width,
          currentRoomPart.y_that_I_start + j * currentRoomPart.tile_width
        )
      end
      for i = 1, currentRoomPart.row_length do
        love.graphics.line(
          currentRoomPart.x_that_I_start + i * currentRoomPart.tile_width,
          currentRoomPart.y_that_I_start,
          currentRoomPart.x_that_I_start + i * currentRoomPart.tile_width,
          currentRoomPart.col_length * currentRoomPart.tile_width
        )
      end
    end
  end,

  noCamDraw = function (self)
    love.graphics.draw(self.sprite.img)
    love.graphics.print(worldMouseX, love.graphics.getWidth()-100)
    love.graphics.print(worldMouseY, love.graphics.getWidth()-100, 50)
    love.graphics.print(mouseIndex or 0, love.graphics.getWidth()-100, 100)
    if currentRoomPart then
      love.graphics.print("rpx:" .. currentRoomPart.x_that_I_start, 5, 175)
      love.graphics.print("rpy:" .. currentRoomPart.y_that_I_start, 5, 200)
      love.graphics.print("rpr:" .. currentRoomPart.row_length, 5, 225)
      love.graphics.print("rpc:" .. currentRoomPart.col_length, 5, 250)
      love.graphics.print("rptile:" .. currentRoomPart.tileset[1], 5, 275)
      love.graphics.print("camscale:" .. camscale, 5, 325)
    end

    if states[self.state].noCamDraw then states[self.state].noCamDraw(self, dt) end
  end
}

function Re:new(init)
local instance = p:new() -- add parent functions and fields
p.new(Re, instance, init) -- add own functions and fields
return instance
end

o.addToWorld(Re:new())

return Re
