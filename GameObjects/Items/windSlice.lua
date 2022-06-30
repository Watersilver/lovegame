local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local expl = require "GameObjects.explode"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local WindSlice = {}

local floor = math.floor
local clamp = u.clamp
local pi = math.pi

local function hitEffect(self, other)
  local x, y
  if other.body then
    x, y = other.body:getPosition()
  else
    x, y = other.x or other.xstart, (other.x or other.xstart) + (other.zo or 0)
  end
  local explOb = expl:new{
    x = x, y = y,
    layer = other.layer + 1,
    explosionNumber = self.explosionNumber or 1,
    explosion_sprite = self.hitWallSprite or im.spriteSettings.swordHitWall,
    image_speed = self.hitWallImageSpeed or 0.5,
    nosound = true
  }
  o.addToWorld(explOb)
end

function WindSlice.initialize(instance)
  instance.sword = true
  instance.immasword = true
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    categories = {PLAYERATTACKCAT},
    masks = {SPRITECAT},
    shape = love.physics.newEdgeShape(
      instance.x0,
      instance.y0,
      instance.x1,
      instance.y1
    )
  }
  instance.seeThrough = true
  instance.layer = 30
end

WindSlice.functions = {
  load = function (self)
    local dist = u.distance2d(self.x0, self.y0, self.x1, self.y1)
    for i = 0,1,1 / dist do
      local x = u.lerp(self.x0, self.x1 - self.x0, i)
      local y = u.lerp(self.y0, self.y1 - self.y0, i)
      local dx, dy = u.randomPointFromEllipse(5)
      session.particles:addSpark{
        x = x + dx, y = y + dy,
        lifespan = love.math.random(),
        vy = -1 - 2 * love.math.random(),
        vx = -1 + 2 * love.math.random()
      }
    end
  end,

  update = function (self)
    o.removeFromWorld(self)
  end,

  -- draw = function (self, td)
  --   -- Debug
  --   love.graphics.line(self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end,
  --
  -- trans_draw = function(self)
  --   self:draw(true)
  -- end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is grass, at most play a sound (implemented via grass explosion)
    if other.grass then return end

    if other.pushback then
      if (other.static and not (other.breakableByUpgradedSword and session.save.dinsPower)) or other.forceSwordSound then
        hitEffect(self, other)
        snd.play(self.cr.sounds.swordTap1)
      elseif other.shieldWall and other.shielded and not ((other.weakShield or other.mediumShield) and session.save.dinsPower) then
        hitEffect(self, other)
        snd.play(self.cr.sounds.swordTap2)
      end
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    coll:setEnabled(false)
  end
}

function WindSlice:new(init)
  local instance = p:new({}, init) -- add parent functions and fields
  p.new(WindSlice, instance, init) -- add own functions and fields
  return instance
end

return WindSlice
