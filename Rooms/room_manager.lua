local Brick = require("BrickTest")
local Player = require("PlayaTest")

local rm = {}

local symbols_to_objects = {
  x = Brick,
  P1 = Player
}

-- Takes that takes a room table and builds it in the world
function rm.build_room(room)

  -- Probably for the camera world
  local rwidth = room.width
  local rheight = room.height

  -- Store room parts (e.g. a set of blocks, background stuff, player, etc.)
  local rparts = room.room_parts

  -- iterate over room parts
  for _, room_part in ipairs(rparts) do
    -- avoid nil values and store all useful stuff to local variables
    local x_that_I_start = room_part.x_that_I_start or 0
    local y_that_I_start = room_part.y_that_I_start or 0
    local tile_width = room_part.tile_width or 0
    local tile_height = room_part.tile_height or tile_width or 0
    local row_length = room_part.row_length or 0

    -- initialize indexes
    local i = 1
    local j = 1

    -- Store calculation to avoid repeating in the for loop
    local number_of_elements = #room_part

    -- iterate over all elements of a room_part
    for _ = 1, number_of_elements do
      local element = symbols_to_objects[room_part[i+(j-1)*row_length]]:new()
      element.position = {
        x = x_that_I_start + (i-1) * tile_width,
        y = y_that_I_start + (j-1) * tile_height
      }
      element.mask:moveTo(element.position.x, element.position.y)
      addToWorld(element)

      i = i + 1
      if row_length > 0 and row_length < i then
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
