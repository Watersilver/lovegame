local Brick = require("BrickTest")
local Player = require("PlayaTest")

rm = {}

local symbols_to_objects = {
  x = Brick,
  P1 = Player
}

function rm.build_room(room)

  local rwidth = room.width
  local rheight = room.height
  local rsubs = room.subrooms

  for index, subroom in pairs(rsubs) do
    if subroom.x_that_I_start == nil then subroom.x_that_I_start = 0 end
    if subroom.y_that_I_start == nil then subroom.y_that_I_start = 0 end
    if subroom.tile_width == nil then subroom.tile_width = 0 end

    local number_of_elements = #subroom

    local i = 1
    local j = 1
    for index = 1, number_of_elements do
      local element = symbols_to_objects[subroom[i]]:new()
      element.position = {
        x = subroom.x_that_I_start + (i-1) * subroom.tile_width,
        y = subroom.y_that_I_start + (j-1) * subroom.tile_width
      }
      element:instantiate()
      i = i + 1
      if subroom.carriage_return and subroom.carriage_return < i then
        i = 1
        j = j + 1
      end
    end

  end



end

function rm.clear_room()
-- todo
end

return rm
