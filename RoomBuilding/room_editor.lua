-- This is a unique "room". It's not built like the others. It's more like an obj
-- It's also a hatchet job at best
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local im = require "image"
local inp = require "input"
local text = require "text"
local sh = require "scaling_handler"
local u = require "utilities"

-- Input
local up, down, left, right, s, sP, spr, enter, ernterP, enterpr, n, nP, npr,
  plus, minus, g, gP, gpr, r, rP, rpr

-- Feedback text
local fbTxt, fbTxtpr, fbTxtCounter = "", "", 0

-- Mouse
local mouseX, mouseY, tileMouseX, tileMouseY, worldMouseX, worldMouseY, mouseIndex
local moub = mouseB

local grid = true

local layerUsable = false
local layerTable = {10, 11, 12, 30, 31, 32}
local layerIndex = 1
local drawTiles = {}
local drawSymbols = false

local camscale = 1

local tilesets = {
  im.spriteSettings.floor,
  im.spriteSettings.walls,
  im.spriteSettings.portals,
  im.spriteSettings.edges,
  im.spriteSettings.clutter,
  index = 1
}

-- prepare room
local room = {gameObjects = {}}
local currentRoomPart
local currentRoomPartIndex
local newRPwidth, newRPheight

-- Store info about tileset I'm working on
local tileset = {
  index = 1,
  name = nil,
  size = 20,
  width = 0,
  height = 0
}

local function loadMap(mapName)
  room = require("Rooms." .. mapName)
  mainCamera:setWorld(0, 0, room.width, room.height)
end

