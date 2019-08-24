-- This is a unique "room". It's not built like the others. It's more like an obj
-- It's also a hatchet job at best
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local im = require "image"
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
local layer = layerTable[layerIndex]
local drawTiles = {}
local drawSymbols = false

local camscale = 1

local tilesets = {
  im.spriteSettings.zeldarip,
  im.spriteSettings.floorOutside,
  im.spriteSettings.solidsOutside,
  im.spriteSettings.basicFriendlyInterior,
  index = 1
}

-- prepare room
local room = {room_parts = {}}
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
local tilesetUsable = false

-- Tilesets index to symbols
local tilesets_to_symbols = {}
tilesets_to_symbols['Tiles/FloorOutside'] = {
  'f', 'f', 'f', 'f', 'aF', 'n', 'n', 'aF', 'n', 'n',
  'f', 'f', 'f', 'f', 'f', 'f', 'g', 'n', 'b', 'st',
  'f', 'f', 'f', 'f', 'f', 'f', 'ga', 'ga', 'ld', 'n',
  'f', 'f', 'f', 'f', 'f', 'f', 'n', 'n', 'ld', 'n',
  'shW', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n',
  'wa', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n',
}
tilesets_to_symbols['Tiles/SolidsOutside'] = {
  'twnw', 'twu', 'twne', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'twl', 'w', 'twr', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'eL', 'eD', 'eR', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'twsw', 'twd', 'twse', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'n',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'sL', 'n',
  'w', 'd', 'w', 'w', 'd', 'w', 'w', 'd', 'w', 'n', 'n',
  'w', 'ptl', 'w', 'w', 'ptl', 'w', 'w', 'ptl', 'w', 'n', 'n',
}
tilesets_to_symbols['Tiles/BasicFriendlyInterior'] = {
  'w', 'w', 'w', 'w', 'w', 'n', 'n', 'n', 'n', 'n', 'n',
  'w', 'f', 'w', 'w', 'w', 'n', 'n', 'n', 'n', 'n', 'n',
  'w', 'w', 'w', 'w', 'w', 'n', 'n', 'n', 'n', 'n', 'n',
  'w', 'ptl', 'w', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n',
  'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n',
  'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n',
  'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n',
}
tilesets_to_symbols['Tiles/zeldarip'] = {
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'ld', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'ld', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f',
  'w', 'w', 'w', 'w', 'st', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f',
  'f', 'f', 'f', 'w', 'w', 'f', 'f', 'f', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'w', 'w', 'f', 'f', 'f', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'w', 'w', 'f', 'f', 'f', 'b', 'b', 'b', 'b', 'f', 'f', 'b', 'b',
  'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'b', 'b', 'b', 'b', 'f', 'f', 'b', 'b',
  'w', 'w', 'w', 'b', 'b', 'b', 'f', 'f', 'w', 'f', 'f', 'w', 'f', 'f', 'w', 'f',
  'w', 'ptl', 'w', 'w', 'ptl', 'w', 'f', 'f', 'w', 'f', 'w', 'f', 'f', 'f', 'f', 'f',
  'w', 'eD', 'w', 'w', 'eD', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'ptl', 'b', 'b', 'ga',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'sL', 'b', 'b', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'eD', 'b', 'b', 'b', 'b', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'ptl', 'w', 'w', 'w',
  'eD', 'b', 'b', 'b', 'b', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'w', 'w', 'w', 'w',
  'f', 'w', 'w', 'w', 'w', 'f', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w',
  'f', 'f', 'w', 'f', 'f', 'f', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w',
  'w', 'eD', 'w', 'w', 'eD', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'ptl', 'f', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'pl', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w',
  'w', 'eD', 'w', 'w', 'eD', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'ptl', 'f', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'eL', 'eR',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'w', 'f', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'ptl',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'b', 'ptl', 'b', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'deD', 'w',
  'w', 'f', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'deR', 'f', 'deL',
  'w', 'w', 'w', 'f', 'f', 'w', 'w', 'w', 'n', 'n', 'w', 'w', 'f', 'w', 'deU', 'w',
  'w', 'w', 'w', 'w', 'f', 'w', 'w', 'f', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w', 'w', 'eD', 'w', 'w', 'eD', 'w',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'ld',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'ptl', 'ga', 'w', 'w', 'w', 'w', 'w', 'ld',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w', 'ptl', 'w', 'w', 'w', 'w', 'w', 'ld',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w', 'f', 'w', 'f', 'ga', 'w', 'f', 'w',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w', 'f', 'f', 'f', 'w', 'f', 'f', 'w',
  'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'w', 'w', 'n', 'f', 'f', 'f', 'f',
  'w', 'w', 'w', 'w', 'f', 'f', 'f', 'w', 'f', 'f', 'f', 'n', 'f', 'f', 'f', 'f',
  'f', 'w', 'w', 'w', 'f', 'f', 'f', 'ptl', 'w', 'w', 'ptl', 'w', 'f', 'f', 'f', 'f',
  'w', 'eD', 'w', 'w', 'eD', 'w', 'b', 'b', 'w', 'w', 'w', 'f', 'f', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'eD', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'ptl', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'st', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'f', 'f', 'f', 'f', 'ptl', 'w', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'w', 'w', 'f', 'f', 'f', 'f', 'w', 'w', 'f', 'f', 'f', 'ga', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'f', 'f', 'f', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'ld',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'ld',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'f', 'f',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'ptl', 'ptl',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'ga', 'f', 'ptl', 'ptl',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'f', 'f', 'f', 'ptl', 'ptl',
  'f', 'f', 'f', 'w', 'w', 'f', 'f', 'f', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'f', 'f', 'f', 'w', 'w', 'f', 'f', 'f', 'w', 'w', 'w', 'w', 'w', 'ptl', 'sL', 'w',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'w', 'ptl', 'ptl', 'w', 'f', 'w', 'f', 'w',
  'f', 'f', 'f', 'w', 'w', 'b', 'b', 'b', 'sL', 'pl', 'n', 'n', 'n', 'n', 'n', 'n',
  'f', 'f', 'f', 'w', 'w', 'w', 'ptl', 'w', 'pl', 'pl', 'n', 'n', 'n', 'n', 'n', 'n',
  'f', 'f', 'f', 'w', 'w', 'w', 'w', 'ptl', 'g', 'n', 'n', 'n', 'n', 'n', 'n', 'n',
  'wa', 'n', 'n', 'wa', 'n', 'n', 'wa', 'n', 'n', 'shW', 'n', 'n', 'n', 'n', 'n', 'n',
  'aF2', 'n', 'n', 'n', 'aF2', 'n', 'n', 'n', 'aF2', 'n', 'n', 'n', 'aF2', 'n', 'n', 'n',
}

