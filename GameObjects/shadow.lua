local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local o = require "GameObjects.objects"

local Shadow = {}

function Shadow.initialize(instance)
  instance.sprite_info = {
    {'Witch/shadow', 1, padding = 2, width = 16, height = 16}
  }
  instance.image_speed = 0
  instance.image_index = 0
  instance.transPersistent = true
  instance.x, instance.y = 0, 0
end

Shadow.functions = {
draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]
  local ca = self.caster
  if ca.exists then self.x, self.y = ca.x, ca.y else o.removeFromWorld(self) end
  love.graphics.draw(
  sprite.img, frame, ca.x, ca.y, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
end,

trans_draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]

  local x, y = self.x , self.y

  if self.playershadow then
    x = x + trans.xtransform - game.transitioning.progress * trans.xadjust
    y = y + trans.ytransform - game.transitioning.progress * trans.yadjust
  else
    x, y = trans.moving_objects_coords(self)
  end

  love.graphics.draw(
  sprite.img, frame,
  x, y, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
end,

load = function (self)
end,

delete = function (self)
end
}

function Shadow:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Shadow, instance, init) -- add own functions and fields
  return instance
end

function Shadow.handleShadow(object, plshadow)
  -- If above ground level
  if object.zo < 0 then
    -- Create shadow
    if not object.shadow then
      local shlayer = object.layer-1
      if shlayer < 1 then shlayer = 1 end
      object.shadow = Shadow:new{
        caster = object, layer = shlayer,
        xstart = x, ystart = y, playershadow = plshadow
      }
      if object.shadowsprite then
        object.shadow.sprite_info = object.shadowsprite
      end
      o.addToWorld(object.shadow)
    end
  else
    -- Destroy Shadow
    if object.shadow then
      o.removeFromWorld(object.shadow)
      object.shadow = nil
    end
  end
end

return Shadow
