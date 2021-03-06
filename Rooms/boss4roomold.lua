local rm = require("RoomBuilding.room_manager")
local sh = require "scaling_handler"
local im = require "image"
local snd = require "sound"

local room = {}
room.newType = true

room.music_info = snd.silence
room.timeScreenEffect = 'fullLight'

room.width = 400
room.height = 304
room.downTrans = {}
room.rightTrans = {}
room.leftTrans = {}
room.upTrans = {}

room.game_scale = 2

room.gameObjects = {
----------Start of gameObjects----------
{ x = 24, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 40, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 56, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 184, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 152, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 168, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 216, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 248, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 232, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 280, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 216, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 264, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 232, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 248, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 120, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 184, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 168, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 136, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 376, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 88, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 72, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 24, n = {l = 10}, t = 1, i = 253},
{ x = 360, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 344, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 40, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 56, n = {l = 10}, t = 1, i = 253},
{ x = 24, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 40, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 56, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 72, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 88, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 120, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 136, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 152, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 168, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 184, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 216, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 232, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 248, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 264, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 280, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 312, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 328, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 344, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 360, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 376, y = 104, n = {l = 10}, t = 1, i = 246},
{ x = 24, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 40, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 56, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 72, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 88, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 120, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 136, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 152, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 168, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 184, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 216, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 232, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 248, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 264, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 280, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 312, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 328, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 344, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 360, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 376, y = 200, n = {l = 10}, t = 1, i = 246},
{ x = 104, y = 280, n = {l = 10}, t = 1, i = 245},
{ x = 200, y = 280, n = {l = 10}, t = 1, i = 245},
{ x = 296, y = 280, n = {l = 10}, t = 1, i = 245},
{ x = 296, y = 24, n = {l = 10}, t = 1, i = 244},
{ x = 200, y = 24, n = {l = 10}, t = 1, i = 244},
{ x = 104, y = 24, n = {l = 10}, t = 1, i = 244},
{ x = 392, y = 24, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 40, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 56, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 72, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 88, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 120, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 136, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 152, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 168, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 184, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 216, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 232, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 248, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 264, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 280, n = {l = 10}, t = 2, i = 162},
{ x = 392, y = 296, n = {l = 10}, t = 2, i = 169},
{ x = 392, y = 8, n = {l = 10}, t = 2, i = 155},
{ x = 376, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 360, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 344, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 328, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 312, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 280, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 264, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 248, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 232, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 216, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 184, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 120, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 88, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 72, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 56, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 40, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 24, y = 296, n = {l = 10}, t = 2, i = 156},
{ x = 24, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 40, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 56, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 72, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 88, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 120, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 136, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 152, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 168, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 184, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 280, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 312, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 328, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 344, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 360, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 376, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 8, y = 296, n = {l = 10}, t = 2, i = 168},
{ x = 8, y = 280, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 264, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 248, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 232, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 216, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 184, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 168, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 152, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 136, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 120, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 88, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 72, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 56, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 40, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 24, n = {l = 10}, t = 2, i = 161},
{ x = 8, y = 8, n = {l = 10}, t = 2, i = 154},
{ x = 104, y = 8, n = {l = 10}, t = 2, i = 163},
{ x = 216, y = 8, n = {l = 10}, t = 2, i = 149},
{ x = 200, y = 8, n = {l = 10}, t = 2, i = 163},
{ x = 296, y = 8, n = {l = 10}, t = 2, i = 163},
{ x = 392, y = 104, n = {l = 10}, t = 2, i = 170},
{ x = 392, y = 200, n = {l = 10}, t = 2, i = 170},
{ x = 296, y = 296, n = {l = 10}, t = 2, i = 177},
{ x = 200, y = 296, n = {l = 10}, t = 2, i = 177},
{ x = 104, y = 296, n = {l = 10}, t = 2, i = 177},
{ x = 8, y = 200, n = {l = 10}, t = 2, i = 184},
{ x = 8, y = 104, n = {l = 10}, t = 2, i = 184},
{ x = 136, y = 296, n = {l = 10}, t = 2, i = 159},
{ x = 168, y = 296, n = {l = 10}, t = 2, i = 160},
{ x = 264, y = 8, n = {l = 10}, t = 2, i = 153},
{ x = 232, y = 8, n = {l = 10}, t = 2, i = 152},
{ x = 136, y = 280, n = {l = 10}, t = 1, i = 252},
{ x = 168, y = 280, n = {l = 10}, t = 1, i = 252},
{ x = 152, y = 296, n = {l = 10}, t = 1, i = 252},
{ x = 152, y = 280, n = {l = 10}, t = 1, i = 252},
{ x = 152, y = 264, n = {l = 10}, t = 1, i = 252},
{ x = 232, y = 24, n = {l = 10}, t = 1, i = 252},
{ x = 264, y = 24, n = {l = 10}, t = 1, i = 252},
{ x = 248, y = 40, n = {l = 10}, t = 1, i = 252},
{ x = 248, y = 24, n = {l = 10}, t = 1, i = 252},
{ x = 248, y = 8, n = {l = 10}, t = 1, i = 252},
{ x = 88, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 72, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 120, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 136, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 264, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 280, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 312, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 328, y = 152, n = {l = 10}, t = 1, i = 253},
{ x = 88, y = 88, n = {l = 10}, t = 1, i = 252},
{ x = 88, y = 120, n = {l = 10}, t = 1, i = 252},
{ x = 120, y = 120, n = {l = 10}, t = 1, i = 252},
{ x = 120, y = 88, n = {l = 10}, t = 1, i = 252},
{ x = 24, y = 24, n = {l = 11}, t = 5, i = 47},
{ x = 24, y = 40, n = {l = 11}, t = 5, i = 47},
{ x = 40, y = 24, n = {l = 11}, t = 5, i = 47},
{ x = 360, y = 24, n = {l = 11}, t = 5, i = 47},
{ x = 376, y = 24, n = {l = 11}, t = 5, i = 47},
{ x = 376, y = 40, n = {l = 11}, t = 5, i = 47},
{ x = 376, y = 264, n = {l = 11}, t = 5, i = 47},
{ x = 376, y = 280, n = {l = 11}, t = 5, i = 47},
{ x = 360, y = 280, n = {l = 11}, t = 5, i = 47},
{ x = 40, y = 280, n = {l = 11}, t = 5, i = 47},
{ x = 24, y = 280, n = {l = 11}, t = 5, i = 47},
{ x = 24, y = 264, n = {l = 11}, t = 5, i = 47},
----------End of gameObjects----------
}

room.manuallyPlacedObjects = {
  { x = 0, y = 0, blueprint = "bosses.boss4.cutscene"},
  { x = 152, y = 0, n = {side = "down"}, blueprint = "misc.DunDoor"},
  { x = 248, y = 0, n = {side = "up"}, blueprint = "misc.DunDoor"},
}

-- I forgot to add some gaps. Make them here
for i = 40, room.width - 32, 16 do
  for j = 40, room.height - 32, 16 do
    if i == 104 or i == 200 or i == 296 then
      table.insert(room.gameObjects, {
        x = i, y = j, n = {l = 11}, t = 1, i = 261
      })
    end
  end
end
-- room.width = 400
-- room.height = 304
for i = 8 + 16, room.width - 16, 16 do
  for j = 8 + 16, room.height - 16, 16 do
    if (i == 104 or i == 200 or i == 296) or (j == 104 or j == 200) then
      table.insert(room.gameObjects, {
        x = i, y = j, n = {l = 11, cutscenePlummet = true}, t = 1, i = 241
      })
    end
  end
end

return room
