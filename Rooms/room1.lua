local rm = require("Rooms.room_manager")

local room = {}

room.width = 800
room.height = 450
room.room_parts = {}

----------Start of arrays of geography of parts of room----------
local room_part = {'P1'}
room_part.x_that_I_start = 300
room_part.y_that_I_start = 200

table.insert(room.room_parts, room_part)
---
local room_part = {'e', 'e'}
room_part.x_that_I_start = 330
room_part.y_that_I_start = 222
room_part.tile_width = 16
room_part.init = {height = 16, side = "down"}

table.insert(room.room_parts, room_part)
---
local room_part = {'e'}
room_part.x_that_I_start = 330
room_part.y_that_I_start = 222
room_part.init = {height = 16, side = "left"}

table.insert(room.room_parts, room_part)
---
local room_part = {'e'}
room_part.x_that_I_start = 346
room_part.y_that_I_start = 222
room_part.init = {height = 16, side = "right"}

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
---
local room_part = {
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
  'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
}
room_part.x_that_I_start = 200
room_part.y_that_I_start = 150
room_part.row_length = 10
room_part.col_length = #room_part/room_part.row_length
room_part.tile_width = 16
room_part.tileset = {'Tiles/TestTiles', 4, 4}
room_part.tileset_index_table = {
  0, 0, 14, 0, 14, 0, 0, 14, 0, 0,
  14, 2, 3, 15, 2, 15, 2, 0, 3, 0,
  0, 3, 15, 2, 0, 5, 3, 15, 2, 14,
  0, 14, 0, 0, 14, 0, 0, 0, 14, 0,
}

table.insert(room.room_parts, room_part)
----------End of arrays of geography of parts of room----------


rm.build_room(room)


return room
