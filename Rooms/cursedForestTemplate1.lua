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
    roomTarget = "Rooms/cursedForestTemplate1.lua",
    xleftmost = 0, xrightmost = 264,
    xmod = 0, ymod = 0
  },
  {
    roomTarget = "Rooms/cursedForest/Crossroads.lua",
    xleftmost = 265, xrightmost = 520,
    xmod = 0, ymod = 0
  }
}
room.rightTrans = {
  {
    roomTarget = "Rooms/cursedForestTemplate1.lua",
    yupper = 0, ylower = 200,
    xmod = 0, ymod = 0
  },
  {
    roomTarget = "Rooms/cursedForest/Crossroads.lua",
    yupper = 201, ylower = 328,
    xmod = 0, ymod = 0
  },
  {
    roomTarget = "Rooms/cursedForestTemplate1.lua",
    yupper = 329, ylower = 520,
    xmod = 0, ymod = 0
  }
}
room.leftTrans = {
  {
    roomTarget = "Rooms/cursedForest/r01.lua",
    yupper = 0, ylower = 200,
    xmod = 0, ymod = 0
  },
  {
    roomTarget = "Rooms/cursedForest/Crossroads.lua",
    yupper = 201, ylower = 328,
    xmod = 0, ymod = 0
  },
  {
    roomTarget = "Rooms/cursedForestTemplate1.lua",
    yupper = 329, ylower = 520,
    xmod = 0, ymod = 0
  }
}
room.upTrans = {
  {
    roomTarget = "Rooms/cursedForestTemplate1.lua",
    xleftmost = 0, xrightmost = 264,
    xmod = 0, ymod = 0
  },
  {
    roomTarget = "Rooms/cursedForest/Crossroads.lua",
    xleftmost = 265, xrightmost = 520,
    xmod = 0, ymod = 0
  }
}

room.game_scale = 2

room.gameObjects = {
----------Start of gameObjects----------
{ x = 8, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 24, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 40, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 56, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 72, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 88, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 104, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 120, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 216, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 232, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 248, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 264, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 280, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 296, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 392, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 408, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 424, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 440, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 456, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 472, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 488, y = 8, n = {l = 10}, t = 2, i = 252},
{ x = 504, y = 8, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 24, n = {l = 10}, t = 2, i = 246},
{ x = 8, y = 40, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 56, n = {l = 10}, t = 2, i = 246},
{ x = 8, y = 72, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 152, n = {l = 10}, t = 2, i = 245},
{ x = 24, y = 152, n = {l = 10}, t = 2, i = 246},
{ x = 24, y = 168, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 168, n = {l = 10}, t = 2, i = 255},
{ x = 8, y = 216, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 360, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 344, n = {l = 10}, t = 2, i = 246},
{ x = 8, y = 328, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 296, n = {l = 10}, t = 2, i = 245},
{ x = 24, y = 296, n = {l = 10}, t = 2, i = 246},
{ x = 24, y = 312, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 440, n = {l = 10}, t = 2, i = 245},
{ x = 24, y = 440, n = {l = 10}, t = 2, i = 246},
{ x = 24, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 24, y = 472, n = {l = 10}, t = 2, i = 246},
{ x = 8, y = 472, n = {l = 10}, t = 2, i = 254},
{ x = 8, y = 504, n = {l = 10}, t = 2, i = 254},
{ x = 8, y = 488, n = {l = 10}, t = 2, i = 255},
{ x = 8, y = 456, n = {l = 10}, t = 2, i = 255},
{ x = 24, y = 456, n = {l = 10}, t = 2, i = 253},
{ x = 24, y = 488, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 200, n = {l = 10}, t = 2, i = 246},
{ x = 8, y = 184, n = {l = 10}, t = 2, i = 253},
{ x = 8, y = 312, n = {l = 10}, t = 2, i = 255},
{ x = 40, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 56, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 72, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 88, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 104, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 120, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 216, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 232, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 248, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 264, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 280, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 296, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 392, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 408, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 424, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 440, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 456, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 472, y = 504, n = {l = 10}, t = 2, i = 246},
{ x = 488, y = 504, n = {l = 10}, t = 2, i = 245},
{ x = 488, y = 472, n = {l = 10}, t = 2, i = 245},
{ x = 488, y = 488, n = {l = 10}, t = 2, i = 252},
{ x = 488, y = 456, n = {l = 10}, t = 2, i = 252},
{ x = 488, y = 440, n = {l = 10}, t = 2, i = 245},
{ x = 504, y = 440, n = {l = 10}, t = 2, i = 246},
{ x = 504, y = 504, n = {l = 10}, t = 2, i = 255},
{ x = 504, y = 488, n = {l = 10}, t = 2, i = 254},
{ x = 504, y = 472, n = {l = 10}, t = 2, i = 255},
{ x = 504, y = 456, n = {l = 10}, t = 2, i = 254},
{ x = 504, y = 360, n = {l = 10}, t = 2, i = 252},
{ x = 504, y = 344, n = {l = 10}, t = 2, i = 245},
{ x = 504, y = 328, n = {l = 10}, t = 2, i = 252},
{ x = 488, y = 296, n = {l = 10}, t = 2, i = 245},
{ x = 504, y = 296, n = {l = 10}, t = 2, i = 246},
{ x = 488, y = 312, n = {l = 10}, t = 2, i = 252},
{ x = 504, y = 312, n = {l = 10}, t = 2, i = 254},
{ x = 504, y = 216, n = {l = 10}, t = 2, i = 252},
{ x = 504, y = 200, n = {l = 10}, t = 2, i = 245},
{ x = 504, y = 184, n = {l = 10}, t = 2, i = 252},
{ x = 504, y = 168, n = {l = 10}, t = 2, i = 254},
{ x = 488, y = 168, n = {l = 10}, t = 2, i = 252},
{ x = 488, y = 152, n = {l = 10}, t = 2, i = 245},
{ x = 504, y = 152, n = {l = 10}, t = 2, i = 246},
{ x = 504, y = 24, n = {l = 10}, t = 2, i = 245},
{ x = 504, y = 40, n = {l = 10}, t = 2, i = 252},
{ x = 504, y = 56, n = {l = 10}, t = 2, i = 245},
{ x = 504, y = 72, n = {l = 10}, t = 2, i = 252},
{ x = 8, y = 88, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 104, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 120, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 136, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 232, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 248, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 264, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 280, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 376, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 392, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 408, n = {l = 10}, t = 1, i = 3},
{ x = 8, y = 424, n = {l = 10}, t = 1, i = 3},
{ x = 152, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 168, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 184, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 200, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 136, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 312, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 328, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 344, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 360, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 376, y = 8, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 88, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 104, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 120, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 136, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 232, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 248, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 264, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 280, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 376, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 392, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 408, n = {l = 10}, t = 1, i = 3},
{ x = 504, y = 424, n = {l = 10}, t = 1, i = 3},
{ x = 376, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 360, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 344, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 328, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 312, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 200, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 184, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 168, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 152, y = 504, n = {l = 10}, t = 1, i = 3},
{ x = 136, y = 504, n = {l = 10}, t = 1, i = 3},
----------End of gameObjects----------
}
return room
