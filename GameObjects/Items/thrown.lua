local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local expl = require "GameObjects.explode"
local im = require "image"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local sh = require "GameObjects.shadow"

local Thrown = {}

local floor = math.floor
local pi = math.pi

local function destroyself(self)
  if not self.destroyedself then
    self.destroyedself = true
    self:throw_collision()
    o.removeFromWorld(self)
    if self.shadow then o.removeFromWorld(self.shadow) end
    self.shadow = nil
  end
end

local sink_sprite = im.spriteSettings.rockSink
local sink_sound = {"Effects/Oracle_Link_Wade"}
local function sink(self)
  self.explosionSpeed = 0.4
  expl.commonExplosion(self, sink_sprite, sink_sound)
  o.removeFromWorld(self)
end

local plummet_sprite = im.spriteSettings.rockPlummet
local plummet_sound = {"Effects/Oracle_Block_Fall"}
local function plummet(self)
  self.explosionSpeed = 0.2
  expl.commonExplosion(self, plummet_sprite, plummet_sound, self.xClosestTile, self.yClosestTile)
  o.removeFromWorld(self)
end

function Thrown.initialize(instance)

  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.gravity = 350
  instance.zvel = 0
  instance.floorTiles = {role = "thrownFloorTilesIndex"} -- Tracks what kind of floortiles I'm over
  -- instance.sprite_info will be handled by creator
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    shape = instance.shape or ps.shapes.thrown,
    sensor = true,
    gravityScaleFactor = 0,
    masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT},
    categories = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT}
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
      if self.floorTiles[1] then
        local x, y = self.body:getPosition()
        -- I could be stepping on up to four tiles. Find closest to determine mods
        local closestTile
        local closestDistance = math.huge
        local previousClosestDistance
        for _, floorTile in ipairs(self.floorTiles) do
          previousClosestDistance = closestDistance
          -- Magic number to account for player height
          closestDistance = math.min(u.distanceSqared2d(x, y+3, floorTile.xstart, floorTile.ystart), closestDistance)
          if closestDistance < previousClosestDistance then
            closestTile = floorTile
          end
        end
        self.xClosestTile = closestTile.xstart
        self.yClosestTile = closestTile.ystart
        if closestTile.water then
          sink(self)
        elseif closestTile.gap then
          plummet(self)
        else
          destroyself(self)
        end
      else
        destroyself(self)
      end
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
      x, y = trans.moving_objects_coords(self)
    else
      self.x, self.y = x, y
    end

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

    -- remember tiles
    if other.floor then
      other.thrownFloorTilesIndex = u.push(self.floorTiles, other)
      return
    end

    if other.grass then return end

    if other.attackDodger then return end

    -- destroy
    destroyself(self)
  end,

  endContact = function(self, a, b, coll, aob, bob)

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Forget Floor tiles
    if other.floor then
      u.free(self.floorTiles, other.thrownFloorTilesIndex)
      other.thrownFloorTilesIndex = nil
    end
  end

  -- preSolve = function(self, a, b, coll, aob, bob)
  -- end
}

function Thrown:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Thrown, instance, init) -- add own functions and fields
  return instance
end

return Thrown
