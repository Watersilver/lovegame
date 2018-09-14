local inp = require "input"

local inv = {}

inv.sword = {
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgSwordL1.png"),
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "swing_sword"
    else
      return "hold_sword"
    end
  end,
  image_offset = function(object, dt, side)
    local offset = object.image_index * 3 * 0.5
    if side == "down" then
      object.ioy = (offset)
    elseif side == "right" then
      object.iox = (offset)
    elseif side == "left"  then
      object.iox = - (offset)
    elseif side == "up" then
      object.ioy = - (offset)
    end
  end
}

inv.jump = {
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgJumpL1.png"),
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "jump"
    else
      return "none"
    end
  end
}

inv.missile = {
  invImage = love.graphics.newImage("Sprites/Inventory/InvMissileL1.png"),
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "fire_missile"
    else
      return "fire_missile"
    end
  end
}

inv.grip = {
  invImage = love.graphics.newImage("Sprites/Inventory/InvMissileL1.png"),
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "gripping"
    else
      return "grip"
    end
  end
}

inv.mark = {
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgJumpL1.png"),
  time = 0.3,
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "mark"
    else
      return "none"
    end
  end
}

inv.recall = {
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgJumpL1.png"),
  time = 0.3,
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "recall"
    else
      return "none"
    end
  end
}

inv.slots = {}

inv.slots[6] = {key = "c", item = inv.sword}
inv.slots[5] = {key = "x", item = inv.jump}
inv.slots[4] = {key = "z", item = inv.missile}
inv.slots[3] = {key = "d", item = inv.mark}
inv.slots[2] = {key = "s", item = inv.recall}
inv.slots[1] = {key = "a", item = inv.grip}

for index, contents in ipairs(inv.slots) do
  inv.slots[inv.slots[index].key] = inv.slots[index]
end

-- Function that returns whether only one inv key is being held
-- If previnput is provided, it returns if only one is being pressed
local function single_inv_key_press(object, input, previnput)
  local keys = 0
  local key
  for _, content in ipairs(inv.slots) do
    if input[content.key] == 1 then
      if not previnput then
        keys = keys + 1
        key = content.key
      else
        if previnput[content.key] == 0 then
          keys = keys + 1
          key = content.key
        end
      end
    end
  end
  return key, keys
end


function inv.check_use(instance, trig, side)
  if trig.swing_sword then
    instance.animation_state:change_state(instance, dt, side .. "swing")
    return true
  elseif trig.jump then
    instance.animation_state:change_state(instance, dt, side .. "jump")
    return true
  elseif trig.fire_missile then
    instance.animation_state:change_state(instance, dt, side .. "missile")
    return true
  elseif trig.gripping and instance.sensors[side .. "Touch"] then
    instance.animation_state:change_state(instance, dt, side .. "gripping")
    return true
  elseif trig.mark then
    instance.animation_state:change_state(instance, dt, "downmark")
    return true
  elseif trig.recall then
    instance.animation_state:change_state(instance, dt, "downrecall")
    return true
  end
  return false
end


function inv.determine_equipment_triggers(object, dt)
  local myinput = object.input
  local previnput = object.previnput
  local trig = object.triggers

  local keypressing, keyspressing = single_inv_key_press(object, myinput)
  if keypressing and keyspressing == 1 then
    local item = inv.slots[keypressing].item
    if item then trig[item.check_trigger(object, previnput[keypressing])] = true end
  end
end


local cursor = {x=1, y=0}
function inv.manage(pauser)

  local myinput = inp.current[pauser.player]
  local previnput = inp.previous[pauser.player]

  -- Check if cursor is being moved
  local x, y = cursor.x, cursor.y
  if myinput.right == 1 and previnput.right == 0 then
    x = x + 1
    if x > 3 then x = 1 end
  end
  if myinput.left == 1 and previnput.left == 0 then
    x = x - 1
    if x < 1 then x = 3 end
  end
  if myinput.up == 1 and previnput.up == 0 then
    y = y + 1
    if y > 1 then y = 0 end
  end
  if myinput.down == 1 and previnput.down == 0 then
    y = y - 1
    if y < 0 then y = 1 end
  end
  cursor.x, cursor.y = x, y

  -- Check if position of item changes
  local keypressed, keyspressed = single_inv_key_press(object, myinput, previnput)
  if keypressed and keyspressed == 1 and inv.slots[cursor.x + 3*cursor.y].item then
    inv.slots[cursor.x + 3*cursor.y].item, inv.slots[keypressed].item =
      inv.slots[keypressed].item, inv.slots[cursor.x + 3*cursor.y].item
  end
end


function inv.draw()
  local x, y = 31, 132
  for index, contents in ipairs(inv.slots) do

    if cursor.x + 3*cursor.y == index then
      local pr, pg, pb, pa = love.graphics.getColor()
      love.graphics.setColor(COLORCONST*0.5, COLORCONST, COLORCONST, COLORCONST)
      love.graphics.rectangle("line", x, y, 18, 18)
      love.graphics.setColor(pr, pg, pb, pa)
    else
      love.graphics.rectangle("line", x, y, 18, 18)
    end
    if contents.item then love.graphics.draw(contents.item.invImage, x+1, y+1) end
    love.graphics.print(contents.key, x+1, y)
    x = x + 19
    if index % 3 == 0 then
      y = y + 19
      x = 31
    end
  end
end

return inv
