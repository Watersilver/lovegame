local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"

local HeldSword = {}

local floor = math.floor
local pi = math.pi

--  Calculate HeldSword position and angle offset due to creator's side
local function calculate_offset(side, phase)
  local xoff, yoff, aoff = 0, 0, 0
  if side == "down" then
    xoff = 3
    yoff = 12
    aoff = pi
  elseif side == "right" then
    xoff = 11
    yoff = 4
    aoff = pi * 0.5
  elseif side == "left" then
    xoff = - 11
    yoff = 4
    aoff = - pi * 0.5
  elseif side == "up" then
    xoff = - 4
    yoff = - 11
    aoff = 0
  end
  return xoff, yoff, aoff
end

function HeldSword.initialize(instance)
  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.image_index = 2
  instance.triggers = {}
  instance.sprite_info = {
    {'Inventory/UseSwordL1', 3, padding = 2, width = 16, height = 15},
    spritefixture_properties = {
      shape = ps.shapes.swordSprite
    }
  }
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    sensor = true,
    density = 0,
    shape = ps.shapes.swordStill,
    categories = {PLAYERATTACKCAT}
  }
  instance.creator = nil -- Object that swings me
  instance.side = nil -- down, right, left, up
end

HeldSword.functions = {

  -- This could also be a func called swing to be used in *swing animstate like so:
  -- -- Swing HeldSword
  -- if instance.HeldSword.exists then instance.HeldSword:swing(dt) end
  -- Pros: no lag (player image_index can be fixed in early update. Position can't)
  -- Cons: One frame that the spritefixture hasen't determined yet who's front
  --       and who's back.
  early_update = function(self, dt)
    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      o.removeFromWorld(self)
    end

    if not self.welded then
      -- Calculate offset due to HeldSword swinging
      local sox, soy, angle = calculate_offset(self.side, phase)
      local creatorx, creatory = cr.body:getPosition()

      -- Set position and physical angle
      self.body:setPosition(creatorx + sox, creatory + soy)
      self.body:setAngle(angle)

      -- Drawing angle
      self.angle = angle

      -- Weld
      love.physics.newWeldJoint(cr.body, self.body, creatorx + sox, creatory + soy, true)
      self.welded = true
    end

    o.change_layer(self, cr.layer)
  end,

  draw = function(self)
    local x, y = self.body:getPosition()
    self.x, self.y = x, y
    local sprite = self.sprite
    -- Check in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, x, y, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)

    -- Debug
    -- love.graphics.polygon("line",
    -- self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      return
    end

    -- Find which fixture belongs to whom
    local myF
    local otherF
    if self == aob then
      myF = a
      otherF = b
      other = bob
    else
      myF = b
      otherF = a
      other = aob
    end

    cr.triggers.stab = true

  end
}

function HeldSword:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(HeldSword, instance, init) -- add own functions and fields
  return instance
end

return HeldSword