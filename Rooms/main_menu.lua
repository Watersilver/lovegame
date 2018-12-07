local rm = require("Rooms.room_manager")
local sh = require "scaling_handler"
local trans = require "transitions"


local room = {}

room.music_info = {"Music/MusicTest"}

room.width = 800
room.height = 450

mainCamera:setWorld(0, 0, room.width, room.height)

room.downTrans = {}
room.rightTrans = {}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 1

room.room_parts = {}

----------Start of arrays of geography of parts of room----------
local room_part = {'mainMenu'}
room_part.x_that_I_start = 0
room_part.y_that_I_start = 0

table.insert(room.room_parts, room_part)
---
----------End of arrays of geography of parts of room----------

-- rm.build_room(room)

return room
