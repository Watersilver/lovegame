local inp = require "input"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local o = require "GameObjects.objects"

local powToShad = {
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
  invImageL2 = love.graphics.newImage("Sprites/Inventory/InvImgJumpL2.png"),
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "jump"
    else
      return "hold_jump"
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

inv.bomb = {
  name = "bomb",
  powerUp = "dinsPower",
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgBomb.png"),
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "bomb"
    else
      return "none"
    end
  end,
  l1 = {
    lvl = 1,
    sprite_info = {im.spriteSettings.playerBomb},
    image_index = 0,
  }
}

inv.speed = {
  name = "speed",
  powerUp = "faroresCourage",
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgSpeed.png"),
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "speed_start"
    else
      return "speed"
    end
  end,
}

inv.mystery = {
  name = "mystery",
  powerUp = "nayrusWisdom",
  invImage = love.graphics.newImage("Sprites/Inventory/InvImgMystery.png"),
  time = 0.3,
  check_trigger = function(object, keyheld)
    if keyheld == 0 then
      return "mystery"
    else
      return "none"
    end
  end,
}

inv.slots = {}

-- inv.slots[6] = {key = "c", item = inv.sword}
-- inv.slots[5] = {key = "x", item = inv.jump}
-- inv.slots[4] = {key = "z", item = inv.missile}
-- inv.slots[3] = {key = "d", item = inv.mark}
-- inv.slots[2] = {key = "s", item = inv.recall}
-- inv.slots[1] = {key = "a", item = inv.grip}

inv.slots[9] = {key = "c", index=9}
inv.slots[8] = {key = "x", index=8}
inv.slots[7] = {key = "z", index=7}
inv.slots[6] = {key = "d", index=6}
inv.slots[5] = {key = "s", index=5}
inv.slots[4] = {key = "a", index=4}
inv.slots[3] = {key = "e", index=3}
inv.slots[2] = {key = "w", index=2}
inv.slots[1] = {key = "q", index=1}

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

local function checkJumpingSword(input)
  local jumpkey = false
  local swordkey = false
  local otherkey = false
  for _, slot in ipairs(inv.slots) do
    if input[slot.key] == 1 then
      if slot.item and slot.item.name == "sword" then
        swordkey = slot.key
      elseif slot.item and slot.item.name == "jump" then
        jumpkey = slot.key
      else
        otherkey = true
      end
    end
    if swordkey and jumpkey then break end
  end
  if otherkey then
    return false
  elseif swordkey and jumpkey then
    return swordkey, jumpkey
  end
  return false
end


function inv.closeInv()
  inv.spellSelection = nil
end
inv.closeInv()


function inv.check_use(instance, trig, side, dt)
  local returnValue = false
  if trig.swing_sword then
    instance.animation_state:change_state(instance, dt, side .. "swing")
    returnValue = true
  elseif trig.jump then
    instance.animation_state:change_state(instance, dt, side .. "jump")
    returnValue = true
  elseif trig.fire_missile then
    instance.animation_state:change_state(instance, dt, side .. "missile")
    returnValue = true
  elseif trig.speed_start then
    instance.animation_state:change_state(instance, dt, side .. "sprintcharge")
    returnValue = true
  elseif trig.bomb then
    local removeResult = session.removeItem("somaBlastSeed")
    if removeResult == "don't have any" then return end
    local blvl = inv.bomb.l1
    instance.liftedOb = (require "GameObjects.Items.lifted"):new{
      creator = instance,
      side = side,
      layer = side == "up" and instance.layer - 1 or instance.layer + 1,
      iAmBomb = true,
      timer = 2,
      blevel = blvl.lvl,
      sprite_info = blvl.sprite_info,
      image_index = math.floor(blvl.image_index),
      lifterSpeedMod = 0.9
    }
    o.addToWorld(instance.liftedOb)
    instance.animation_state:change_state(instance, dt, side .. "lifting")
    returnValue = true
  elseif trig.gripping and instance.sensors[side .. "Touch"] then
    instance.animation_state:change_state(instance, dt, side .. "gripping")
    returnValue = true
  elseif trig.mystery then
    instance.animation_state:change_state(instance, dt, side .. "mdust")
    returnValue = true
  elseif trig.mark then
    instance.animation_state:change_state(instance, dt, "downmark")
    returnValue = true
  elseif trig.recall then
    instance.animation_state:change_state(instance, dt, "downrecall")
    returnValue = true
  end
  -- Destroy decoy if using items
  if returnValue then session.decoy = nil end
  return returnValue
end


function inv.determine_equipment_triggers(object, dt)
  local myinput = object.input
  local previnput = object.previnput
  local trig = object.triggers

  local keypressing, keyspressing = single_inv_key_press(object, myinput)
  if keypressing then
    if keyspressing == 1 then
      local item = inv.slots[keypressing].item
      if item then trig[item.check_trigger(object, previnput[keypressing])] = true end
    elseif keyspressing == 2 then
      local swordkey, jumpkey = checkJumpingSword(myinput)
      if swordkey then
        trig[inv.sword.check_trigger(object, previnput[swordkey])] = true
        trig[inv.jump.check_trigger(object, previnput[jumpkey])] = true
      end
    end
  end
end


function inv.manage(pauser)

  local myinput = inp.current[pauser.player]
  local previnput = inp.previous[pauser.player]

  -- if myinput.right == 1 and previnput.right == 0 then
  --   x = x + 1
  --   if x > 3 then x = 1 end
  -- end

  -- figure out which key was pressed (not held), and if only one
  local keypressed, keyspressed = single_inv_key_press(object, myinput, previnput)
  -- if one key was pressed proceed
  if keypressed and keyspressed == 1 then
    if inv.spellSelection then
      -- if a spell was already selected, swap it with the one on the pressed key
      -- only swap if necessary
      if inv.spellSelection ~= inv.slots[keypressed].index then
        inv.slots[inv.spellSelection].item, inv.slots[keypressed].item =
          inv.slots[keypressed].item, inv.slots[inv.spellSelection].item
          snd.play(glsounds.select)
      else
        snd.play(glsounds.deselect)
      end
      -- Operation complete. Disable selection.
      inv.spellSelection = nil
    else
      -- if a spell isn't already selected, select the spell that corresponds to the pressed key
      inv.spellSelection = inv.slots[keypressed].index
      snd.play(glsounds.cursor)
    end
  end
end


function inv.draw(l,t,w,h)
  local cc = COLORCONST

  -- pieces of heart
  local pocx, pocy = w - invPieceOfHeart.width * 2, h * 0.5
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
    w - invPieceOfHeart.width * 2.6,
    h * 0.5 + invPieceOfHeart.height + 3
  )
  local pr, pg, pb, pa = love.graphics.getColor()
  love.graphics.setColor(cc, cc, cc*pohColourMod, cc)
  love.graphics.print(
    "x" .. pohCounter,
    w - invPieceOfHeart.width * 2.6 + 16,
    h * 0.5 + invPieceOfHeart.height + 8,
    0,
    0.3
  )
  love.graphics.setColor(pr, pg, pb, pa)

  -- spells
  -- local x, y = 31, 132
  local itemBoxSide = 18
  local itemBoxOffset = itemBoxSide + 1
  local xInit = w * 0.5 - itemBoxOffset * 1.5
  local yInit = h - itemBoxOffset * 3
  local x, y = xInit, yInit

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
      if session[contents.item.name .. "L2"] then
        love.graphics.draw(contents.item.invImageL2, x+1, y+1)
      else
        love.graphics.draw(contents.item.invImage, x+1, y+1)
      end
      love.graphics.setShader(worldShader)
    end
    local pr, pg, pb, pa = love.graphics.getColor()
    local prevBm = love.graphics.getBlendMode()
    if inv.spellSelection == index then
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

  -- water walking
  local wwx = xInit + itemBoxSide * 3.3
  local wwy = yInit + itemBoxSide * 0.5
  local wwImg = love.graphics.newImage("Sprites/Inventory/Jesus.png")
  local pr, pg, pb, pa = love.graphics.getColor()
  if session.save.walkOnWater then
    love.graphics.setColor(0, 0, 0, cc * 0.5)
    love.graphics.rectangle("line", wwx, wwy, itemBoxSide, itemBoxSide)
    love.graphics.setColor(cc * 0.2, cc * 0.2, cc * 0.2, cc * 0.1)
    love.graphics.rectangle("fill", wwx, wwy, itemBoxSide, itemBoxSide)
    love.graphics.setColor(cc, cc, cc, cc)
    love.graphics.draw(wwImg, wwx+1, wwy+1)
  else
    love.graphics.setColor(0, 0, 0, cc * 0.5)
    love.graphics.rectangle("line", wwx, wwy, itemBoxSide, itemBoxSide)
    love.graphics.setColor(0, 0, 0, cc * 0.3)
    love.graphics.rectangle("fill", wwx, wwy, itemBoxSide, itemBoxSide)
  end
  love.graphics.setColor(pr, pg, pb, pa)

  -- light
  local lx = xInit - itemBoxSide * 1.3 + 2
  local ly = yInit + itemBoxSide * 0.5
  local lImg = love.graphics.newImage("Sprites/Inventory/Devil2.png")
  local pr, pg, pb, pa = love.graphics.getColor()
  if session.save.playerGlowAvailable then
    love.graphics.setColor(0, 0, 0, cc * 0.5)
    love.graphics.rectangle("line", lx, ly, itemBoxSide, itemBoxSide)
    love.graphics.setColor(cc * 0.2, cc * 0.2, cc * 0.2, cc * 0.1)
    love.graphics.rectangle("fill", lx, ly, itemBoxSide, itemBoxSide)
    love.graphics.setColor(cc, cc, cc, cc)
    love.graphics.draw(lImg, lx+1, ly+1)
  else
    love.graphics.setColor(0, 0, 0, cc * 0.5)
    love.graphics.rectangle("line", lx, ly, itemBoxSide, itemBoxSide)
    love.graphics.setColor(0, 0, 0, cc * 0.3)
    love.graphics.rectangle("fill", lx, ly, itemBoxSide, itemBoxSide)
  end
  love.graphics.setColor(pr, pg, pb, pa)

end

return inv
