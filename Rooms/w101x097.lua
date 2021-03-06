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
    roomTarget = "Rooms/w101x098.lua",
    xleftmost = 0, xrightmost = 520,
    xmod = 0, ymod = 0
  }
}
room.rightTrans = {
  {
    roomTarget = "Rooms/w102x097.lua",
    yupper = 0, ylower = 520,
    xmod = 0, ymod = 0
  }
}
room.leftTrans = {}
room.upTrans = {
  {
    roomTarget = "Rooms/w101x096.lua",
    xleftmost = 0, xrightmost = 520,
    xmod = 0, ymod = 0
  }
}

room.game_scale = 2

room.gameObjects = {
----------Start of gameObjects----------
{ x = 504, y = 8, n = {l = 10}, t = 2, i = 58},
{ x = 504, y = 200, n = {l = 10}, t = 2, i = 65},
{ x = 504, y = 216, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 232, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 248, n = {l = 10}, t = 2, i = 58},
{ x = 504, y = 424, n = {l = 10}, t = 2, i = 65},
{ x = 504, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 264, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 296, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 312, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 328, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 344, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 376, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 392, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 408, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 360, n = {l = 10}, t = 1, i = 151},
{ x = 504, y = 280, n = {l = 10}, t = 1, i = 151},
{ x = 504, y = 24, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 40, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 56, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 72, n = {l = 10}, t = 1, i = 141},
{ x = 504, y = 168, n = {l = 10}, t = 1, i = 165},
{ x = 504, y = 184, n = {l = 10}, t = 1, i = 165},
{ x = 488, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 440, y = 504, n = {l = 10}, t = 2, i = 57},
{ x = 424, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 504, n = {l = 10}, t = 2, i = 56},
{ x = 328, y = 504, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 504, n = {l = 10}, t = 2, i = 69},
{ x = 264, y = 504, n = {l = 10}, t = 2, i = 56},
{ x = 344, y = 504, n = {l = 10}, t = 1, i = 227},
{ x = 440, y = 488, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 472, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 456, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 440, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 424, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 408, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 392, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 376, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 360, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 344, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 328, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 312, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 296, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 280, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 264, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 248, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 232, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 216, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 200, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 184, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 168, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 152, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 136, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 120, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 104, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 88, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 72, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 56, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 40, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 24, n = {l = 10}, t = 2, i = 57},
{ x = 440, y = 8, n = {l = 10}, t = 2, i = 57},
{ x = 264, y = 488, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 472, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 456, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 440, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 424, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 408, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 392, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 376, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 360, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 344, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 328, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 312, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 296, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 280, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 264, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 248, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 232, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 216, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 200, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 184, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 168, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 152, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 136, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 120, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 104, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 88, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 72, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 56, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 40, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 24, n = {l = 10}, t = 2, i = 56},
{ x = 264, y = 8, n = {l = 10}, t = 2, i = 56},
{ x = 280, y = 8, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 8, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 8, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 8, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 8, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 8, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 8, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 24, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 40, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 56, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 72, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 248, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 264, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 280, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 296, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 328, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 424, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 184, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 168, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 152, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 104, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 88, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 72, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 56, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 40, n = {l = 10}, t = 2, i = 69},
{ x = 280, y = 24, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 24, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 24, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 24, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 24, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 24, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 40, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 408, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 424, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 168, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 152, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 104, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 40, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 40, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 40, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 40, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 56, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 56, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 72, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 248, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 264, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 280, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 296, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 408, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 392, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 184, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 168, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 152, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 104, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 88, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 72, n = {l = 10}, t = 2, i = 69},
{ x = 296, y = 56, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 56, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 56, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 72, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 72, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 72, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 88, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 104, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 104, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 104, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 104, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 248, n = {l = 10}, t = 2, i = 69},
{ x = 392, y = 264, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 184, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 168, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 152, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 312, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 152, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 168, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 184, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 200, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 216, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 296, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 296, n = {l = 10}, t = 2, i = 69},
{ x = 344, y = 312, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 376, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 360, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 344, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 264, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 248, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 168, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 152, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 376, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 360, y = 152, n = {l = 10}, t = 2, i = 69},
{ x = 328, y = 488, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 472, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 456, n = {l = 10}, t = 2, i = 57},
{ x = 360, y = 488, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 472, n = {l = 10}, t = 2, i = 56},
{ x = 376, y = 456, n = {l = 10}, t = 2, i = 56},
{ x = 344, y = 488, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 472, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 456, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 456, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 456, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 440, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 424, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 440, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 424, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 408, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 392, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 408, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 392, n = {l = 10}, t = 1, i = 227},
{ x = 376, y = 424, n = {l = 10}, t = 1, i = 227},
{ x = 392, y = 424, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 424, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 408, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 392, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 376, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 360, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 328, n = {l = 10}, t = 3, i = 5},
{ x = 408, y = 344, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 376, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 360, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 344, n = {l = 10}, t = 1, i = 227},
{ x = 312, y = 328, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 328, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 312, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 296, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 280, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 264, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 248, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 232, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 216, n = {l = 10}, t = 1, i = 227},
{ x = 296, y = 200, n = {l = 10}, t = 1, i = 227},
{ x = 328, y = 328, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 328, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 328, n = {l = 10}, t = 1, i = 227},
{ x = 376, y = 312, n = {l = 10}, t = 1, i = 227},
{ x = 376, y = 328, n = {l = 10}, t = 1, i = 227},
{ x = 376, y = 296, n = {l = 10}, t = 1, i = 227},
{ x = 376, y = 280, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 280, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 280, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 264, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 248, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 232, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 232, n = {l = 10}, t = 1, i = 227},
{ x = 376, y = 232, n = {l = 10}, t = 1, i = 227},
{ x = 392, y = 232, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 232, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 216, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 200, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 216, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 200, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 184, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 184, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 168, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 152, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 136, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 120, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 104, n = {l = 10}, t = 1, i = 227},
{ x = 408, y = 88, n = {l = 10}, t = 1, i = 227},
{ x = 392, y = 88, n = {l = 10}, t = 1, i = 227},
{ x = 376, y = 88, n = {l = 10}, t = 1, i = 227},
{ x = 360, y = 88, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 88, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 72, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 56, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 40, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 24, n = {l = 10}, t = 1, i = 227},
{ x = 344, y = 8, n = {l = 10}, t = 1, i = 227},
{ x = 312, y = 440, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 424, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 408, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 392, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 376, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 360, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 344, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 328, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 312, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 296, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 280, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 264, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 248, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 232, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 216, n = {l = 10}, t = 2, i = 57},
{ x = 280, y = 200, n = {l = 10}, t = 2, i = 57},
{ x = 312, y = 200, n = {l = 10}, t = 2, i = 56},
{ x = 312, y = 216, n = {l = 10}, t = 2, i = 56},
{ x = 312, y = 232, n = {l = 10}, t = 2, i = 56},
{ x = 312, y = 248, n = {l = 10}, t = 2, i = 56},
{ x = 312, y = 264, n = {l = 10}, t = 2, i = 56},
{ x = 312, y = 280, n = {l = 10}, t = 2, i = 56},
{ x = 312, y = 296, n = {l = 10}, t = 2, i = 56},
{ x = 312, y = 312, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 312, n = {l = 10}, t = 2, i = 57},
{ x = 360, y = 296, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 280, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 264, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 248, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 232, n = {l = 10}, t = 2, i = 57},
{ x = 344, y = 216, n = {l = 10}, t = 2, i = 57},
{ x = 344, y = 200, n = {l = 10}, t = 2, i = 57},
{ x = 344, y = 184, n = {l = 10}, t = 2, i = 57},
{ x = 376, y = 184, n = {l = 10}, t = 2, i = 56},
{ x = 376, y = 200, n = {l = 10}, t = 2, i = 56},
{ x = 376, y = 216, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 248, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 264, n = {l = 10}, t = 2, i = 56},
{ x = 392, y = 280, n = {l = 10}, t = 2, i = 56},
{ x = 392, y = 296, n = {l = 10}, t = 2, i = 56},
{ x = 392, y = 312, n = {l = 10}, t = 2, i = 56},
{ x = 392, y = 328, n = {l = 10}, t = 2, i = 56},
{ x = 344, y = 344, n = {l = 10}, t = 2, i = 56},
{ x = 344, y = 360, n = {l = 10}, t = 2, i = 56},
{ x = 344, y = 376, n = {l = 10}, t = 2, i = 56},
{ x = 344, y = 392, n = {l = 10}, t = 2, i = 61},
{ x = 344, y = 408, n = {l = 10}, t = 2, i = 61},
{ x = 344, y = 424, n = {l = 10}, t = 2, i = 61},
{ x = 344, y = 440, n = {l = 10}, t = 2, i = 61},
{ x = 376, y = 440, n = {l = 10}, t = 2, i = 56},
{ x = 376, y = 408, n = {l = 10}, t = 2, i = 56},
{ x = 376, y = 392, n = {l = 10}, t = 2, i = 56},
{ x = 392, y = 408, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 392, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 376, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 360, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 344, n = {l = 10}, t = 2, i = 57},
{ x = 424, y = 344, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 360, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 376, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 392, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 408, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 424, n = {l = 10}, t = 2, i = 56},
{ x = 392, y = 216, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 200, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 184, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 168, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 152, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 136, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 120, n = {l = 10}, t = 2, i = 57},
{ x = 392, y = 104, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 88, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 72, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 56, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 40, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 24, n = {l = 10}, t = 2, i = 57},
{ x = 328, y = 8, n = {l = 10}, t = 2, i = 57},
{ x = 360, y = 8, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 24, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 40, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 56, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 72, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 88, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 104, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 120, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 136, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 152, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 168, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 184, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 200, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 216, n = {l = 10}, t = 2, i = 56},
{ x = 424, y = 232, n = {l = 10}, t = 2, i = 56},
{ x = 360, y = 168, n = {l = 10}, t = 3, i = 5},
{ x = 488, y = 248, n = {l = 10}, t = 2, i = 58},
{ x = 472, y = 248, n = {l = 10}, t = 2, i = 58},
{ x = 488, y = 424, n = {l = 10}, t = 2, i = 65},
{ x = 472, y = 424, n = {l = 10}, t = 2, i = 65},
{ x = 456, y = 424, n = {l = 10}, t = 2, i = 65},
{ x = 456, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 488, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 440, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 456, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 472, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 248, n = {l = 10}, t = 2, i = 58},
{ x = 456, y = 424, n = {l = 11}, t = 5, i = 56},
{ x = 456, y = 248, n = {l = 11}, t = 5, i = 58},
{ x = 456, y = 264, n = {l = 10}, t = 1, i = 141},
{ x = 456, y = 296, n = {l = 10}, t = 1, i = 141},
{ x = 456, y = 312, n = {l = 10}, t = 1, i = 141},
{ x = 456, y = 328, n = {l = 10}, t = 1, i = 141},
{ x = 456, y = 344, n = {l = 10}, t = 1, i = 141},
{ x = 456, y = 360, n = {l = 10}, t = 1, i = 141},
{ x = 488, y = 408, n = {l = 10}, t = 1, i = 141},
{ x = 472, y = 360, n = {l = 10}, t = 1, i = 141},
{ x = 488, y = 376, n = {l = 10}, t = 1, i = 141},
{ x = 488, y = 360, n = {l = 10}, t = 1, i = 141},
{ x = 488, y = 344, n = {l = 10}, t = 1, i = 141},
{ x = 472, y = 328, n = {l = 10}, t = 1, i = 141},
{ x = 472, y = 264, n = {l = 10}, t = 2, i = 35},
{ x = 488, y = 264, n = {l = 10}, t = 2, i = 36},
{ x = 488, y = 280, n = {l = 10}, t = 2, i = 43},
{ x = 488, y = 296, n = {l = 10}, t = 2, i = 43},
{ x = 488, y = 312, n = {l = 10}, t = 2, i = 67},
{ x = 472, y = 312, n = {l = 10}, t = 2, i = 66},
{ x = 472, y = 296, n = {l = 10}, t = 2, i = 42},
{ x = 472, y = 280, n = {l = 10}, t = 2, i = 42},
{ x = 456, y = 376, n = {l = 10}, t = 2, i = 35},
{ x = 472, y = 376, n = {l = 10}, t = 2, i = 36},
{ x = 472, y = 392, n = {l = 10}, t = 2, i = 50},
{ x = 456, y = 392, n = {l = 10}, t = 2, i = 49},
{ x = 456, y = 408, n = {l = 10}, t = 2, i = 63},
{ x = 472, y = 408, n = {l = 10}, t = 2, i = 64},
{ x = 504, y = 88, n = {l = 10}, t = 2, i = 65},
{ x = 504, y = 104, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 504, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 152, n = {l = 10}, t = 2, i = 64},
{ x = 488, y = 136, n = {l = 10}, t = 2, i = 57},
{ x = 488, y = 120, n = {l = 10}, t = 2, i = 57},
{ x = 456, y = 120, n = {l = 10}, t = 2, i = 56},
{ x = 456, y = 136, n = {l = 10}, t = 2, i = 56},
{ x = 456, y = 152, n = {l = 10}, t = 2, i = 63},
{ x = 472, y = 136, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 120, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 88, n = {l = 10}, t = 2, i = 53},
{ x = 488, y = 104, n = {l = 10}, t = 2, i = 50},
{ x = 472, y = 104, n = {l = 10}, t = 2, i = 65},
{ x = 456, y = 104, n = {l = 10}, t = 2, i = 49},
{ x = 456, y = 88, n = {l = 10}, t = 2, i = 42},
{ x = 456, y = 72, n = {l = 10}, t = 2, i = 42},
{ x = 456, y = 56, n = {l = 10}, t = 2, i = 42},
{ x = 456, y = 40, n = {l = 10}, t = 2, i = 35},
{ x = 472, y = 8, n = {l = 10}, t = 2, i = 35},
{ x = 488, y = 8, n = {l = 10}, t = 2, i = 58},
{ x = 472, y = 24, n = {l = 10}, t = 2, i = 42},
{ x = 472, y = 40, n = {l = 10}, t = 2, i = 45},
{ x = 472, y = 152, n = {l = 10}, t = 3, i = 5},
{ x = 488, y = 200, n = {l = 10}, t = 2, i = 65},
{ x = 472, y = 200, n = {l = 10}, t = 2, i = 65},
{ x = 456, y = 200, n = {l = 10}, t = 2, i = 49},
{ x = 456, y = 216, n = {l = 10}, t = 2, i = 56},
{ x = 456, y = 232, n = {l = 10}, t = 2, i = 56},
{ x = 472, y = 216, n = {l = 10}, t = 2, i = 69},
{ x = 472, y = 232, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 232, n = {l = 10}, t = 2, i = 69},
{ x = 488, y = 216, n = {l = 10}, t = 2, i = 69},
{ x = 456, y = 184, n = {l = 10}, t = 2, i = 42},
{ x = 504, y = 152, n = {l = 11}, t = 5, i = 58},
{ x = 456, y = 168, n = {l = 11}, t = 5, i = 60},
{ x = 488, y = 168, n = {l = 10}, t = 1, i = 165},
{ x = 488, y = 184, n = {l = 10}, t = 1, i = 165},
{ x = 472, y = 184, n = {l = 10}, t = 1, i = 165},
{ x = 472, y = 168, n = {l = 10}, t = 1, i = 165},
{ x = 488, y = 24, n = {l = 10}, t = 1, i = 141},
{ x = 488, y = 40, n = {l = 10}, t = 1, i = 141},
{ x = 488, y = 56, n = {l = 10}, t = 1, i = 141},
{ x = 488, y = 72, n = {l = 10}, t = 1, i = 141},
{ x = 472, y = 72, n = {l = 10}, t = 1, i = 141},
{ x = 472, y = 88, n = {l = 10}, t = 1, i = 141},
{ x = 472, y = 56, n = {l = 10}, t = 3, i = 11},
{ x = 504, y = 152, n = {l = 10}, t = 2, i = 59},
{ x = 456, y = 168, n = {l = 10}, t = 2, i = 59},
{ x = 456, y = 280, n = {l = 10}, t = 1, i = 151},
{ x = 472, y = 344, n = {l = 10}, t = 1, i = 151},
{ x = 488, y = 328, n = {l = 10}, t = 1, i = 151},
{ x = 488, y = 392, n = {l = 10}, t = 1, i = 151},
----------End of gameObjects----------
}
return room
