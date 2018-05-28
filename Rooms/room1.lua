local rm = require("Rooms.room_manager")

room = {}

room.width = 800
room.height = 450
room.subrooms = {}
layers = 3

sprites = {
  player1 = love.graphics.newImage("Sprites/Test.png"),
  brick = love.graphics.newImage("Sprites/Brick.png")
}


local subroom = {
  'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x',
  'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x',
  'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x',
  'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x',
}
subroom.x_that_I_start = 200
subroom.y_that_I_start = 300
subroom.carriage_return = 15
subroom.tile_width = 16

table.insert(room.subrooms, subroom)

local subroom = {'P1'}
subroom.x_that_I_start = 300
subroom.y_that_I_start = 200

table.insert(room.subrooms, subroom)


rm.build_room(room)


return room
