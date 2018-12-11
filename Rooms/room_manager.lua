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
    local tileset = room_part.tileset
    local init = room_part.init
    local tileset_index_table = room_part.tileset_index_table

    -- initialize indices
    local i = 1
    local j = 1

    -- Store calculation to avoid repeating in the for loop
    local number_of_elements = #room_part

    -- If there are symbols, look for element in symbol_to_objects table
    if number_of_elements > 0 then
      -- iterate over all elements of a room_part
      for _ = 1, number_of_elements do

        -- Store place on room part table
        local symbol_index = i+(j-1)*row_length
        -- Store symbol of room part
        local symbol = room_part[symbol_index]
        -- If symbol exists, create corresponding object
        if symbol ~= 'n' then
          local element = rm.sto[symbol]:new(init)
          element.xstart = x_that_I_start + (i-1) * tile_width
          element.ystart = y_that_I_start + (j-1) * tile_height
          element.x = element.xstart
          element.y = element.ystart
          -- Make sure to use as few edge shapes as necessary
          local epp = element.physical_properties
          if epp and epp.tile then
            if row_length == 0 or row_length == 1 or element.allsides then
              epp.tile = {"u", "d", "l", "r"}
            elseif col_length == 0 then
              if i == 1 then
                epp.tile = {"u", "d", "l"}
              elseif i == row_length then
                epp.tile = {"u", "d", "r"}
              else
                epp.tile = {"u", "d"}
              end
            elseif j == 1 then
              if i == 1 then
                epp.tile = {"u", "l"} -- upper left
              elseif i == row_length then
                epp.tile = {"u", "r"} -- upper right and so forth
              else
                epp.tile = {"u"}
              end
            elseif j == col_length then
              if i == 1 then
                epp.tile = {"d", "l"}
              elseif i == row_length then
                epp.tile = {"d", "r"}
              else
                epp.tile = {"d"}
              end
            else
              if i == 1 then
                epp.tile = {"l"}
              elseif i == row_length then
                epp.tile = {"r"}
              else
                epp.tile = {"none"}
              end
            end
          end

          -- Determine sprite
          if tileset then
            element.sprite_info = {tileset}
            element.image_index = tileset_index_table[symbol_index]
          end

          o.addToWorld(element)
        end

        -- Progress iterators
        i = i + 1
        if row_length > 0 and row_length < i then
          i = 1
          j = j + 1
        end
      end

    -- If there are no symbols, require element from blueprint variable
    else
      local blueprint = require("GameObjects." .. room_part.blueprint)
      local element = blueprint:new(init)
      element.xstart = x_that_I_start
      element.ystart = y_that_I_start
      element.x = element.xstart
      element.y = element.ystart
      o.addToWorld(element)
    end

  end

end

return rm
