local u = require "utilities"
local o = require "GameObjects.objects"

local rm = {}

rm.sto = require "Rooms.symbols_to_objects"

-- Table that takes a room table and builds it in the world
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
    local col_length = room_part.col_length or 0

    -- initialize indices
    local i = 1
    local j = 1

    -- Store calculation to avoid repeating in the for loop
    local number_of_elements = #room_part

    -- iterate over all elements of a room_part
    for _ = 1, number_of_elements do
      local element = rm.sto[room_part[i+(j-1)*row_length]]:new()
      element.xstart = x_that_I_start + (i-1) * tile_width
      element.ystart = y_that_I_start + (j-1) * tile_height
      -- Make sure to use as few edge shapes as necessary
      if element.physical_properties.tile then
        if j == 1 then
          if i == 1 then
            element.physical_properties.tile = {"u", "l"} -- upper left
          elseif i == row_length then
            element.physical_properties.tile = {"u", "r"} -- upper right and so forth
          else
            element.physical_properties.tile = {"u"}
          end
        elseif j == col_length then
          if i == 1 then
            element.physical_properties.tile = {"d", "l"}
          elseif i == row_length then
            element.physical_properties.tile = {"d", "r"}
          else
            element.physical_properties.tile = {"d"}
          end
        else
          if i == 1 then
            element.physical_properties.tile = {"l"}
          elseif i == row_length then
            element.physical_properties.tile = {"r"}
          else
            element.physical_properties.tile = {"none"}
          end
        end
      end
      o.addToWorld(element)

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