-- Save room to disk in useable format
local function SaveMap()
  local newfile = love.filesystem.newFile("new_room.lua")
  newfile:close()
  local success = love.filesystem.write("new_room.lua",
    "local rm = require(\"Rooms.room_manager\")\n\z
    local sh = require \"scaling_handler\"\n\z
    local im = require \"image\"\n\z
    local snd = require \"sound\"\n\z
    \n\z
    local room = {}\n\z
    room.newType = true\n\z
    \n\z
    room.music_info ToBeADDED -- = snd.ovrwrld1\n\z
    room.timeDoesntPass ToBeADDED\n\z
    room.timeScreenEffect ToBeADDED -- = 'default'\n\z
    \n\z
    room.width = " .. room.width .. "\n\z
    room.height = " .. room.height .. "\n\z
    room.downTrans = {}ToBeADDED\n\z
    room.rightTrans = {}ToBeADDED\n\z
    room.leftTrans = {}ToBeADDED\n\z
    room.upTrans = {}ToBeADDED\n\z
    \n\z
    room.game_scale ToBeADDED -- = 2\n\z
    \n\z
    room.gameObjects = {\n\z
    ----------Start of gameObjects----------\n")
    local gObjString = ""
    for _, gO in ipairs(room.gameObjects) do
      gObjString = gObjString ..
      "{ x = " .. gO.x .. ", \z
         y = " .. gO.y .. ", \z
         init = {layer = " .. gO.init.layer .. "}, \z
         tileset = " .. gO.tileset.positionstring .. ", \z
         index = " .. gO.index .. "\z
       },\n"
  end
  love.filesystem.append("new_room.lua",
  gObjString .. "----------End of gameObjects----------\n\z
  }\n\z
  return room")
  if not success then love.errhand("Failed to write new_room") end
end

-- Return x, y and worldSlice of tile of mouse
local function getRoompartInfoOnPos(x, y)
  local rpx = x
  local rpy = y
  if not room.width or (rpx >= room.width or rpx < 0) then return nil, nil end
  if not room.height or (rpy >= room.height or rpy < 0) then return nil, nil end
  return math.floor(rpx / 16), math.floor(rpy / 16)
end

local states = {
  initial = {
    update = function (self, dt)
      text.inputLim = 999
      fbTxt = "room name to load room or nothing for new"
      if enterP then
        if text.input == "" then self.state = "getW"; fbTxt = "Give room width and height in that order and in tiles"
        else loadMap(text.input); self.state = "building"
        end
        text.inputLim = 10
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(text.input, 400, 50)
      love.graphics.print(fbTxt, 400)
    end
  },

  getW = {
    update = function (self, dt)
      if enterP then
        self.state = "getH"
        room.width = tonumber(text.input) or 31
        text.input = ""
        -- room.width = math.floor(room.width / 16) * 16
        room.width = math.floor(room.width) * 16
        fbTxt = "collumns set to " .. room.width / 16
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
        room.height = tonumber(text.input) or 28
        -- room.height = math.floor(room.height / 16) * 16
        room.height = math.floor(room.height) * 16
        text.input = ""
        fbTxt = "rows set to " .. room.height / 16
        mainCamera:setWorld(0, 0, room.width, room.height)
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(text.input, 400, 50)
      love.graphics.print(fbTxt, 400)
    end
  },

  building = {
    update = function (self, dt)
      if moub[1] then--moub["1press"] then
        if tileMouseX and tileMouseY then
          local xquantized, yquantized = tileMouseX * 16 + 8, tileMouseY * 16 + 8
          if not inp.shift then
            -- remove previous tile
            for i=#room.gameObjects,1,-1 do
              local prevObj = room.gameObjects[i]
              if prevObj.init.layer == layerTable[layerIndex] and prevObj.x == xquantized and prevObj.y == yquantized then
                table.remove(room.gameObjects, i)
              end
            end
          end
          if not ctrl then
            -- addTile
            local newOb = {}
            newOb.x = xquantized
            newOb.y = yquantized
            newOb.init = {layer = layerTable[layerIndex]}
            newOb.tileset = tilesets[tilesets.index]
            newOb.index = tileset.index - 1
            table.insert(room.gameObjects, newOb)
          end
        end
      end
      if moub["2press"] then
        mainCamera.xt, mainCamera.yt = mainCamera:toWorld(love.mouse.getPosition())
      end

      if saveP then SaveMap() end
    end,

    noCamDraw = function (self)
      love.graphics.print(fbTxt, 400)
    end
  },
}

local Re = {}

function Re.initialize(instance)
  instance.sprite_info = tilesets
  instance.state = "initial"
end

Re.functions = {
  load = function (self)
    tileset.name = tilesets[tilesets.index][1]
    self.tileset = im.sprites[tileset.name]
    tileset.width = self.tileset.img:getWidth()
    tileset.height = self.tileset.img:getHeight()
    tileset.index = 1
  end,

  update = function (self, dt)
    -- Handle feedback text
    if fbTxtpr ~= fbTxt then fbTxtCounter = 0 end
    fbTxtpr = fbTxt
    fbTxtCounter = fbTxtCounter + dt
    if fbTxtCounter > 5 then fbTxt = "" end

    -- Handle Main camera
    if plus then camscale = camscale + dt end
    if minus then camscale = camscale - dt end
    sh.__set_total_scale(camscale)

    -- Store mouse position
    mouseX, mouseY = love.mouse.getPosition()
    worldMouseX, worldMouseY = mainCamera:toWorld(mouseX, mouseY)
    tileMouseX, tileMouseY = getRoompartInfoOnPos(worldMouseX, worldMouseY)

    -- input
    if love.keyboard.isDown("up") then up = true else up = false end
    upP = up and not uppr
    uppr = up
    if love.keyboard.isDown("left") then left = true else left = false end
    leftP = left and not leftpr
    leftpr = left
    if love.keyboard.isDown("down") then down = true else down = false end
    downP = down and not downpr
    downpr = down
    if love.keyboard.isDown("right") then right = true else right = false end
    rightP = right and not rightpr
    rightpr = right
    if love.keyboard.isDown("=") then plus = true else plus = false end
    if love.keyboard.isDown("-") then minus = true else minus = false end
    if love.keyboard.isDown("s") then s = true else s = false end
    sP = s and not spr
    spr = s
    if love.keyboard.isDown("c") then c = true else c = false end
    cP = c and not cpr
    cpr = c
    if love.keyboard.isDown("return") then enter = true else enter = false end
    enterP = enter and not enterpr
    enterpr = enter
    if love.keyboard.isDown("lctrl", "rctrl") then ctrl = true else ctrl = false end
    ctrlP = ctrl and not ctrlpr
    ctrlpr = ctrl
    if love.keyboard.isDown("g") then g = true else g = false end
    gP = g and not gpr
    gpr = g
    if love.keyboard.isDown("r") then r = true else r = false end
    rP = r and not rpr
    rpr = r
    if love.keyboard.isDown("d") then d = true else d = false end
    dP = d and not dpr
    dpr = d
    if love.keyboard.isDown("l") then l = true else l = false end
    lP = l and not lpr
    lpr = l

    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("s") then save = true else save = false end
    saveP = save and not savepr
    savepr = save

    -- act on input
    if sP then
      tilesets.index = tilesets.index + 1
      if tilesets.index > #tilesets then tilesets.index = 1 end
      tileset.name = tilesets[tilesets.index][1]
      self.tileset = im.sprites[tileset.name]
      tileset.width = self.tileset.img:getWidth()
      tileset.height = self.tileset.img:getHeight()
      tileset.index = 1
    end
    if lP then
      layerIndex = layerIndex + 1
      if layerIndex > #layerTable then layerIndex = 1 end
    end
    if gP then grid = not grid end
    if tileset.name then
      if upP then tileset.index = tileset.index - tileset.width / tileset.size end
      if leftP then tileset.index = tileset.index - 1 end
      if downP then tileset.index = tileset.index + tileset.width / tileset.size end
      if rightP then tileset.index = tileset.index + 1 end
      local maxindex = tileset.width / tileset.size * tileset.height / tileset.size
      if tileset.index <= 0 then tileset.index = tileset.index + maxindex end
      if tileset.index > maxindex then tileset.index = tileset.index - maxindex end
    end

    if states[self.state].update then states[self.state].update(self, dt) end
  end,

  draw = function (self)
    -- Draw room
    for _, obj in ipairs(room.gameObjects) do
      for _, drawinglayer in ipairs(layerTable) do
        if obj.init.layer == drawinglayer then
          local sprite = im.sprites[obj.tileset[1]]
          love.graphics.draw(sprite.img, sprite[obj.index], obj.x, obj.y, 0, 1, 1, 8, 8)
        end
      end
    end
    -- Draw grid
    if room.height and grid then
      for j = 0, room.height / 16 do
        love.graphics.line(
          0,
          j * 16,
          room.width,
          j * 16
        )
      end
      for i = 0, room.width / 16 do
        love.graphics.line(
          i * 16,
          0,
          i * 16,
          room.height
        )
      end
    end
  end,

  noCamDraw = function (self)
    -- Show the selected tile
    local selectyOffset = 0
    local twidth = tileset.width
    local selectx, selecty = 0, 0
    local tsize = tileset.size
    if tileset.name then
      local tindex, twidth = tileset.index, tileset.width
      selectx = (tindex - 1) * tsize
      while selectx >= twidth do
        selectx = selectx - twidth
        selecty = selecty + tsize
      end
      while selecty - selectyOffset > love.graphics.getHeight() * 0.5 do
        selectyOffset = selectyOffset + love.graphics.getHeight() * 0.25
      end
      selecty = selecty - selectyOffset
    end
    -- Show the tileset. If not same as roompart tile set, make transparent
    local pr, pg, pb, pa = love.graphics.getColor()
    local alpha
    alpha = 1
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST * alpha)
    love.graphics.draw(self.tileset.img, 0, - selectyOffset)
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.print(worldMouseX, love.graphics.getWidth()-100)
    love.graphics.print(worldMouseY, love.graphics.getWidth()-100, 50)
    love.graphics.print(tileMouseX or -1, love.graphics.getWidth()-100, 150)
    love.graphics.print(tileMouseY or -1, love.graphics.getWidth()-100, 200)
    if currentRoomPart then
      love.graphics.print("rpx:" .. currentRoomPart.x_that_I_start, twidth, 0)
      love.graphics.print("rpy:" .. currentRoomPart.y_that_I_start, twidth, 25)
      love.graphics.print("rpr:" .. currentRoomPart.row_length, twidth, 50)
      love.graphics.print("rpc:" .. currentRoomPart.col_length, twidth, 75)
      love.graphics.print("rptile:" .. currentRoomPart.tileset[1], twidth, 100)
      love.graphics.print("camscale:" .. camscale, twidth, 150)
    end
    -- Show layer. If not same as roompart tile set, make transparent
    alpha = 1
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST * alpha)
    love.graphics.print("Layer:" .. layerTable[layerIndex], twidth, 350)
    love.graphics.setColor(pr, pg, pb, pa)

    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(COLORCONST, 0, 0, COLORCONST * 0.5)
    love.graphics.rectangle(
    "fill",
    selectx,
    selecty,
    tsize,
    tsize)
    love.graphics.setColor(pr, pg, pb, pa)

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
