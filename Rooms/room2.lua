local rm = require("Rooms.room_manager")
local sh = require "scaling_handler"
local im = require "image"

local room = {}

room.music_info = {"Silence"}

room.width = 500
room.height = 450

-- mainCamera:setWorld(0, 0, room.width, room.height)

room.downTrans = {}
room.rightTrans = {
  {
    roomTarget = "Rooms/room1.lua", -- Room you'll go to if this transition happens
    yupper = 0, ylower = 450, -- Limits to check against
    xmod = 0, ymod = 0 -- Modification of x, y variables for next room
  }
}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 2

room.room_parts = {}

----------Start of arrays of geography of parts of room----------
local room_part = {
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
}
room_part.x_that_I_start = 166
room_part.y_that_I_start = 110
room_part.row_length = 10
room_part.col_length = #room_part/room_part.row_length
room_part.tile_width = 16
room_part.tileset = im.spriteSettings.testtiles
room_part.tileset_index_table = {
  0, 0, 14, 0, 14, 0, 0, 14, 0, 0,
  14, 2, 3, 15, 2, 15, 2, 0, 3, 0,
  0, 3, 15, 2, 0, 5, 3, 15, 2, 14,
  0, 14, 0, 0, 14, 0, 0, 0, 14, 0,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
  'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
}
room_part.x_that_I_start = 200
room_part.y_that_I_start = 300
room_part.row_length = 15
room_part.col_length = #room_part/room_part.row_length
room_part.tile_width = 16

table.insert(room.room_parts, room_part)
----------End of arrays of geography of parts of room----------


-- rm.build_room(room)


return room
