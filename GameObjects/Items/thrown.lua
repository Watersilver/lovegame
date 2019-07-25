local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local sh = require "GameObjects.shadow"

local Thrown = {}

local floor = math.floor
local pi = math.pi

local function destroyself(self)
  self:throw_collision()
  o.removeFromWorld(self)
end

function Thrown.initialize(instance)

  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.gravity = 350
  instance.zvel = 0
  -- instance.sprite_info will be handled by creator
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    shape = instance.shape or ps.shapes.thrown,
    sensor = true,
    gravityScaleFactor = 0,
    categories = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT}
  }
  instance.seeThrough = true
  instance.immathrown = true
end

Thrown.functions = {

  load = function(self)
    self.zo = - 1.5 * ps.shapes.plshapeHeight
    self.body:setPosition(self.x, self.y - self.zo)
    self.body:setLinearVelocity(self.vx, self.vy)
  end,

  update = function(self, dt)

    -- Handle zaxis
    self.zo = self.zo - self.zvel * dt
    if self.zo >= 0 then
      -- self.zo = 0
      -- self.zvel = 0
      if self.shadow then o.removeFromWorld(self.shadow) end
      self.shadow = nil
      destroyself(self)
    else
      self.zvel = self.zvel - self.gravity * dt
      if not self.shadow then
        self.shadow = sh:new{
          caster = self, layer = self.layer-2,
          xstart = x, ystart = y
        }
        o.addToWorld(self.shadow)
      end
    end

    -- throw_update is a function fed by what I was before I was thrown
    if self.throw_update then throw_update(self, dt) end
  end,

  draw = function(self, td)
    local x, y = self.body:getPosition()

    if td then
      x = x + trans.xtransform
      y = y + trans.ytransform
    end

    self.x, self.y = x, y
    local sprite = self.sprite
    -- Check in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, x, y + self.zo, self.angle,
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

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.grass then return end

    if other.attackDodger then return end

    if self.shadow then o.removeFromWorld(self.shadow) end
    self.shadow = nil
    destroyself(self)


  end,

  preSolve = function(self, a, b, coll, aob, bob)
  end
}

function Thrown:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Thrown, instance, init) -- add own functions and fields
  return instance
end

return Thrown
