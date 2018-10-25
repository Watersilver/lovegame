local rm = require("Rooms.room_manager")
local sh = require "scaling_handler"
local trans = require "transitions"
local game = require "game"


local room = {}

room.width = 800
room.height = 450

mainCamera:setWorld(0, 0, room.width, room.height)

room.downTrans = {}
room.rightTrans = {}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 2

room.room_parts = {}

----------Start of arrays of geography of parts of room----------
local room_part = {'P1'}
room_part.x_that_I_start = session.save.playerX or 300
room_part.y_that_I_start = session.save.playerY or 200

table.insert(room.room_parts, room_part)
---
----------End of arrays of geography of parts of room----------


rm.build_room(room)

-- Make sure there's no camera weirdness, even if I start in a tiny room
sh.calculate_total_scale{game_scale=11}
-- return assert(love.filesystem.load("Rooms/room1.lua"))()
return game.change_room(session.save.room or "Rooms/room1.lua")
