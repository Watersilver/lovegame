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
local room_part = {
  'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x',
  'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x',
  'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x',
  'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x',
}
room_part.x_that_I_start = 200
room_part.y_that_I_start = 300
room_part.row_length = 15
room_part.col_length = #room_part/room_part.row_length
room_part.tile_width = 16

table.insert(room.room_parts, room_part)
----------End of arrays of geography of parts of room----------


rm.build_room(room)


return room