-- Functions always below vars, so they can recognise them
local function roomPartDrawFunctionsMaker(room_part)
  room_part.draw = function (self, drawinglayer)
    if self.layer ~= drawinglayer then return end
    local sx, sy = self.x_that_I_start, self.y_that_I_start
    local loaded_sprite = im.load_sprite({room_part.tileset[1]})
    for rpindex = 1, #self do
      if self[rpindex] ~= 'n' then
        love.graphics.draw(
          loaded_sprite.img,
          loaded_sprite[self.tileset_index_table[rpindex]],
          sx,
          sy
        )
      end
      sx = sx + self.tile_width
      if sx >= self.x_that_I_start + self.row_length * self.tile_width then
        sx, sy = self.x_that_I_start, sy + self.tile_width
      end
    end
  end
  room_part.drawSymbols = function (self, drawinglayer)
    if self.layer ~= drawinglayer then return end
    local sx, sy = self.x_that_I_start, self.y_that_I_start
    for rpindex = 1, #self do
      love.graphics.print(self[rpindex], sx, sy, 0, 0.5)
      sx = sx + self.tile_width
      if sx >= self.x_that_I_start + self.row_length * self.tile_width then
        sx, sy = self.x_that_I_start, sy + self.tile_width
      end
    end
  end
end

local function loadMap(mapName)
  room = require(mapName)
  mainCamera:setWorld(0, 0, room.width, room.height)
  for _, room_part in ipairs(room.room_parts) do
    local selflayer = room_part.layer
    if not selflayer then
      if room_part.init then
        selflayer = room_part.init.layer
      else
        selflayer = 10
      end
    end
    room_part.x_that_I_start = room_part.x_that_I_start - 8
    room_part.y_that_I_start = room_part.y_that_I_start - 8
    room_part.layer = selflayer
    roomPartDrawFunctionsMaker(room_part)
  end
  currentRoomPartIndex = 1
  currentRoomPart = room.room_parts[currentRoomPartIndex]
end

