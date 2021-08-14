local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local expl = require "GameObjects.explode"
local im = require "image"
local snd = require "sound"
local bspl = require "GameObjects.Items.bombsplosion"
local shdrs = require "Shaders.shaders"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local sh = require "GameObjects.shadow"

local Thrown = {}

local floor = math.floor
local pi = math.pi

local function destroyself(self)
  if not self.destroyedself then
    self.destroyedself = true
    if self.throw_collision then self:throw_collision() end
    o.removeFromWorld(self)
    if self.shadow then o.removeFromWorld(self.shadow) end
    self.shadow = nil
    if self.iAmBomb then
      local newBspl = bspl:new{
        x = self.x, y = self.y, layer = self.layer,
        dustAccident = self.dustBomb
      }
      o.addToWorld(newBspl)
    end
  end
end

local function touchGround(self)
  if self.iAmBomb then
    if not self.planted then snd.play(glsounds.bombDrop) end
    if self.bounces == 0 then
      self.cantGrab = false
      self.bounces = 1
      self.zvel = 55
      self.zo = -1
      local vx, vy = self.body:getLinearVelocity()
      self.body:setLinearVelocity(vx * 0.25, vy * 0.25)
      o.change_layer(self, self.layer - 2)
    elseif self.bounces == 1 then
      self.bounces = 2
      self.zvel = 22
      self.zo = -1
      local vx, vy = self.body:getLinearVelocity()
      self.body:setLinearVelocity(vx * 0.25, vy * 0.25)
    else
      self.gravity = 0
      self.zvel = 0
      self.zo = 0
      self.planted = true
      self.body:setLinearVelocity(0, 0)
      if self.shadow then o.removeFromWorld(self.shadow) end
      self.shadow = nil
    end
  else
    destroyself(self)
  end
end

local sink = expl.sink

local plummet = expl.plummet

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
    masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT},
    -- categories = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT}
    categories = {}
  }
  instance.seeThrough = true
  instance.immathrown = true
  instance.bounces = 0
  instance.thrownGoesThrough = true
  instance.zo = - 1.5 * ps.shapes.plshapeHeight

  instance.liftable = true
  instance.cantGrab = true
end

Thrown.functions = {

  load = function(self)
    self.body:setPosition(self.x, self.y - self.zo)
    self.body:setLinearVelocity(self.vx, self.vy)
    if self.iAmBomb then
      if session.save.dinsPower and not self.dustBomb then
        self.myShader = shdrs["bombRedShader"]
      end
      self.startingTimer = self.startingTimer or self.timer
      self.vibrPhase = self.vibrPhase or 0
      self.xvscale = self.xvscale or 0
      self.yvscale = self.yvscale or 0
    end
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
          -- Magic number to account for thrown height
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
          touchGround(self)
        end
      else
        touchGround(self)
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

    -- life timer (for bombs)
    if self.timer then
      if self.timer < 0 then
        destroyself(self)
      end
      local vibrSpeedMod = 15 / (2 * self.timer / self.startingTimer - 0.25)
      if vibrSpeedMod < 0 or vibrSpeedMod > 50 then vibrSpeedMod = 50 end
      self.vibrPhase = self.vibrPhase + dt * vibrSpeedMod
      self.xvscale = math.sin(self.vibrPhase) * 0.1
      self.yvscale = math.cos(self.vibrPhase) * 0.1
      self.timer = self.timer - dt
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
    local worldShader = love.graphics.getShader()

    love.graphics.setShader(self.inheritedShader or self.myShader)
    love.graphics.draw(
    sprite.img, frame, x, y + self.zo, self.angle,
    sprite.res_x_scale*(self.x_scale + (self.xvscale or 0)),
    sprite.res_y_scale*(self.y_scale + (self.yvscale or 0)),
    sprite.cx, sprite.cy)

    love.graphics.setShader(worldShader)

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
    u.rememberFloorTile(self, other)

    if other.floor then return end

    if other.grass then return end

    if other.attackDodger then return end

    -- destroy
    if not other.thrownGoesThrough then
      if self.iAmBomb then
        if not other.bombGoesThrough then self.body:setLinearVelocity(0, 0) end
      else
        destroyself(self)
      end
    end
  end,

  endContact = function(self, a, b, coll, aob, bob)

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Forget Floor tiles
    u.forgetFloorTile(self, other)
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
