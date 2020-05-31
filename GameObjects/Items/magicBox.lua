local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local im = require "image"
local trans = require "transitions"
local o = require "GameObjects.objects"
local u = require "utilities"
local dc = require "GameObjects.Helpers.determine_colliders"
local expl = require "GameObjects.explode"
local snd = require "sound"

local lp = love.physics

local bt = {}

function bt.initialize(instance)
  instance.sprite_info = {im.spriteSettings.playerMbox}
  instance.floorTiles = {role = "thrownFloorTilesIndex"}
  instance.physical_properties = {
    bodyType = "dynamic",
    density = 40,
    gravityScaleFactor = 0,
    shape = ps.shapes.circleAlmost1,
    restitution = 0,
    linearDamping = 40,
    fixedRotation = true,
    categories = {1, FLOORCOLLIDECAT}
  }
  instance.ballbreaker = true
  instance.image_index = 0
  instance.image_speed = 0.25
  -- instance.pushback = true
  -- instance.liftable = true
end

bt.functions = {
  update = function(self, dt)
    self.x, self.y = self.body:getPosition()
    self.image_index = (self.image_index + dt*60*self.image_speed)
    local frames = self.sprite.frames
    if self.image_index >= frames then
      self.image_index = frames - 0.1
    end
    if not self.creator then
      o.removeFromWorld(self)
      local disappearEffect = expl:new{
        x = self.x, y = self.y,
        layer = self.layer,
        image_speed = 0.2,
        explosion_sprite = im.spriteSettings.playerDissapearMbox,
        glsounds.appearVanish,
        sound = glsounds.appearVanish
      }
      o.addToWorld(disappearEffect)
    end

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
        self.creator = nil
      elseif closestTile.gap then
        self.creator = nil
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
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  load = function(self)
    snd.play(glsounds.appearVanish)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.immasword then
      self.creator = nil
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
    elseif other.immasprint then
      self.creator = nil
    end
  end,
}

function bt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(bt, instance, init) -- add own functions and fields
  return instance
end

return bt
