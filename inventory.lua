local inp = require "input"
local shdrs = require "Shaders.shaders"

powToShad = {
  dinsPower = "itemRedShader",
  nayrusWisdom = "itemBlueShader",
  faroresCourage = "itemGreenShader",
}

-- set up piece of heart image
local invPieceOfHeart = {
  img = love.graphics.newImage("Sprites/Inventory/InvPieceOfHeart.png"),
  smallImg = love.graphics.newImage("Sprites/pieceOfHeart.png"),
  quads = {}
}
invPieceOfHeart.width = (invPieceOfHeart.img:getWidth() / 5) - 2
invPieceOfHeart.height = invPieceOfHeart.img:getHeight() - 2
invPieceOfHeart.cx = invPieceOfHeart.width * 0.5
invPieceOfHeart.cy = invPieceOfHeart.height * 0.5
for i = 0, 4 do
  invPieceOfHeart.quads[i] = love.graphics.newQuad(
    1 + i * (invPieceOfHeart.width + 2), -- x
    1, -- y
    invPieceOfHeart.width, invPieceOfHeart.height,
    invPieceOfHeart.img:getDimensions()
  )
end

local inv = {}

inv.sword = {
  name = "sword",
  powerUp = "dinsPower",
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgSwordL1.png"),
  time = 0.5, -- normal zelda games 0.3 me 0.35
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "swing_sword"
    else
      return "hold_sword"
    end
  end,
  image_offset = function(object, dt, side)
    local offset
    -- if object.swingingSword and (object.swingTimer > object.swingDuration) then
    --   offset = 0
    -- else
    --   offset = object.image_index * 3 * 0.5
    -- end
    if object.swingingSword and (object.item_use_duration - object.item_use_counter < 0.07) then
      offset = 0
    else
      offset = object.image_index * 3 * 0.5
    end
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
  name = "jump",
  powerUp = "nayrusWisdom",
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
  name = "missile",
  powerUp = "nayrusWisdom",
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
  name = "grip",
  powerUp = "dinsPower",
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgGripL1.png"),
  time = 0.25,
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "gripping"
    else
      return "grip"
    end
  end
}

inv.mark = {
  name = "mark",
  powerUp = "faroresCourage",
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgMarkL1.png"),
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
  name = "recall",
  powerUp = "faroresCourage",
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgRecallL1.png"),
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

-- inv.slots[6] = {key = "c", item = inv.sword}
-- inv.slots[5] = {key = "x", item = inv.jump}
-- inv.slots[4] = {key = "z", item = inv.missile}
-- inv.slots[3] = {key = "d", item = inv.mark}
-- inv.slots[2] = {key = "s", item = inv.recall}
-- inv.slots[1] = {key = "a", item = inv.grip}

inv.slots[6] = {key = "c"}
inv.slots[5] = {key = "x"}
inv.slots[4] = {key = "z"}
inv.slots[3] = {key = "d"}
inv.slots[2] = {key = "s"}
inv.slots[1] = {key = "a"}

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
  local cc = COLORCONST

  -- pieces of heart
  local pocx, pocy = HudWidth - invPieceOfHeart.width * 2, HudHeight * 0.5
  love.graphics.print("PIECES",
  pocx - invPieceOfHeart.width * 0.9, pocy - invPieceOfHeart.height * 2,
  0, 0.4, 0.4)
  love.graphics.print("OF HEART",
  pocx - invPieceOfHeart.width * 1.2, pocy - invPieceOfHeart.height * 1.5,
  0, 0.4, 0.4)
  local pohs = (session.save.piecesOfHeart or 0)
  local ipocFrame = pohs % 4
  local pohCounter = pohs
  local pohColourMod = 1
  if pohs >= GCON.maxPOHs then ipocFrame = 4; pohCounter = "MAX"; pohColourMod = 0.2 end
  love.graphics.draw(
    invPieceOfHeart.img,
    invPieceOfHeart.quads[ipocFrame],
    pocx,
    pocy,
    0, -- angle
    2, -- scale
    2,
    invPieceOfHeart.cx,
    invPieceOfHeart.cy
  )
  love.graphics.draw(
    invPieceOfHeart.smallImg,
    HudWidth - invPieceOfHeart.width * 2.6,
    HudHeight * 0.5 + invPieceOfHeart.height + 3
  )
  local pr, pg, pb, pa = love.graphics.getColor()
  love.graphics.setColor(cc, cc, cc*pohColourMod, cc)
  love.graphics.print(
    "x" .. pohCounter,
    HudWidth - invPieceOfHeart.width * 2.6 + 16,
    HudHeight * 0.5 + invPieceOfHeart.height + 8,
    0,
    0.3
  )
  love.graphics.setColor(pr, pg, pb, pa)

  -- spells
  -- local x, y = 31, 132
  local itemBoxSide = 18
  local itemBoxOffset = itemBoxSide + 1
  local xInit = HudWidth * 0.5 - itemBoxOffset * 1.5
  local x, y = xInit, HudHeight - itemBoxOffset * 3

  love.graphics.print("SPELLS", x, y - itemBoxOffset * 0.6, 0, 0.4, 0.4)
  for index, contents in ipairs(inv.slots) do

    if contents.item then
      local worldShader = love.graphics.getShader()
      local itemShader
      local powUp = contents.item.powerUp
      if session.save[powUp] then
        itemShader = shdrs[powToShad[powUp]]
      end
      love.graphics.setShader(itemShader)
      love.graphics.draw(contents.item.invImage, x+1, y+1)
      love.graphics.setShader(worldShader)
    end
    local pr, pg, pb, pa = love.graphics.getColor()
    local prevBm = love.graphics.getBlendMode()
    if cursor.x + 3*cursor.y == index then
      -- love.graphics.setColor(cc*0.5, cc, cc, cc)
      love.graphics.setColor(cc * 0.1, cc * 0.1, cc * 0.1, cc * 0.5)
      love.graphics.rectangle("line", x, y, itemBoxSide, itemBoxSide)
      love.graphics.setColor(cc * 0.2, cc * 0.2, cc * 0.2, cc * 0.1)
      love.graphics.rectangle("fill", x, y, itemBoxSide, itemBoxSide)
    else
      love.graphics.setColor(0, 0, 0, cc * 0.5)
      love.graphics.rectangle("line", x, y, itemBoxSide, itemBoxSide)
      love.graphics.setColor(0, 0, 0, cc * 0.3)
      love.graphics.rectangle("fill", x, y, itemBoxSide, itemBoxSide)
    end
    love.graphics.setBlendMode(prevBm)
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.print(contents.key, x+1, y, 0, 0.2, 0.2)
    x = x + itemBoxOffset
    if index % 3 == 0 then
      y = y + itemBoxOffset
      x = xInit
    end
  end
end

return inv