-- Save room to disk in useable format
local function SaveMap()
  local newfile = love.filesystem.newFile("new_room.lua")
  newfile:close()
  local success = love.filesystem.write("new_room.lua",
    "local rm = require(\"Rooms.room_manager\")\n\z
    local sh = require \"scaling_handler\"\n\z
    local im = require \"image\"\n\z
    \n\z
    local room = {}\n\z
    \n\z
    room.music_info ToBeADDED\n\z
    \n\z
    room.width = " .. room.width .. "\n\z
    room.height = " .. room.height .. "\n\z
    room.downTrans = {}ToBeADDED\n\z
    room.rightTrans = {}ToBeADDED\n\z
    room.leftTrans = {}ToBeADDED\n\z
    room.upTrans = {}ToBeADDED\n\z
    \n\z
    room.game_scale ToBeADDED\n\z
    \n\z
    room.room_parts = {}\n\z
    ----------Start of arrays of geography of parts of room----------\n")
  for _, rp in ipairs(room.room_parts) do
    local rpsymbols, rptileindex = "", ""
    for i, symbol in ipairs(rp) do
      rpsymbols = rpsymbols .. "'" .. symbol .. "', "
      local image_index = rp.tileset_index_table[i] or "nil"
      rptileindex = rptileindex .. image_index .. ", "
    end
    love.filesystem.append("new_room.lua",
    "---\n\z
    local room_part = {\n" ..
      rpsymbols .. "\n\z
    }\n\z
    room_part.x_that_I_start = " .. rp.x_that_I_start + 8 .. "\n\z
    room_part.y_that_I_start = " .. rp.y_that_I_start + 8 .. "\n\z
    room_part.row_length = " .. rp.row_length .. "\n\z
    room_part.col_length = " .. rp.col_length .. "\n\z
    room_part.tile_width = " .. rp.tile_width .. "\n\z
    room_part.init = {}\n\z
    room_part.init.layer = " .. rp.layer .. "\n\z
    room_part.tileset = " .. rp.tileset.positionstring .. "\n\z
    room_part.tileset_index_table = {\n"
      .. rptileindex .. "\n\z
    }\n\z
    \n\z
    table.insert(room.room_parts, room_part)\n"
  )
  end
  love.filesystem.append("new_room.lua",
  "----------End of arrays of geography of parts of room----------\n\z
  \n\z
  return room")
  if not success then love.errhand("Failed to write new_room") end
end

local function newRoomPart(partInfo)
  local room_part = {}
  room_part.x_that_I_start = partInfo[1] or 0
  room_part.y_that_I_start = partInfo[2] or 0
  room_part.tile_width = 16
  room_part.row_length = math.ceil(partInfo[3] / room_part.tile_width) or 1
  room_part.col_length = math.ceil(partInfo[4] / room_part.tile_width) or 1
  room_part.length = room_part.row_length * room_part.col_length
  room_part.init = partInfo.init
  room_part.layer = layer
  room_part.tileset = tilesets[tilesets.index]
  room_part.tileset_index_table = {}
  for i = 1, room_part.row_length * room_part.col_length do
    room_part[i] = 'n'
  end
  if not room.hasRoomParts then
    room.hasRoomParts = true
    tileset.name = tilesets[tilesets.index][1] -- [1] is the name field; a string
    room_part.first = true
  end
  roomPartDrawFunctionsMaker(room_part)
  local room_partIndex = u.push(room.room_parts, room_part)
  return room_part, room_partIndex
end

-- Return x, y and worldSlice of tile of mouse
local function getRoompartInfoOnPos(x, y)
  if not currentRoomPart then return -1, -1, -1 end
  local rpx = x - currentRoomPart.x_that_I_start
  local rpy = y - currentRoomPart.y_that_I_start
  local row = math.ceil(rpx / currentRoomPart.tile_width)
  local col = math.ceil(rpy / currentRoomPart.tile_width)
  if row > currentRoomPart.row_length or row < 1 then return -1, -1, -1 end
  if col > currentRoomPart.col_length or col < 1 then return -1, -1, -1 end
  local index = (currentRoomPart.row_length * (col - 1)) + row
  return index, row, col
end

local states = {
  initial = {
    update = function (self, dt)
      text.inputLim = 999
      fbTxt = "room name to load room"
      if enterP then
        if text.input == "" then self.state = "getW"; fbTxt = "Give room width and height in order"
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
        room.width = tonumber(text.input) or 100
        text.input = ""
        room.width = math.floor(room.width / 16) * 16
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
        room.height = tonumber(text.input) or 100
        room.height = math.floor(room.height / 16) * 16
        text.input = ""
        fbTxt = "room.height set to " .. room.height
        mainCamera:setWorld(0, 0, room.width, room.height)
        currentRoomPart, currentRoomPartIndex = newRoomPart{0, 0, room.width, room.height}
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(text.input, 400, 50)
      love.graphics.print(fbTxt, 400)
    end
  },

  building = {
    update = function (self, dt)
      if rP then
        self.state = "roomPartOptions"
        fbTxt = "r to add room part. d to delete room part"
      end
      -- Change room part
      if cP then
        currentRoomPartIndex = currentRoomPartIndex + 1
        if currentRoomPartIndex > #room.room_parts then currentRoomPartIndex = 1 end
        currentRoomPart = room.room_parts[currentRoomPartIndex]
      end
      fuck = #room.room_parts
    end,

    noCamDraw = function (self)
      love.graphics.print(fbTxt, 400)
    end
  },

  roomPartOptions = {
    update = function (self, dt)
      if rP then
        self.state = "getNewRoomPartW"
        text.input = ""
        fbTxt = "Input dimensions"
      end
      if dP then
        if not currentRoomPart.first then
          table.remove(room.room_parts, currentRoomPartIndex)
          currentRoomPartIndex = 1
          currentRoomPart = room.room_parts[currentRoomPartIndex]
        else
          fbTxt = "Cannot delete initial room part"
        end
        self.state = "building"
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(fbTxt, 400)
    end
  },

  getNewRoomPartW = {
    update = function (self, dt)
      if enterP then
        self.state = "getNewRoomPartH"
        newRPwidth = tonumber(text.input) or 100
        text.input = ""
        fbTxt = "room part rows set to " .. newRPwidth
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(text.input, 400, 50)
      love.graphics.print(fbTxt, 400)
    end
  },

  getNewRoomPartH = {
    update = function (self, dt)
      if enterP then
        self.state = "confirmNewRoomPart"
        newRPheight = tonumber(text.input) or 100
        text.input = ""
        fbTxt = "room part rows = " .. newRPwidth .. ", room part cols = " .. newRPheight ..
          "\nOk? r = yes, d = no (origin will be at mouse)"
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(text.input, 400, 50)
      love.graphics.print(fbTxt, 400)
    end
  },

  confirmNewRoomPart = {
    update = function (self, dt)
      if rP then
        self.state = "building"
        currentRoomPart, currentRoomPartIndex = newRoomPart{
          math.floor(worldMouseX / 16) * 16,
          math.floor(worldMouseY / 16) * 16,
          newRPwidth * 16, newRPheight * 16}
      end
      if dP then
        self.state = "building"
      end
    end,

    noCamDraw = function (self)
      love.graphics.print(text.input, 400, 50)
      love.graphics.print(fbTxt, 400)
    end
  }
}

local Re = {}

function Re.initialize(instance)
  instance.sprite_info = tilesets
  instance.state = "initial"
end

Re.functions = {
  load = function (self)
    self.tileset = self.sprite
    tileset.width = self.tileset.img:getWidth()
    tileset.height = self.tileset.img:getHeight()
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
    mouseIndex, tileMouseX, tileMouseY = getRoompartInfoOnPos(worldMouseX, worldMouseY)

    -- Check if room_part Layer and layer are the same and if room_part tileset is same as tileset
    if currentRoomPart and currentRoomPart.layer == layer then layerUsable = true else layerUsable = false end
    if currentRoomPart and currentRoomPart.tileset[1] == tileset.name then tilesetUsable = true else tilesetUsable = false end

    if fbTxtCounter > 5 then fbTxt = "" end
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
    if love.keyboard.isDown("lshift") then lshift = true else lshift = false end
    lshiftP = lshift and not lshiftpr
    lshiftpr = lshift
    if love.keyboard.isDown("n") then n = true else n = false end
    nP = n and not npr
    npr = n
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
      self.tileset = im.load_sprite({tileset.name})
      local selftileset = self.tileset
      tileset.width = selftileset.img:getWidth()
      tileset.height = selftileset.img:getHeight()
      tileset.index = 1
    end
    if lP then
      layerIndex = layerIndex + 1
      if layerIndex > #layerTable then layerIndex = 1 end
      layer = layerTable[layerIndex]
    end
    if gP then grid = not grid end
    if nP then drawSymbols = not drawSymbols end
    if tileset.name then
      if upP then tileset.index = tileset.index - tileset.width / tileset.size end
      if leftP then tileset.index = tileset.index - 1 end
      if downP then tileset.index = tileset.index + tileset.width / tileset.size end
      if rightP then tileset.index = tileset.index + 1 end
      local maxindex = tileset.width / tileset.size * tileset.height / tileset.size
      if tileset.index <= 0 then tileset.index = tileset.index + maxindex end
      if tileset.index > maxindex then tileset.index = tileset.index - maxindex end
    end
    if moub[1] then--moub["1press"] then
      if currentRoomPart and mouseIndex > 0 and layerUsable and tilesetUsable then
        -- if position is filled with tile, then
        if lshift then--currentRoomPart[mouseIndex] ~= 'n' then
          -- removeTile()
          currentRoomPart[mouseIndex] = 'n'
          currentRoomPart.tileset_index_table[mouseIndex] = nil
        else
          -- addTile()
          currentRoomPart[mouseIndex] = tilesets_to_symbols[tileset.name][tileset.index]
          currentRoomPart.tileset_index_table[mouseIndex] = tileset.index - 1
        end
      end
    end
    if moub["2press"] then
      mainCamera.xt, mainCamera.yt = mainCamera:toWorld(love.mouse.getPosition())
    end

    if states[self.state].update then states[self.state].update(self, dt) end

    if saveP then SaveMap() end
  end,

  draw = function (self)
    -- Draw room parts
    for _, rp in ipairs(room.room_parts) do
      for _, drawinglayer in ipairs(layerTable) do
        rp:draw(drawinglayer)
        if drawSymbols then rp:drawSymbols(drawinglayer) end
      end
    end
    -- Draw grid
    if currentRoomPart and grid then
      for j = 1, currentRoomPart.col_length do
        love.graphics.line(
          currentRoomPart.x_that_I_start,
          currentRoomPart.y_that_I_start + j * currentRoomPart.tile_width,
          currentRoomPart.x_that_I_start + currentRoomPart.row_length * currentRoomPart.tile_width,
          currentRoomPart.y_that_I_start + j * currentRoomPart.tile_width
        )
      end
      fuck = currentRoomPart.tile_width--*currentRoomPart.row_length
      for i = 1, currentRoomPart.row_length do
        love.graphics.line(
          currentRoomPart.x_that_I_start + i * currentRoomPart.tile_width,
          currentRoomPart.y_that_I_start,
          currentRoomPart.x_that_I_start + i * currentRoomPart.tile_width,
          currentRoomPart.y_that_I_start + currentRoomPart.col_length * currentRoomPart.tile_width
        )
      end
    end
  end,

  noCamDraw = function (self)
    -- Show the selected tile
    local selectyOffset = 0
    local twidth = tileset.width
    if tileset.name then
      local selectx, selecty = 0, 0
      local tsize, tindex, twidth = tileset.size, tileset.index, tileset.width
      selectx = (tindex - 1) * tsize
      while selectx >= twidth do
        selectx = selectx - twidth
        selecty = selecty + tsize
      end
      while selecty - selectyOffset > love.graphics.getHeight() * 0.5 do
        selectyOffset = selectyOffset + love.graphics.getHeight() * 0.25
      end
      selecty = selecty - selectyOffset
      local pr, pg, pb, pa = love.graphics.getColor()
      love.graphics.setColor(COLORCONST, 0, 0, COLORCONST)
      love.graphics.rectangle(
      "line",
      selectx,
      selecty,
      tsize,
      tsize)
      love.graphics.setColor(pr, pg, pb, pa)
    end
    -- Show the tileset. If not same as roompart tile set, make transparent
    local pr, pg, pb, pa = love.graphics.getColor()
    local alpha
    if tilesetUsable then alpha = 1 else alpha = 0.2 end
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST * alpha)
    love.graphics.draw(self.tileset.img, 0, - selectyOffset)
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.print(worldMouseX, love.graphics.getWidth()-100)
    love.graphics.print(worldMouseY, love.graphics.getWidth()-100, 50)
    love.graphics.print(mouseIndex, love.graphics.getWidth()-100, 100)
    love.graphics.print(tileMouseX, love.graphics.getWidth()-100, 150)
    love.graphics.print(tileMouseY, love.graphics.getWidth()-100, 200)
    if currentRoomPart then
      love.graphics.print("rpx:" .. currentRoomPart.x_that_I_start, twidth, 0)
      love.graphics.print("rpy:" .. currentRoomPart.y_that_I_start, twidth, 25)
      love.graphics.print("rpr:" .. currentRoomPart.row_length, twidth, 50)
      love.graphics.print("rpc:" .. currentRoomPart.col_length, twidth, 75)
      love.graphics.print("rptile:" .. currentRoomPart.tileset[1], twidth, 100)
      love.graphics.print("camscale:" .. camscale, twidth, 150)
    end
    -- Show layer. If not same as roompart tile set, make transparent
    if layerUsable then alpha = 1 else alpha = 0.2 end
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST * alpha)
    love.graphics.print("Layer:" .. layer, twidth, 350)
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
