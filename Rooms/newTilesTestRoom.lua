local rm = require("Rooms.room_manager")
local sh = require "scaling_handler"
local im = require "image"
local u = require "utilities"

local room = {}

room.music_info = {"Music/MusicTest2"}--{"Music/MusicTest"}

room.width = 496
room.height = 448
room.downTrans = {
  {
    roomTarget = "Rooms/NWTestRoom.lua", -- Room you'll go to if this transition happens
    xleftmost = 0, xrightmost = 496, -- Limits to check against
    xmod = 0, ymod = 0 -- Modification of x, y variables for next room
  }
}
room.rightTrans = {
  {
    roomTarget = "Rooms/newTilesTestRoom2.lua", -- Room you'll go to if this transition happens
    yupper = 0, ylower = 450, -- Limits to check against
    xmod = 0, ymod = 0 -- Modification of x, y variables for next room
  }
}
room.leftTrans = {
  {
    roomTarget = "Rooms/TestRoom1.lua", -- Room you'll go to if this transition happens
    yupper = 0, ylower = 450, -- Limits to check against
    xmod = 0, ymod = 0 -- Modification of x, y variables for next room
  }
}
room.upTrans = {
  {
    roomTarget = "Rooms/NWTestRoom.lua", -- Room you'll go to if this transition happens
    xleftmost = 0, xrightmost = 496, -- Limits to check against
    xmod = 0, ymod = 0 -- Modification of x, y variables for next room
  }
}

room.game_scale = 2

room.room_parts = {}
----------Start of arrays of geography of parts of room----------
---
local room_part = {
'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'ld', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'ld', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'ld', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'g', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'g', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'g', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'g', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'g', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'g', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'g', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f', 'f',
}
room_part.x_that_I_start = 8
room_part.y_that_I_start = 8
room_part.row_length = 31
room_part.col_length = 28
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 10
room_part.tileset = im.spriteSettings.floorOutside
room_part.tileset_index_table = {
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 3, 0, 0, 0, 21, 21, 21, 11, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0, 21, 25, 21, 21, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35, 21, 21, 21, 21, 0, 0, 1, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 38, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, 0, 0, 16, 0, 0, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, 0, 0, 0, 0, 0, 0, 2, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'twnw', 'twu', 'twu', 'n', 'n', 'n', 'twsw', 'n', 'twd', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
}
room_part.x_that_I_start = 184
room_part.y_that_I_start = 184
room_part.row_length = 3
room_part.col_length = 6
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.solidsOutside
room_part.tileset_index_table = {
0, 1, 1, nil, nil, nil, 33, nil, 34, 44, 45, 45, 44, 56, 45, 55, 56, 56,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'twne', 'n', 'twse', 'w', 'w', 'w',
}
room_part.x_that_I_start = 248
room_part.y_that_I_start = 184
room_part.row_length = 1
room_part.col_length = 6
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.solidsOutside
room_part.tileset_index_table = {
2, nil, 35, 46, 46, 57,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'twu',
}
room_part.x_that_I_start = 232
room_part.y_that_I_start = 184
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.solidsOutside
room_part.tileset_index_table = {
1,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'f',
}
room_part.x_that_I_start = 232
room_part.y_that_I_start = 216
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.floorOutside
room_part.tileset_index_table = {
18,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'eL',
}
room_part.x_that_I_start = 184
room_part.y_that_I_start = 200
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {height = 48}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.solidsOutside
room_part.tileset_index_table = {
22,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'eD',
}
room_part.x_that_I_start = 200
room_part.y_that_I_start = 216
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {height = 48}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.solidsOutside
room_part.tileset_index_table = {
23,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'eR',
}
room_part.x_that_I_start = 248
room_part.y_that_I_start = 200
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {height = 48}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.solidsOutside
room_part.tileset_index_table = {
24,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'sL', 'sL', 'sL', 'sL', 'sL', 'sL', 'sL', 'sL', 'sL',
}
room_part.x_that_I_start = 312
room_part.y_that_I_start = 200
room_part.row_length = 3
room_part.col_length = 3
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.solidsOutside
room_part.tileset_index_table = {
53, 53, 53, 53, 53, 53, 53, 53, 53,
}

table.insert(room.room_parts, room_part)
---
local room_part = {
'itgvr'
}
room_part.x_that_I_start = 222
room_part.y_that_I_start = 188
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 20

table.insert(room.room_parts, room_part)
---
local room_part = {
blueprint = "GlobalNpcs.mobilityGiver"
}
room_part.x_that_I_start = 272
room_part.y_that_I_start = 222
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 20

table.insert(room.room_parts, room_part)
---
local room_part = {blueprint = 'GlobalNpcs.saver'}
room_part.x_that_I_start = 248
room_part.y_that_I_start = 280
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 20

table.insert(room.room_parts, room_part)
---
local room_part = {blueprint = 'GlobalNpcs.chest'}
room_part.x_that_I_start = 281
room_part.y_that_I_start = 313
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}

table.insert(room.room_parts, room_part)
---
local room_part = {blueprint = 'GlobalNpcs.sign'}
room_part.x_that_I_start = 241
room_part.y_that_I_start = 313
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}

table.insert(room.room_parts, room_part)
---
local room_part = {
blueprint = "GlobalNpcs.instructionsDialogue"
}
room_part.x_that_I_start = 292
room_part.y_that_I_start = 0
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 20

table.insert(room.room_parts, room_part)
---
local room_part = {
'ptl'
}
room_part.x_that_I_start = 200
room_part.y_that_I_start = 288
room_part.row_length = 3
room_part.col_length = 4
room_part.tile_width = 16
room_part.init = {
  destination = "Rooms/TestRoomBoss.lua",
  desx = 55,
  desy = 85,
  grounded = true
}
room_part.init.layer = 11
room_part.tileset = im.spriteSettings.basicFriendlyInterior
room_part.tileset_index_table = {
4+11*3
}

table.insert(room.room_parts, room_part)
---
local room_part = {
blueprint = "enemies.slime"
}
-- room_part.x_that_I_start = 372
-- room_part.y_that_I_start = 222
local possibleCoords = {{368, 224}, {96, 176}, {208, 80}, {176, 368}}
local chosenKey = u.chooseKeyFromTable(possibleCoords)
room_part.x_that_I_start = possibleCoords[chosenKey][1]
room_part.y_that_I_start = possibleCoords[chosenKey][2]
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}
room_part.init.layer = 20

table.insert(room.room_parts, room_part)
---
local room_part = {
blueprint = "enemies.raven"
}
room_part.x_that_I_start = 30
room_part.y_that_I_start = 368
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}

table.insert(room.room_parts, room_part)
---
local room_part = {
blueprint = "enemies.crow"
}
room_part.x_that_I_start = 432
room_part.y_that_I_start = 368
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}

table.insert(room.room_parts, room_part)
---
local room_part = {
blueprint = "RockTest"
}
room_part.x_that_I_start = 372
room_part.y_that_I_start = 111
room_part.row_length = 1
room_part.col_length = 1
room_part.tile_width = 16
room_part.init = {}

table.insert(room.room_parts, room_part)
-- ---
-- local room_part = {
-- blueprint = "GlobalNpcs.autoActivatedDlg"
-- }
-- room_part.x_that_I_start = 372
-- room_part.y_that_I_start = 111
-- room_part.row_length = 1
-- room_part.col_length = 1
-- room_part.tile_width = 16
-- room_part.init = {}
--
-- table.insert(room.room_parts, room_part)
----------End of arrays of geography of parts of room----------

return room
