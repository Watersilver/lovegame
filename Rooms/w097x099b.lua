local rm = require("RoomBuilding.room_manager")
local sh = require "scaling_handler"
local im = require "image"
local snd = require "sound"

local room = {}
room.newType = true

room.music_info = snd.ovrwrld1
room.timeScreenEffect = 'default'

room.width = 512
room.height = 512
room.downTrans = {
  {
    roomTarget = "Rooms/w097x100.lua",
    xleftmost = 0, xrightmost = 520,
    xmod = 0, ymod = 0
  }
}
room.rightTrans = {}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 2

room.gameObjects = {
----------Start of gameObjects----------
{ x = 296, y = 504, n = {l = 10}, t = 2, i = 42},
{ x = 376, y = 504, n = {l = 10}, t = 2, i = 43},
{ x = 296, y = 488, n = {l = 10}, t = 2, i = 52},
{ x = 376, y = 488, n = {l = 10}, t = 2, i = 43},
{ x = 376, y = 472, n = {l = 10}, t = 2, i = 43},
{ x = 376, y = 456, n = {l = 10}, t = 2, i = 43},
{ x = 376, y = 440, n = {l = 10}, t = 2, i = 43},
{ x = 376, y = 424, n = {l = 10}, t = 2, i = 36},
{ x = 360, y = 424, n = {l = 10}, t = 2, i = 58},
{ x = 344, y = 424, n = {l = 10}, t = 2, i = 58},
{ x = 328, y = 424, n = {l = 10}, t = 2, i = 58},
{ x = 312, y = 424, n = {l = 10}, t = 2, i = 58},
{ x = 296, y = 424, n = {l = 10}, t = 2, i = 58},
{ x = 280, y = 488, n = {l = 10}, t = 2, i = 65},
{ x = 264, y = 488, n = {l = 10}, t = 2, i = 65},
{ x = 248, y = 488, n = {l = 10}, t = 2, i = 65},
{ x = 232, y = 488, n = {l = 10}, t = 2, i = 65},
{ x = 216, y = 488, n = {l = 10}, t = 2, i = 65},
{ x = 200, y = 488, n = {l = 10}, t = 2, i = 65},
{ x = 184, y = 488, n = {l = 10}, t = 2, i = 49},
{ x = 184, y = 472, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 456, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 440, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 424, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 408, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 392, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 376, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 360, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 344, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 328, n = {l = 10}, t = 2, i = 42},
{ x = 184, y = 312, n = {l = 10}, t = 2, i = 42},
{ x = 280, y = 424, n = {l = 10}, t = 2, i = 46},
{ x = 280, y = 408, n = {l = 10}, t = 2, i = 43},
{ x = 280, y = 392, n = {l = 10}, t = 2, i = 43},
{ x = 280, y = 376, n = {l = 10}, t = 2, i = 43},
{ x = 280, y = 360, n = {l = 10}, t = 2, i = 43},
{ x = 280, y = 344, n = {l = 10}, t = 2, i = 43},
{ x = 280, y = 328, n = {l = 10}, t = 2, i = 43},
{ x = 280, y = 312, n = {l = 10}, t = 2, i = 43},
{ x = 280, y = 296, n = {l = 10}, t = 2, i = 53},
{ x = 184, y = 296, n = {l = 10}, t = 2, i = 52},
{ x = 168, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 152, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 136, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 120, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 104, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 88, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 72, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 56, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 40, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 24, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 8, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 296, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 312, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 328, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 344, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 360, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 376, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 392, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 408, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 424, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 440, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 456, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 472, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 488, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 504, y = 296, n = {l = 10}, t = 2, i = 65},
{ x = 168, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 24, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 40, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 56, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 72, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 88, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 104, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 120, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 136, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 168, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 152, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 200, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 216, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 232, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 248, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 264, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 8, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 24, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 40, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 56, y = 488, n = {l = 10}, t = 1, i = 17},
{ x = 104, y = 488, n = {l = 10}, t = 1, i = 17},
{ x = 120, y = 488, n = {l = 10}, t = 1, i = 17},
{ x = 152, y = 488, n = {l = 10}, t = 1, i = 17},
{ x = 152, y = 504, n = {l = 10}, t = 1, i = 17},
{ x = 120, y = 504, n = {l = 10}, t = 1, i = 17},
{ x = 104, y = 504, n = {l = 10}, t = 1, i = 17},
{ x = 72, y = 504, n = {l = 10}, t = 1, i = 17},
{ x = 56, y = 504, n = {l = 10}, t = 1, i = 40},
{ x = 88, y = 504, n = {l = 10}, t = 1, i = 41},
{ x = 136, y = 488, n = {l = 10}, t = 1, i = 41},
{ x = 168, y = 504, n = {l = 10}, t = 1, i = 41},
{ x = 88, y = 488, n = {l = 10}, t = 1, i = 6},
{ x = 136, y = 504, n = {l = 10}, t = 1, i = 6},
{ x = 168, y = 488, n = {l = 10}, t = 1, i = 65},
{ x = 72, y = 488, n = {l = 10}, t = 1, i = 65},
{ x = 392, y = 488, n = {l = 10}, t = 1, i = 65},
{ x = 440, y = 488, n = {l = 10}, t = 1, i = 65},
{ x = 456, y = 488, n = {l = 10}, t = 1, i = 65},
{ x = 472, y = 488, n = {l = 10}, t = 1, i = 65},
{ x = 504, y = 504, n = {l = 10}, t = 1, i = 65},
{ x = 488, y = 504, n = {l = 10}, t = 1, i = 65},
{ x = 408, y = 504, n = {l = 10}, t = 1, i = 65},
{ x = 392, y = 504, n = {l = 10}, t = 1, i = 41},
{ x = 440, y = 504, n = {l = 10}, t = 1, i = 41},
{ x = 424, y = 488, n = {l = 10}, t = 1, i = 41},
{ x = 472, y = 504, n = {l = 10}, t = 1, i = 17},
{ x = 504, y = 488, n = {l = 10}, t = 1, i = 17},
{ x = 408, y = 488, n = {l = 10}, t = 1, i = 6},
{ x = 456, y = 504, n = {l = 10}, t = 1, i = 6},
{ x = 424, y = 504, n = {l = 10}, t = 1, i = 6},
{ x = 488, y = 488, n = {l = 10}, t = 1, i = 6},
{ x = 312, y = 504, n = {l = 10}, t = 1, i = 5},
{ x = 312, y = 488, n = {l = 10}, t = 1, i = 5},
{ x = 328, y = 504, n = {l = 10}, t = 1, i = 5},
{ x = 344, y = 504, n = {l = 10}, t = 1, i = 5},
{ x = 360, y = 504, n = {l = 10}, t = 1, i = 5},
{ x = 360, y = 488, n = {l = 10}, t = 1, i = 5},
{ x = 360, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 360, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 360, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 344, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 328, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 312, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 296, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 280, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 296, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 312, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 344, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 344, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 328, y = 488, n = {l = 10}, t = 1, i = 5},
{ x = 344, y = 488, n = {l = 10}, t = 1, i = 5},
{ x = 328, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 328, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 312, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 296, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 280, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 280, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 264, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 248, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 232, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 216, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 200, y = 472, n = {l = 10}, t = 1, i = 5},
{ x = 264, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 264, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 248, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 216, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 200, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 200, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 216, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 232, y = 456, n = {l = 10}, t = 1, i = 5},
{ x = 232, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 248, y = 440, n = {l = 10}, t = 1, i = 5},
{ x = 184, y = 504, n = {l = 10}, t = 2, i = 63},
{ x = 200, y = 296, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 296, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 296, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 296, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 296, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 312, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 328, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 344, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 360, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 376, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 392, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 408, n = {l = 10}, t = 1, i = 217},
{ x = 264, y = 424, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 424, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 424, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 424, n = {l = 10}, t = 1, i = 217},
{ x = 200, y = 424, n = {l = 10}, t = 1, i = 217},
{ x = 200, y = 408, n = {l = 10}, t = 1, i = 217},
{ x = 200, y = 392, n = {l = 10}, t = 1, i = 217},
{ x = 200, y = 376, n = {l = 10}, t = 1, i = 217},
{ x = 200, y = 360, n = {l = 10}, t = 1, i = 217},
{ x = 200, y = 344, n = {l = 10}, t = 1, i = 217},
{ x = 200, y = 328, n = {l = 10}, t = 1, i = 217},
{ x = 200, y = 312, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 312, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 312, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 312, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 328, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 344, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 360, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 376, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 392, n = {l = 10}, t = 1, i = 217},
{ x = 248, y = 408, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 408, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 408, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 392, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 376, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 360, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 344, n = {l = 10}, t = 1, i = 217},
{ x = 216, y = 328, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 328, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 344, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 360, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 376, n = {l = 10}, t = 1, i = 217},
{ x = 232, y = 392, n = {l = 10}, t = 1, i = 217},
{ x = 168, y = 472, n = {l = 10}, t = 1, i = 17},
{ x = 104, y = 472, n = {l = 10}, t = 1, i = 17},
{ x = 8, y = 488, n = {l = 10}, t = 1, i = 25},
{ x = 24, y = 488, n = {l = 10}, t = 1, i = 25},
{ x = 40, y = 488, n = {l = 10}, t = 1, i = 25},
{ x = 8, y = 472, n = {l = 10}, t = 1, i = 9},
{ x = 24, y = 472, n = {l = 10}, t = 1, i = 33},
{ x = 40, y = 472, n = {l = 10}, t = 1, i = 41},
{ x = 88, y = 472, n = {l = 10}, t = 1, i = 41},
{ x = 152, y = 472, n = {l = 10}, t = 1, i = 65},
{ x = 136, y = 472, n = {l = 10}, t = 1, i = 65},
{ x = 72, y = 472, n = {l = 10}, t = 1, i = 65},
{ x = 56, y = 472, n = {l = 10}, t = 1, i = 6},
{ x = 120, y = 472, n = {l = 10}, t = 1, i = 6},
{ x = 424, y = 472, n = {l = 10}, t = 1, i = 41},
{ x = 472, y = 472, n = {l = 10}, t = 1, i = 41},
{ x = 408, y = 472, n = {l = 10}, t = 1, i = 65},
{ x = 456, y = 472, n = {l = 10}, t = 1, i = 65},
{ x = 488, y = 472, n = {l = 10}, t = 1, i = 65},
{ x = 392, y = 472, n = {l = 10}, t = 1, i = 6},
{ x = 440, y = 472, n = {l = 10}, t = 1, i = 6},
{ x = 504, y = 472, n = {l = 10}, t = 1, i = 6},
----------End of gameObjects----------
}
return room
