local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local im = require "image"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

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

  instance.transPersistent = true
  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.image_index = 2
  instance.triggers = {}
  instance.sprite_info = {im.spriteSettings.playerSword}
  instance.spritefixture_properties = {shape = ps.shapes.swordSprite}
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    sensor = true,
    density = 0,
    shape = ps.shapes.swordHeld,
    categories = {PLAYERATTACKCAT},
    -- masks = {FLOORCAT}
  }
  instance.creator = nil -- Object that swings me
  instance.side = nil -- down, right, left, up
  instance.seeThrough = true
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
    if self.weld and (not self.weld:isDestroyed()) then self.weld:destroy() end

    -- Calculate offset due to HeldSword swinging
    local sox, soy, angle = calculate_offset(self.side, phase)
    local creatorx, creatory = cr.body:getPosition()

    -- Determine offset due to falling
    local fy = 0
    if cr.edgeFall and cr.edgeFall.step2 then
      fy = - cr.edgeFall.height
    end

    -- Set position and physical angle
    self.body:setPosition(creatorx + sox, creatory + soy + cr.zo + fy)
    self.body:setAngle(angle)

    -- Drawing angle
    self.angle = angle

    -- Weld
    self.weld = love.physics.newWeldJoint(cr.body, self.body, creatorx + sox, creatory + soy + cr.zo, true)

    -- Check if I'm on the air
    if cr.zo ~= 0 then
      self.onAir = true
    else
      self.onAir = false
    end

    if self.onAir then
      self.fixture:setCategory(PLAYERJUMPATTACKCAT)
    else
      self.fixture:setCategory(PLAYERATTACKCAT)
    end

    o.change_layer(self, cr.layer)
  end,

  draw = function(self, td)
    local x, y = self.body:getPosition()

    if self.spritejoint then
      self.spritejoint:destroy()
      if not self.spritejoint:isDestroyed() then self.spritejoint:destroy() end
      self.spritejoint = nil
    end

    if td then
      x = x + trans.xtransform - game.transitioning.progress * trans.xadjust
      y = y + trans.ytransform - game.transitioning.progress * trans.yadjust
    else
      self.spritebody:setPosition(x, y)
      self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)
    end

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
    -- self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    -- love.graphics.polygon("line",
    -- self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end,

  trans_draw = function(self)
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      return
    end

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is grass, do nothing
    if other.grass then return end

    -- If other is attackDodger, do nothing
    if other.attackDodger then return end

    -- If below edge, treat as wall
    if other.edge then
      if not ec.swordBelowEdge(other, cr) then return end
    end

    -- This will destroy held sword and create a sword that is stabbing
    cr.triggers.stab = true

  end
}

function HeldSword:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(HeldSword, instance, init) -- add own functions and fields
  return instance
end

return HeldSword
