local rm = require("Rooms.room_manager")
local sh = require "scaling_handler"
local im = require "image"

local room = {}

room.music_info = {"music/MusicTest"}

room.width = 800
room.height = 350

-- mainCamera:setWorld(0, 0, room.width, room.height)

room.downTrans = {
  -- {
  --   roomTarget = "Rooms/room1.lua", -- Room you'll go to if this transition happens
  --   xleftmost = 0, yrightmost = 800, -- Limits to check against
  --   xmod = 0, ymod = 0 -- Modification of x, y variables for next room
  -- }
}
room.rightTrans = {
  -- {
  --   roomTarget = "Rooms/room1.lua", -- Room you'll go to if this transition happens
  --   yupper = 0, ylower = 450, -- Limits to check against
  --   xmod = 0, ymod = 0 -- Modification of x, y variables for next room
  -- }
}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 2

room.room_parts = {}

----------Start of arrays of geography of parts of room----------
local room_part = {
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
}
room_part.x_that_I_start = 116
room_part.y_that_I_start = 160
room_part.row_length = 15
room_part.col_length = #room_part/room_part.row_length
room_part.tile_width = 16
room_part.tileset = im.spriteSettings.floorOutside
room_part.tileset_index_table = {
  0, 0, 14, 0, 14, 0, 0, 14, 0, 0, 3, 15, 2, 15, 2,
  14, 2, 3, 15, 2, 15, 2, 0, 3, 0, 0, 14, 0, 14, 0,
  0, 3, 15, 2, 0, 5, 3, 15, 2, 14, 0, 3, 15, 2, 12,
  0, 14, 0, 0, 14, 0, 0, 0, 14, 0, 0, 3, 11, 0, 14
}

table.insert(room.room_parts, room_part)
----------End of arrays of geography of parts of room----------


-- rm.build_room(room)


return room
