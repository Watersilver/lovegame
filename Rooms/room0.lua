local rm = require("Rooms.room_manager")
local sh = require "scaling_handler"
local trans = require "transitions"


local room = {}

room.width = 800
room.height = 450

mainCamera:setWorld(0, 0, room.width, room.height)

room.downTrans = {}
room.rightTrans = {}
room.leftTrans = {}
room.upTrans = {}

sh.calculate_total_scale{game_scale=2}

room.room_parts = {}

----------Start of arrays of geography of parts of room----------
local room_part = {'P1'}
room_part.x_that_I_start = 300
room_part.y_that_I_start = 200

table.insert(room.room_parts, room_part)
---
----------End of arrays of geography of parts of room----------


rm.build_room(room)

return assert(love.filesystem.load("Rooms/room1.lua"))()
