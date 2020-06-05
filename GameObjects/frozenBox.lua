local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local im = require "image"
local shdrs = require "Shaders.shaders"
local trans = require "transitions"
local o = require "GameObjects.objects"
local u = require "utilities"
local dc = require "GameObjects.Helpers.determine_colliders"
local expl = require "GameObjects.explode"
local snd = require "sound"
local sh = require "GameObjects.shadow"
local ebh = require "enemy_behaviours"
local game = require "game"

local lp = love.physics

local bt = {}

function bt.initialize(instance)
  instance.sprite_info = {im.spriteSettings.liftableRock}
  instance.floorTiles = {role = "thrownFloorTilesIndex"}
  instance.physical_properties = {
    bodyType = "dynamic",
    density = 200,
    gravityScaleFactor = 0,
    shape = ps.shapes.circleAlmost1,
    restitution = 0,
    linearDamping = 1,
    fixedRotation = true,
    categories = {1, FLOORCOLLIDECAT}
  }
  instance.ballbreaker = true
  instance.pushback = true
  instance.image_index = 0
  instance.myShader = shdrs.frozenShader
  instance.gravity = 350
  instance.zvel = 35
  instance.zo = 0
  instance.forceSwordSound = true
  instance.swordForceMod = 0.1
  instance.missileForceMod = 0.1
  instance.thrownForceMod = 0.1
  instance.bombsplosionForceMod = 0.5
  instance.bullrushForceMod = 0.5
  -- instance.pushback = true
  -- instance.liftable = true
end

bt.functions = {
  update = function(self, dt)
    -- Remove if out of bounds
    if self.x + 8 < 0 or self.x - 8 > game.room.width then
      o.removeFromWorld(self)
    elseif self.y < -8 or self.y > game.room.height + 8 then
      o.removeFromWorld(self)
    end

    self.x, self.y = self.body:getPosition()
    -- Handle zaxis
    self.zo = self.zo - self.zvel * dt
    if self.zo >= 0 then
      self.gravity = 0
      self.zvel = 0
      self.zo = 0
      if self.shadow then o.removeFromWorld(self.shadow) end
      self.shadow = nil
    else
      self.zvel = self.zvel - self.gravity * dt
      if not self.shadow then
        self.shadow = sh:new{
          caster = self, layer = self.layer-1,
          xstart = self.x, ystart = self.y
        }
        o.addToWorld(self.shadow)
      end
    end

    if self.floorTiles[1] then
      local x, y = self.body:getPosition()
      -- I could be stepping on up to four tiles. Find closest to determine mods
      local closestTile
      local closestDistance = math.huge
      local previousClosestDistance
      for _, floorTile in ipairs(self.floorTiles) do
        previousClosestDistance = closestDistance
        closestDistance = math.min(u.distanceSqared2d(x, y, floorTile.xstart, floorTile.ystart), closestDistance)
        if closestDistance < previousClosestDistance then
          closestTile = floorTile
        end
      end
      self.xClosestTile = closestTile.xstart
      self.yClosestTile = closestTile.ystart
      if closestTile.water then
        expl.sink(self)
      elseif closestTile.gap then
        expl.plummet(self)
      end
    end

  end,

  draw = function (self, td)
    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    local sprite = self.sprite
    local frame = sprite[math.floor(self.image_index)]
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, x, y + self.zo, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.immasword then
      self.lastHit = "sword"
      ebh.propelledByHit(self, other, myF, otherF)
    elseif other.immamissile then
      self.lastHit = "missile"
      ebh.propelledByHit(self, other, myF, otherF)
    elseif other.immathrown and not other.iAmBomb then
      self.lastHit = "thrown"
      ebh.propelledByHit(self, other, myF, otherF)
    elseif other.immabombsplosion then
      self.lastHit = "bombsplosion"
      ebh.propelledByHit(self, other, myF, otherF)
    elseif not otherF:isSensor() and other.immasprint then
      self.lastHit = "bullrush"
      ebh.propelledByHit(self, other, myF, otherF)
    end

    -- remember tiles
    u.rememberFloorTile(self, other)
  end,

  endContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Forget Floor tiles
    u.forgetFloorTile(self, other)
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.gap or other.water then
      coll:setEnabled(false)
    end
  end,
}

function bt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(bt, instance, init) -- add own functions and fields
  return instance
end

return bt
