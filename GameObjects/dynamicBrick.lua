local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local u = require "utilities"
local dc = require "GameObjects.Helpers.determine_colliders"
local expl = require "GameObjects.explode"
local game = require "game"

local bt = {}

function bt.initialize(instance)
  instance.sprite_info = {{'Brick', 2, 2}}
  instance.floorTiles = {role = "thrownFloorTilesIndex"}
  instance.physical_properties = {
    bodyType = "dynamic",
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1,
    mass = 40,
    linearDamping = 40,
    restitution = 0,
    downSensor = ps.shapes.edgeRect1x1.dc
  }
  instance.ballbreaker = true
  instance.image_index = 0
  instance.image_speed = 0
  instance.pushback = true
  instance.layer = 13
  instance.forceSwordSound = true

  instance.bottomObs = {}
end

bt.functions = {
  isBottomFixture = function(self, fixture)
    return fixture:getUserData() == "downTouch"
  end,

  update = function(self, dt)
    self.x, self.y = self.body:getPosition()

    if (game.room.sideScrolling) then
      self.body:applyForce(0, 350 * self.body:getMass())

      if #self.bottomObs > 0 then
        self.body:setLinearDamping(self.physical_properties.linearDamping)
      else
        self.body:setLinearDamping(0)
      end
    end

    self.image_index = (self.image_index + dt*60*self.image_speed)
    local frames = self.sprite.frames
    if self.image_index >= frames then
      self.image_index = frames - 0.1
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
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if (self:isBottomFixture(myF)) then
      table.insert(self.bottomObs, other)
    end

    if myF:isSensor() then return end

    -- remember tiles
    u.rememberFloorTile(self, other)
  end,

  endContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if self:isBottomFixture(myF) then
      for i, obj in ipairs(self.bottomObs) do
        if obj == other then
          table.remove(self.bottomObs, i)
          break
        end
      end
    end

    if myF:isSensor() then return end

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
