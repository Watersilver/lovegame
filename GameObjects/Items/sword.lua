local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local Sword = {}

local floor = math.floor
local clamp = u.clamp
local pi = math.pi

--  Calculate sword position and angle offset due to creator's side
local function calculate_offset(side, phase)
  local xoff, yoff, aoff = 0, 0, 0
  if side == "down" then
    if phase == 0 then
      xoff = - 12
      yoff = 4
      aoff = pi * 1.5
    elseif phase == 1 then
      xoff = - 9
      yoff = 14
      aoff = pi
    elseif phase == 2 then
      xoff = 3
      yoff = 15
      aoff = pi
    end
  elseif side == "right" then
    if phase == 0 then
      xoff = 0
      yoff = - 12
      aoff = 0
    elseif phase == 1 then
      xoff = 11
      yoff = - 10
      aoff = 0
    elseif phase == 2 then
      xoff = 14
      yoff = 4
      aoff = pi * 0.5
    end
  elseif side == "left" then
    if phase == 0 then
      xoff = 0
      yoff = - 12
      aoff = 0
    elseif phase == 1 then
      xoff = - 10
      yoff = - 11
      aoff = pi * 1.5
    elseif phase == 2 then
      xoff = - 14
      yoff = 4
      aoff = - pi * 0.5
    end
  elseif side == "up" then
    if phase == 0 then
      xoff = 14
      yoff = - 1
      aoff = pi * 0.5
    elseif phase == 1 then
      xoff = 11
      yoff = - 12
      aoff = 0
    elseif phase == 2 then
      xoff = - 4
      yoff = - 15
      aoff = 0
    end
  end
  return xoff, yoff, aoff
end

function Sword.initialize(instance)

  instance.transPersistent = true
  instance.sword = true
  instance.immasword = true
  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.triggers = {}
  instance.sprite_info = {im.spriteSettings.playerSword}
  instance.spritefixture_properties = {shape = ps.shapes.swordSprite}
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    -- masks = {FLOORCAT}
  }
  instance.creator = nil -- Object that swings me
  instance.side = nil -- down, right, left, up
end

Sword.functions = {

  -- This could also be a func called swing to be used in *swing animstate like so:
  -- -- Swing sword
  -- if instance.sword.exists then instance.sword:swing(dt) end
  -- Pros: no lag (player image_index can be fixed in early update. Position can't)
  -- Cons: One frame that the spritefixture hasen't determined yet who's front
  --       and who's back.
  early_update = function(self, dt)
    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      o.removeFromWorld(self)
    end

    -- Check if I'm on the air
    if cr.zo ~= 0 then
      self.onAir = true
    else
      self.onAir = false
    end

    if self.weld then self.weld:destroy() end

    -- Calculate sprite_index
    local phase
    if not self.stab then
      phase = floor(cr.image_index * self.sprite.frames / cr.sprite.frames)
      self.image_index = phase
    else
      self.image_index = 2
      phase = self.image_index
    end
    local prevphase = self.previous_image_index

    -- -- Calculate offset due to sword swinging
    -- local sox, soy, angle = calculate_offset(self.side, phase)
    -- local creatorx, creatory = cr.body:getPosition()

    if phase ~= prevphase then

      if self.fixture then
        self.fixture:destroy()
      end
      if phase == 0 then
        self.fixture = love.physics.newFixture(self.body, ps.shapes.swordIgniting, 0)
      elseif phase == 1 then
        self.fixture = love.physics.newFixture(self.body, ps.shapes.swordSwingWide, 0)
      elseif phase == 2 then
        self.fixture = love.physics.newFixture(self.body, ps.shapes.swordStill, 0)
      end
      self.fixture:setSensor(true)

    end

    if self.onAir then
      self.fixture:setCategory(PLAYERJUMPATTACKCAT)
    else
      self.fixture:setCategory(PLAYERATTACKCAT)
    end

    -- Calculate offset due to sword swinging
    local sox, soy, angle = calculate_offset(self.side, phase)
    local creatorx, creatory = cr.body:getPosition()

    -- Determine offset due to wielder's offset
    local wox, woy = cr.iox, cr.ioy

    -- Determine offset due to falling
    local fy = 0
    if cr.edgeFall and cr.edgeFall.step2 then
      fy = - cr.edgeFall.height
    end

    -- Set position and angle
    local x, y = creatorx + sox + wox, creatory + soy + woy + cr.zo + fy
    self.body:setPosition(x, y)
    self.body:setAngle(angle)

    if self.spritejoint then self.spritejoint:destroy() end
    self.spritebody:setPosition(x, y)
    self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)


    -- Drawing angle
    self.angle = angle

    -- Weld
    self.weld = love.physics.newWeldJoint(cr.body, self.body, x, y, true)

    o.change_layer(self, cr.layer)
    self.previous_image_index = phase
  end,

  draw = function(self, td)
    local x, y = self.body:getPosition()

    if td then
      x = x + trans.xtransform - game.transitioning.progress * trans.xadjust
      y = y + trans.ytransform - game.transitioning.progress * trans.yadjust
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

    -- If other is grass, at most play a sound (not yet implemented)
    if other.grass then return end

    local pushback = other.pushback

    -- If below edge, treat as wall
    if other.edge then
      if ec.swordBelowEdge(other, cr) then pushback = true else return end
    end

    if pushback and not self.hitWall then
      local lvx, lvy = cr.body:getLinearVelocity()
      local crmass = cr.body:getMass()
      local crbrakes = clamp(0, cr.brakes, cr.brakesLim)
      cr.body:applyLinearImpulse(-lvx * crmass, -lvy * crmass)
      if self.side == "down" then
        px, py = 0, -10 * crmass * crbrakes
      elseif self.side == "right" then
        px, py = -10 * crmass * crbrakes, 0
      elseif self.side == "left" then
        px, py = 10 * crmass * crbrakes, 0
      elseif self.side == "up" then
        px, py = 0, 10 * crmass * crbrakes
      end
      cr.body:applyLinearImpulse(px, py)
      self.hitWall = true

    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
  end
}

function Sword:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Sword, instance, init) -- add own functions and fields
  return instance
end

return Sword
