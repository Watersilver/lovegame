local rm = require("RoomBuilding.room_manager")
local sh = require "scaling_handler"
local im = require "image"
local snd = require "sound"

local room = {}
room.newType = true

room.music_info = snd.ovrwrld1
room.timeScreenEffect = 'forestMagic'

room.width = 400 -- 400 / 16 = 25
room.height = 224 -- 224 / 16 = 14
room.downTrans = {
  {
    roomTarget = "Rooms/w100x099.lua", -- Ver To Up Right
    xleftmost = 0, xrightmost = 400,
    xmod = 112, ymod = 0
  }
}
room.rightTrans = {}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 2

room.gameObjects = {
----------Start of gameObjects----------
{ x = 136, y = 216, n = {l = 10}, t = 2, i = 58},
{ x = 120, y = 216, n = {l = 10}, t = 2, i = 58},
{ x = 104, y = 216, n = {l = 10}, t = 2, i = 58},
{ x = 88, y = 216, n = {l = 10}, t = 2, i = 58},
{ x = 72, y = 216, n = {l = 10}, t = 2, i = 58},
{ x = 56, y = 216, n = {l = 10}, t = 2, i = 58},
{ x = 40, y = 216, n = {l = 10}, t = 2, i = 58},
{ x = 344, y = 200, n = {l = 10}, t = 2, i = 238},
{ x = 360, y = 200, n = {l = 10}, t = 2, i = 239},
{ x = 360, y = 184, n = {l = 10}, t = 2, i = 232},
{ x = 344, y = 184, n = {l = 10}, t = 2, i = 231},
{ x = 360, y = 168, n = {l = 10}, t = 2, i = 238},
{ x = 360, y = 152, n = {l = 10}, t = 2, i = 231},
{ x = 376, y = 152, n = {l = 10}, t = 2, i = 232},
{ x = 376, y = 168, n = {l = 10}, t = 2, i = 239},
{ x = 344, y = 136, n = {l = 10}, t = 2, i = 238},
{ x = 344, y = 120, n = {l = 10}, t = 2, i = 231},
{ x = 360, y = 120, n = {l = 10}, t = 2, i = 232},
{ x = 360, y = 136, n = {l = 10}, t = 2, i = 239},
{ x = 360, y = 104, n = {l = 10}, t = 2, i = 238},
{ x = 360, y = 88, n = {l = 10}, t = 2, i = 231},
{ x = 376, y = 88, n = {l = 10}, t = 2, i = 232},
{ x = 376, y = 104, n = {l = 10}, t = 2, i = 239},
{ x = 344, y = 72, n = {l = 10}, t = 2, i = 238},
{ x = 344, y = 56, n = {l = 10}, t = 2, i = 231},
{ x = 360, y = 56, n = {l = 10}, t = 2, i = 232},
{ x = 360, y = 72, n = {l = 10}, t = 2, i = 239},
{ x = 328, y = 40, n = {l = 10}, t = 2, i = 238},
{ x = 328, y = 24, n = {l = 10}, t = 2, i = 231},
{ x = 344, y = 24, n = {l = 10}, t = 2, i = 232},
{ x = 344, y = 40, n = {l = 10}, t = 2, i = 239},
{ x = 296, y = 24, n = {l = 10}, t = 2, i = 238},
{ x = 296, y = 8, n = {l = 10}, t = 2, i = 231},
{ x = 312, y = 8, n = {l = 10}, t = 2, i = 232},
{ x = 312, y = 24, n = {l = 10}, t = 2, i = 239},
{ x = 264, y = 40, n = {l = 10}, t = 2, i = 238},
{ x = 264, y = 24, n = {l = 10}, t = 2, i = 231},
{ x = 280, y = 24, n = {l = 10}, t = 2, i = 232},
{ x = 280, y = 40, n = {l = 10}, t = 2, i = 239},
{ x = 88, y = 200, n = {l = 10}, t = 2, i = 239},
{ x = 72, y = 200, n = {l = 10}, t = 2, i = 238},
{ x = 72, y = 184, n = {l = 10}, t = 2, i = 231},
{ x = 88, y = 184, n = {l = 10}, t = 2, i = 232},
{ x = 72, y = 168, n = {l = 10}, t = 2, i = 239},
{ x = 56, y = 168, n = {l = 10}, t = 2, i = 238},
{ x = 56, y = 152, n = {l = 10}, t = 2, i = 231},
{ x = 72, y = 152, n = {l = 10}, t = 2, i = 232},
{ x = 56, y = 136, n = {l = 10}, t = 2, i = 239},
{ x = 40, y = 136, n = {l = 10}, t = 2, i = 238},
{ x = 40, y = 120, n = {l = 10}, t = 2, i = 231},
{ x = 56, y = 120, n = {l = 10}, t = 2, i = 232},
{ x = 56, y = 104, n = {l = 10}, t = 2, i = 239},
{ x = 40, y = 104, n = {l = 10}, t = 2, i = 238},
{ x = 40, y = 88, n = {l = 10}, t = 2, i = 231},
{ x = 56, y = 88, n = {l = 10}, t = 2, i = 232},
{ x = 40, y = 168, n = {l = 10}, t = 2, i = 239},
{ x = 24, y = 168, n = {l = 10}, t = 2, i = 238},
{ x = 24, y = 152, n = {l = 10}, t = 2, i = 231},
{ x = 40, y = 152, n = {l = 10}, t = 2, i = 232},
{ x = 24, y = 200, n = {l = 10}, t = 2, i = 239},
{ x = 8, y = 200, n = {l = 10}, t = 2, i = 238},
{ x = 8, y = 184, n = {l = 10}, t = 2, i = 231},
{ x = 24, y = 184, n = {l = 10}, t = 2, i = 232},
{ x = 24, y = 104, n = {l = 10}, t = 2, i = 232},
{ x = 24, y = 120, n = {l = 10}, t = 2, i = 239},
{ x = 8, y = 120, n = {l = 10}, t = 2, i = 238},
{ x = 8, y = 104, n = {l = 10}, t = 2, i = 231},
{ x = 56, y = 56, n = {l = 10}, t = 2, i = 231},
{ x = 56, y = 72, n = {l = 10}, t = 2, i = 238},
{ x = 72, y = 72, n = {l = 10}, t = 2, i = 239},
{ x = 72, y = 56, n = {l = 10}, t = 2, i = 232},
{ x = 88, y = 56, n = {l = 10}, t = 2, i = 238},
{ x = 88, y = 40, n = {l = 10}, t = 2, i = 231},
{ x = 104, y = 40, n = {l = 10}, t = 2, i = 232},
{ x = 104, y = 56, n = {l = 10}, t = 2, i = 239},
{ x = 40, y = 56, n = {l = 10}, t = 2, i = 239},
{ x = 24, y = 56, n = {l = 10}, t = 2, i = 238},
{ x = 24, y = 40, n = {l = 10}, t = 2, i = 231},
{ x = 40, y = 40, n = {l = 10}, t = 2, i = 232},
{ x = 8, y = 72, n = {l = 10}, t = 2, i = 239},
{ x = 8, y = 56, n = {l = 10}, t = 2, i = 232},
{ x = 40, y = 24, n = {l = 10}, t = 2, i = 238},
{ x = 40, y = 8, n = {l = 10}, t = 2, i = 231},
{ x = 56, y = 8, n = {l = 10}, t = 2, i = 232},
{ x = 56, y = 24, n = {l = 10}, t = 2, i = 239},
{ x = 120, y = 40, n = {l = 10}, t = 2, i = 238},
{ x = 120, y = 24, n = {l = 10}, t = 2, i = 231},
{ x = 136, y = 24, n = {l = 10}, t = 2, i = 232},
{ x = 136, y = 40, n = {l = 10}, t = 2, i = 239},
{ x = 152, y = 56, n = {l = 10}, t = 2, i = 238},
{ x = 152, y = 40, n = {l = 10}, t = 2, i = 231},
{ x = 168, y = 40, n = {l = 10}, t = 2, i = 232},
{ x = 168, y = 56, n = {l = 10}, t = 2, i = 239},
{ x = 184, y = 40, n = {l = 10}, t = 2, i = 238},
{ x = 184, y = 24, n = {l = 10}, t = 2, i = 231},
{ x = 200, y = 24, n = {l = 10}, t = 2, i = 232},
{ x = 200, y = 40, n = {l = 10}, t = 2, i = 239},
{ x = 216, y = 24, n = {l = 10}, t = 2, i = 238},
{ x = 216, y = 8, n = {l = 10}, t = 2, i = 231},
{ x = 232, y = 8, n = {l = 10}, t = 2, i = 232},
{ x = 232, y = 24, n = {l = 10}, t = 2, i = 239},
{ x = 232, y = 56, n = {l = 10}, t = 2, i = 238},
{ x = 232, y = 40, n = {l = 10}, t = 2, i = 231},
{ x = 248, y = 40, n = {l = 10}, t = 2, i = 232},
{ x = 248, y = 56, n = {l = 10}, t = 2, i = 239},
{ x = 376, y = 136, n = {l = 10}, t = 1, i = 1},
{ x = 376, y = 120, n = {l = 10}, t = 1, i = 1},
{ x = 360, y = 8, n = {l = 10}, t = 1, i = 1},
{ x = 344, y = 8, n = {l = 10}, t = 1, i = 1},
{ x = 328, y = 8, n = {l = 10}, t = 1, i = 1},
{ x = 280, y = 8, n = {l = 10}, t = 1, i = 1},
{ x = 248, y = 24, n = {l = 10}, t = 1, i = 1},
{ x = 168, y = 8, n = {l = 10}, t = 1, i = 1},
{ x = 152, y = 24, n = {l = 10}, t = 1, i = 1},
{ x = 168, y = 24, n = {l = 10}, t = 1, i = 1},
{ x = 120, y = 8, n = {l = 10}, t = 1, i = 1},
{ x = 104, y = 8, n = {l = 10}, t = 1, i = 1},
{ x = 104, y = 24, n = {l = 10}, t = 1, i = 1},
{ x = 72, y = 40, n = {l = 10}, t = 1, i = 1},
{ x = 56, y = 40, n = {l = 10}, t = 1, i = 1},
{ x = 24, y = 24, n = {l = 10}, t = 1, i = 1},
{ x = 8, y = 40, n = {l = 10}, t = 1, i = 1},
{ x = 24, y = 8, n = {l = 10}, t = 1, i = 1},
{ x = 24, y = 88, n = {l = 10}, t = 1, i = 1},
{ x = 8, y = 88, n = {l = 10}, t = 1, i = 1},
{ x = 24, y = 72, n = {l = 10}, t = 1, i = 1},
{ x = 40, y = 72, n = {l = 10}, t = 1, i = 1},
{ x = 24, y = 136, n = {l = 10}, t = 1, i = 1},
{ x = 8, y = 168, n = {l = 10}, t = 1, i = 1},
{ x = 40, y = 184, n = {l = 10}, t = 1, i = 1},
{ x = 40, y = 200, n = {l = 10}, t = 1, i = 1},
{ x = 56, y = 200, n = {l = 10}, t = 1, i = 1},
{ x = 56, y = 184, n = {l = 10}, t = 1, i = 1},
{ x = 216, y = 40, n = {l = 10}, t = 1, i = 1},
{ x = 72, y = 24, n = {l = 10}, t = 2, i = 238},
{ x = 88, y = 24, n = {l = 10}, t = 2, i = 239},
{ x = 88, y = 8, n = {l = 10}, t = 2, i = 232},
{ x = 72, y = 8, n = {l = 10}, t = 2, i = 231},
{ x = 184, y = 72, n = {l = 10}, t = 2, i = 238},
{ x = 184, y = 56, n = {l = 10}, t = 2, i = 231},
{ x = 216, y = 56, n = {l = 10}, t = 2, i = 232},
{ x = 216, y = 72, n = {l = 10}, t = 2, i = 239},
{ x = 200, y = 56, n = {l = 10}, t = 2, i = 233},
{ x = 200, y = 72, n = {l = 10}, t = 3, i = 10},
{ x = 312, y = 120, n = {l = 10}, t = 1, i = 17},
{ x = 296, y = 136, n = {l = 10}, t = 1, i = 17},
{ x = 312, y = 152, n = {l = 10}, t = 1, i = 17},
{ x = 280, y = 168, n = {l = 10}, t = 1, i = 17},
{ x = 264, y = 184, n = {l = 10}, t = 1, i = 17},
{ x = 104, y = 88, n = {l = 10}, t = 1, i = 17},
{ x = 120, y = 72, n = {l = 10}, t = 1, i = 17},
{ x = 120, y = 200, n = {l = 10}, t = 1, i = 17},
{ x = 152, y = 200, n = {l = 10}, t = 1, i = 17},
{ x = 168, y = 200, n = {l = 10}, t = 1, i = 17},
{ x = 312, y = 136, n = {l = 10}, t = 1, i = 12},
{ x = 296, y = 168, n = {l = 10}, t = 1, i = 12},
{ x = 136, y = 200, n = {l = 10}, t = 1, i = 12},
{ x = 264, y = 168, n = {l = 10}, t = 1, i = 20},
{ x = 88, y = 88, n = {l = 10}, t = 1, i = 20},
{ x = 136, y = 72, n = {l = 10}, t = 1, i = 28},
{ x = 168, y = 88, n = {l = 10}, t = 1, i = 124},
{ x = 232, y = 88, n = {l = 10}, t = 1, i = 126},
{ x = 216, y = 88, n = {l = 10}, t = 1, i = 125},
{ x = 200, y = 88, n = {l = 10}, t = 1, i = 125},
{ x = 168, y = 72, n = {l = 10}, t = 1, i = 116},
{ x = 232, y = 72, n = {l = 10}, t = 1, i = 118},
{ x = 168, y = 184, n = {l = 10}, t = 1, i = 17},
{ x = 248, y = 168, n = {l = 10}, t = 1, i = 17},
{ x = 280, y = 184, n = {l = 10}, t = 1, i = 17},
{ x = 312, y = 184, n = {l = 10}, t = 1, i = 17},
{ x = 328, y = 168, n = {l = 10}, t = 1, i = 17},
{ x = 312, y = 168, n = {l = 10}, t = 1, i = 17},
{ x = 328, y = 152, n = {l = 10}, t = 1, i = 17},
{ x = 312, y = 72, n = {l = 10}, t = 1, i = 17},
{ x = 312, y = 56, n = {l = 10}, t = 1, i = 17},
{ x = 264, y = 152, n = {l = 10}, t = 1, i = 17},
{ x = 280, y = 152, n = {l = 10}, t = 1, i = 17},
{ x = 136, y = 88, n = {l = 10}, t = 1, i = 17},
{ x = 136, y = 104, n = {l = 10}, t = 1, i = 17},
{ x = 120, y = 104, n = {l = 10}, t = 1, i = 17},
{ x = 120, y = 152, n = {l = 10}, t = 1, i = 17},
{ x = 120, y = 168, n = {l = 10}, t = 1, i = 17},
{ x = 136, y = 168, n = {l = 10}, t = 1, i = 17},
{ x = 136, y = 184, n = {l = 10}, t = 1, i = 17},
{ x = 152, y = 168, n = {l = 10}, t = 1, i = 17},
{ x = 136, y = 56, n = {l = 10}, t = 1, i = 10},
{ x = 120, y = 56, n = {l = 10}, t = 1, i = 8},
{ x = 104, y = 72, n = {l = 10}, t = 1, i = 9},
{ x = 88, y = 72, n = {l = 10}, t = 1, i = 8},
{ x = 72, y = 88, n = {l = 10}, t = 1, i = 8},
{ x = 88, y = 168, n = {l = 10}, t = 1, i = 24},
{ x = 104, y = 184, n = {l = 10}, t = 1, i = 16},
{ x = 104, y = 200, n = {l = 10}, t = 1, i = 24},
{ x = 328, y = 200, n = {l = 10}, t = 1, i = 18},
{ x = 328, y = 184, n = {l = 10}, t = 1, i = 18},
{ x = 344, y = 168, n = {l = 10}, t = 1, i = 26},
{ x = 344, y = 152, n = {l = 10}, t = 1, i = 10},
{ x = 328, y = 136, n = {l = 10}, t = 1, i = 18},
{ x = 328, y = 120, n = {l = 10}, t = 1, i = 18},
{ x = 344, y = 104, n = {l = 10}, t = 1, i = 26},
{ x = 344, y = 88, n = {l = 10}, t = 1, i = 10},
{ x = 328, y = 72, n = {l = 10}, t = 1, i = 18},
{ x = 328, y = 56, n = {l = 10}, t = 1, i = 10},
{ x = 312, y = 40, n = {l = 10}, t = 1, i = 10},
{ x = 296, y = 40, n = {l = 10}, t = 1, i = 8},
{ x = 280, y = 56, n = {l = 10}, t = 1, i = 9},
{ x = 264, y = 56, n = {l = 10}, t = 1, i = 8},
{ x = 280, y = 136, n = {l = 10}, t = 1, i = 12},
{ x = 136, y = 152, n = {l = 10}, t = 1, i = 12},
{ x = 120, y = 184, n = {l = 10}, t = 1, i = 12},
{ x = 184, y = 168, n = {l = 10}, t = 1, i = 181},
{ x = 200, y = 168, n = {l = 10}, t = 1, i = 181},
{ x = 216, y = 168, n = {l = 10}, t = 1, i = 181},
{ x = 184, y = 184, n = {l = 10}, t = 1, i = 105},
{ x = 200, y = 184, n = {l = 10}, t = 1, i = 105},
{ x = 216, y = 184, n = {l = 10}, t = 1, i = 105},
{ x = 168, y = 152, n = {l = 10}, t = 1, i = 181},
{ x = 184, y = 152, n = {l = 10}, t = 1, i = 181},
{ x = 216, y = 152, n = {l = 10}, t = 1, i = 181},
{ x = 232, y = 152, n = {l = 10}, t = 1, i = 181},
{ x = 152, y = 136, n = {l = 10}, t = 1, i = 181},
{ x = 168, y = 120, n = {l = 10}, t = 1, i = 181},
{ x = 200, y = 120, n = {l = 10}, t = 1, i = 181},
{ x = 216, y = 120, n = {l = 10}, t = 1, i = 181},
{ x = 232, y = 120, n = {l = 10}, t = 1, i = 181},
{ x = 248, y = 136, n = {l = 10}, t = 1, i = 181},
{ x = 232, y = 136, n = {l = 10}, t = 1, i = 181},
{ x = 216, y = 136, n = {l = 10}, t = 1, i = 181},
{ x = 184, y = 136, n = {l = 10}, t = 1, i = 181},
{ x = 168, y = 136, n = {l = 10}, t = 1, i = 181},
{ x = 184, y = 104, n = {l = 10}, t = 1, i = 181},
{ x = 200, y = 104, n = {l = 10}, t = 1, i = 181},
{ x = 216, y = 104, n = {l = 10}, t = 1, i = 181},
{ x = 264, y = 136, n = {l = 10}, t = 1, i = 112},
{ x = 248, y = 152, n = {l = 10}, t = 1, i = 104},
{ x = 232, y = 168, n = {l = 10}, t = 1, i = 104},
{ x = 168, y = 168, n = {l = 10}, t = 1, i = 106},
{ x = 152, y = 152, n = {l = 10}, t = 1, i = 106},
{ x = 136, y = 136, n = {l = 10}, t = 1, i = 114},
{ x = 168, y = 104, n = {l = 10}, t = 1, i = 122},
{ x = 232, y = 104, n = {l = 10}, t = 1, i = 120},
{ x = 248, y = 72, n = {l = 10}, t = 1, i = 9},
{ x = 152, y = 72, n = {l = 10}, t = 1, i = 9},
{ x = 152, y = 120, n = {l = 10}, t = 1, i = 122},
{ x = 248, y = 120, n = {l = 10}, t = 1, i = 120},
{ x = 136, y = 120, n = {l = 10}, t = 1, i = 17},
{ x = 264, y = 120, n = {l = 10}, t = 1, i = 17},
{ x = 152, y = 88, n = {l = 10}, t = 1, i = 28},
{ x = 248, y = 88, n = {l = 10}, t = 1, i = 28},
{ x = 264, y = 72, n = {l = 10}, t = 1, i = 28},
{ x = 152, y = 104, n = {l = 10}, t = 1, i = 28},
{ x = 248, y = 104, n = {l = 10}, t = 1, i = 28},
{ x = 120, y = 88, n = {l = 10}, t = 1, i = 12},
{ x = 152, y = 184, n = {l = 10}, t = 1, i = 20},
{ x = 104, y = 168, n = {l = 10}, t = 1, i = 6},
{ x = 248, y = 184, n = {l = 10}, t = 1, i = 6},
{ x = 232, y = 184, n = {l = 10}, t = 1, i = 6},
{ x = 296, y = 184, n = {l = 10}, t = 1, i = 6},
{ x = 296, y = 152, n = {l = 10}, t = 1, i = 6},
{ x = 88, y = 120, n = {l = 10}, t = 2, i = 231},
{ x = 104, y = 120, n = {l = 10}, t = 2, i = 232},
{ x = 104, y = 136, n = {l = 10}, t = 2, i = 239},
{ x = 88, y = 136, n = {l = 10}, t = 2, i = 238},
{ x = 72, y = 120, n = {l = 10}, t = 1, i = 27},
{ x = 72, y = 104, n = {l = 10}, t = 1, i = 24},
{ x = 88, y = 104, n = {l = 10}, t = 1, i = 25},
{ x = 104, y = 104, n = {l = 10}, t = 1, i = 25},
{ x = 120, y = 120, n = {l = 10}, t = 1, i = 16},
{ x = 120, y = 136, n = {l = 10}, t = 1, i = 16},
{ x = 104, y = 152, n = {l = 10}, t = 1, i = 9},
{ x = 88, y = 152, n = {l = 10}, t = 1, i = 8},
{ x = 72, y = 136, n = {l = 10}, t = 1, i = 1},
{ x = 280, y = 72, n = {l = 10}, t = 1, i = 25},
{ x = 296, y = 72, n = {l = 10}, t = 1, i = 25},
{ x = 296, y = 120, n = {l = 10}, t = 1, i = 9},
{ x = 280, y = 120, n = {l = 10}, t = 1, i = 9},
{ x = 264, y = 104, n = {l = 10}, t = 1, i = 18},
{ x = 264, y = 88, n = {l = 10}, t = 1, i = 18},
{ x = 328, y = 88, n = {l = 10}, t = 1, i = 17},
{ x = 312, y = 104, n = {l = 10}, t = 1, i = 16},
{ x = 312, y = 88, n = {l = 10}, t = 1, i = 16},
{ x = 328, y = 104, n = {l = 10}, t = 1, i = 20},
{ x = 296, y = 56, n = {l = 10}, t = 1, i = 12},
{ x = 184, y = 120, n = {l = 10}, t = 1, i = 260},
{ x = 200, y = 152, n = {l = 10}, t = 1, i = 259},
{ x = 200, y = 136, n = {l = 10}, t = 1, i = 181},
{ x = 136, y = 8, n = {l = 10}, t = 2, i = 238},
{ x = 152, y = 8, n = {l = 10}, t = 2, i = 239},
{ x = 376, y = 8, n = {l = 10}, t = 2, i = 238},
{ x = 360, y = 40, n = {l = 10}, t = 2, i = 238},
{ x = 360, y = 24, n = {l = 10}, t = 2, i = 231},
{ x = 376, y = 24, n = {l = 10}, t = 2, i = 232},
{ x = 376, y = 40, n = {l = 10}, t = 2, i = 239},
{ x = 248, y = 8, n = {l = 10}, t = 2, i = 238},
{ x = 264, y = 8, n = {l = 10}, t = 2, i = 239},
{ x = 200, y = 8, n = {l = 10}, t = 2, i = 239},
{ x = 184, y = 8, n = {l = 10}, t = 2, i = 238},
{ x = 8, y = 24, n = {l = 10}, t = 2, i = 239},
{ x = 8, y = 8, n = {l = 10}, t = 2, i = 232},
{ x = 8, y = 152, n = {l = 10}, t = 2, i = 239},
{ x = 8, y = 136, n = {l = 10}, t = 2, i = 232},
{ x = 280, y = 104, n = {l = 10}, t = 2, i = 238},
{ x = 296, y = 104, n = {l = 10}, t = 2, i = 239},
{ x = 296, y = 88, n = {l = 10}, t = 2, i = 232},
{ x = 280, y = 88, n = {l = 10}, t = 2, i = 231},
{ x = 184, y = 88, n = {l = 10}, t = 1, i = 125},
{ x = 184, y = 88, n = {l = 11}, t = 5, i = 2},
{ x = 216, y = 88, n = {l = 11}, t = 5, i = 2},
{ x = 168, y = 72, n = {l = 11}, t = 5, i = 2},
{ x = 232, y = 72, n = {l = 11}, t = 5, i = 2},
{ x = 88, y = 72, n = {l = 11}, t = 5, i = 2},
{ x = 328, y = 56, n = {l = 11}, t = 5, i = 2},
{ x = 72, y = 88, n = {l = 11}, t = 5, i = 13},
{ x = 168, y = 216, n = {l = 10}, t = 2, i = 36},
{ x = 152, y = 216, n = {l = 10}, t = 2, i = 58},
{ x = 344, y = 216, n = {l = 10}, t = 2, i = 35},
{ x = 360, y = 216, n = {l = 10}, t = 2, i = 36},
{ x = 328, y = 216, n = {l = 10}, t = 1, i = 17},
{ x = 376, y = 200, n = {l = 10}, t = 2, i = 238},
{ x = 376, y = 184, n = {l = 10}, t = 2, i = 231},
{ x = 392, y = 184, n = {l = 10}, t = 2, i = 232},
{ x = 392, y = 200, n = {l = 10}, t = 2, i = 239},
{ x = 392, y = 152, n = {l = 10}, t = 2, i = 238},
{ x = 392, y = 136, n = {l = 10}, t = 2, i = 231},
{ x = 392, y = 120, n = {l = 10}, t = 2, i = 238},
{ x = 392, y = 104, n = {l = 10}, t = 2, i = 231},
{ x = 392, y = 8, n = {l = 10}, t = 2, i = 239},
{ x = 376, y = 72, n = {l = 10}, t = 2, i = 238},
{ x = 376, y = 56, n = {l = 10}, t = 2, i = 231},
{ x = 392, y = 56, n = {l = 10}, t = 2, i = 232},
{ x = 392, y = 72, n = {l = 10}, t = 2, i = 239},
{ x = 392, y = 88, n = {l = 10}, t = 1, i = 1},
{ x = 392, y = 40, n = {l = 10}, t = 1, i = 1},
{ x = 392, y = 24, n = {l = 10}, t = 1, i = 27},
{ x = 392, y = 168, n = {l = 10}, t = 1, i = 1},
{ x = 376, y = 216, n = {l = 10}, t = 1, i = 9},
{ x = 392, y = 216, n = {l = 10}, t = 1, i = 9},
{ x = 24, y = 216, n = {l = 10}, t = 2, i = 35},
{ x = 8, y = 216, n = {l = 10}, t = 2, i = 36},
{ x = 312, y = 200, n = {l = 10}, t = 2, i = 36},
{ x = 184, y = 200, n = {l = 10}, t = 2, i = 35},
{ x = 200, y = 200, n = {l = 10}, t = 2, i = 58},
{ x = 216, y = 200, n = {l = 10}, t = 2, i = 58},
{ x = 232, y = 200, n = {l = 10}, t = 2, i = 58},
{ x = 248, y = 200, n = {l = 10}, t = 2, i = 58},
{ x = 264, y = 200, n = {l = 10}, t = 2, i = 58},
{ x = 280, y = 200, n = {l = 10}, t = 2, i = 58},
{ x = 296, y = 200, n = {l = 10}, t = 2, i = 58},
{ x = 200, y = 216, n = {l = 10}, t = 2, i = 65},
{ x = 216, y = 216, n = {l = 10}, t = 2, i = 65},
{ x = 232, y = 216, n = {l = 10}, t = 2, i = 65},
{ x = 248, y = 216, n = {l = 10}, t = 2, i = 65},
{ x = 264, y = 216, n = {l = 10}, t = 2, i = 65},
{ x = 280, y = 216, n = {l = 10}, t = 2, i = 65},
{ x = 296, y = 216, n = {l = 10}, t = 2, i = 65},
{ x = 312, y = 216, n = {l = 10}, t = 2, i = 50},
{ x = 184, y = 216, n = {l = 10}, t = 2, i = 49},
{ x = 168, y = 200, n = {l = 11}, t = 5, i = 2},
----------End of gameObjects----------
}
return room
