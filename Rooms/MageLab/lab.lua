local rm = require("RoomBuilding.room_manager")
local sh = require "scaling_handler"
local im = require "image"
local snd = require "sound"

local room = {}
room.newType = true

room.music_info = snd.ovrwrld1
room.music_info = nil
room.timeScreenEffect = 'dull'

room.width = 160
room.height = 112
room.downTrans = {}
room.rightTrans = {}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 3.7

room.gameObjects = {
----------Start of gameObjects----------
{ x = 24, y = 104, n = {l = 10}, t = 2, i = 156},
{ x = 136, y = 104, n = {l = 10}, t = 2, i = 156},
{ x = 104, y = 104, n = {l = 10}, t = 2, i = 158},
{ x = 56, y = 104, n = {l = 10}, t = 2, i = 157},
{ x = 8, y = 104, n = {l = 10}, t = 2, i = 168},
{ x = 152, y = 104, n = {l = 10}, t = 2, i = 169},
{ x = 152, y = 72, n = {l = 10}, t = 2, i = 162},
{ x = 152, y = 56, n = {l = 10}, t = 2, i = 162},
{ x = 152, y = 40, n = {l = 10}, t = 2, i = 162},
{ x = 152, y = 24, n = {l = 10}, t = 2, i = 162},
{ x = 8, y = 88, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 72, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 56, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 40, n = {l = 10}, t = 2, i = 161},
{ x = 152, y = 8, n = {l = 10}, t = 2, i = 155},
{ x = 104, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 120, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 136, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 72, y = 8, n = {l = 10}, t = 2, i = 163},
{ x = 88, y = 8, n = {l = 10}, t = 2, i = 163},
{ x = 152, y = 88, n = {l = 10}, t = 2, i = 170},
{ x = 8, y = 24, n = {l = 10}, t = 2, i = 184},
{ x = 40, y = 104, n = {l = 10}, t = 2, i = 177},
{ x = 120, y = 104, n = {l = 10}, t = 2, i = 177},
{ x = 72, y = 24, n = {l = 10}, t = 1, i = 187},
{ x = 88, y = 24, n = {l = 10}, t = 1, i = 187},
{ x = 104, y = 24, n = {l = 10}, t = 1, i = 187},
{ x = 120, y = 24, n = {l = 10}, t = 1, i = 187},
{ x = 136, y = 24, n = {l = 10}, t = 1, i = 187},
{ x = 136, y = 40, n = {l = 10}, t = 1, i = 187},
{ x = 120, y = 40, n = {l = 10}, t = 1, i = 187},
{ x = 104, y = 40, n = {l = 10}, t = 1, i = 187},
{ x = 56, y = 40, n = {l = 10}, t = 1, i = 187},
{ x = 56, y = 40, n = {l = 11}, t = 5, i = 76},
{ x = 24, y = 24, n = {l = 12}, t = 5, i = 77}, -- Note
{ x = 24, y = 40, n = {l = 10}, t = 1, i = 187},
{ x = 40, y = 56, n = {l = 10}, t = 1, i = 187},
{ x = 56, y = 56, n = {l = 10}, t = 1, i = 187},
{ x = 104, y = 72, n = {l = 10}, t = 1, i = 187},
{ x = 136, y = 88, n = {l = 10}, t = 1, i = 187},
{ x = 88, y = 88, n = {l = 10}, t = 1, i = 187},
{ x = 104, y = 88, n = {l = 10}, t = 1, i = 187},
{ x = 120, y = 88, n = {l = 10}, t = 1, i = 187},
{ x = 120, y = 72, n = {l = 10}, t = 1, i = 187},
{ x = 136, y = 72, n = {l = 10}, t = 1, i = 187},
{ x = 136, y = 56, n = {l = 10}, t = 1, i = 187},
{ x = 120, y = 56, n = {l = 10}, t = 1, i = 187},
{ x = 104, y = 56, n = {l = 10}, t = 1, i = 187},
{ x = 88, y = 72, n = {l = 10}, t = 1, i = 187},
{ x = 72, y = 72, n = {l = 10}, t = 1, i = 187},
{ x = 56, y = 72, n = {l = 10}, t = 1, i = 187},
{ x = 56, y = 88, n = {l = 10}, t = 1, i = 187},
{ x = 40, y = 88, n = {l = 10}, t = 1, i = 187},
{ x = 24, y = 88, n = {l = 10}, t = 1, i = 187},
{ x = 40, y = 72, n = {l = 10}, t = 1, i = 187},
{ x = 24, y = 72, n = {l = 10}, t = 1, i = 187},
{ x = 24, y = 24, n = {l = 10}, t = 1, i = 242},
{ x = 56, y = 24, n = {l = 10}, t = 1, i = 242},
{ x = 40, y = 40, n = {l = 10}, t = 1, i = 242},
{ x = 40, y = 24, n = {l = 10}, t = 1, i = 241},
{ x = 24, y = 56, n = {l = 10}, t = 1, i = 240},
{ x = 8, y = 8, n = {l = 10}, t = 2, i = 154},
{ x = 24, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 40, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 56, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 72, y = 88, n = {l = 10}, t = 1, i = 187},
{ x = 72, y = 104, n = {l = 10}, t = 1, i = 187},
{ x = 88, y = 104, n = {l = 10}, t = 1, i = 187},
{ x = 72, y = 104, n = {l = 11,
destination = "Rooms/w102x098.lua",
desx = 288,
desy = 280,}, t = 3, i = 0},
{ x = 88, y = 104, n = {l = 11,
destination = "Rooms/w102x098.lua",
desx = 288,
desy = 280,}, t = 3, i = 0},
{ x = 40, y = 24, n = {l = 11}, t = 5, i = 33},
{ x = 24, y = 24, n = {l = 11}, t = 5, i = 32},
{ x = 104, y = 8, n = {l = 11}, t = 5, i = 20},
{ x = 104, y = 24, n = {l = 11}, t = 5, i = 30},
{ x = 136, y = 24, n = {l = 11}, t = 5, i = 17},
{ x = 136, y = 40, n = {l = 11}, t = 5, i = 25},
{ x = 120, y = 24, n = {l = 11}, t = 5, i = 71},
{ x = 56, y = 24, n = {l = 11}, t = 5, i = 28},
{ x = 56, y = 8, n = {l = 11}, t = 5, i = 20},
{ x = 24, y = 88, n = {l = 11}, t = 5, i = 47},
{ x = 72, y = 56, n = {l = 10}, t = 1, i = 187},
{ x = 88, y = 56, n = {l = 10}, t = 1, i = 187},
{ x = 88, y = 40, n = {l = 10}, t = 1, i = 187},
{ x = 72, y = 40, n = {l = 10}, t = 1, i = 187},
----------End of gameObjects----------
}

room.manuallyPlacedObjects = {
  {x = 24, y = 24, blueprint = "InRooms.mageLab.mageNoteLab"},
  {x = 80, y = 32, blueprint = "InRooms.mageLab.magicMissileChest"}
}
return room
