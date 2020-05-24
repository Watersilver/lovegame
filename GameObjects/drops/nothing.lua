local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local im = require "image"
local dc = require "GameObjects.Helpers.determine_colliders"
local sh = require "GameObjects.shadow"
local zAxis = (require "movement").top_down.zAxis

local o = require "GameObjects.objects"

local Drop = {}

local spriteInfo = {
  {'Drops/nothing', padding = 0, width = 7, height = 7},
}

local pp = {
  bodyType = "static",
  fixedRotation = true,
  shape = ps.shapes.circleHalf,
  masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT}
}

local function onPlayerTouch()
end

function Drop.initialize(instance)
  instance.physical_properties = pp
  instance.sprite_info = spriteInfo
  instance.onPlayerTouch = onPlayerTouch
  instance.image_speed = 0
  instance.seeThrough = true
  instance.layer = 21
  instance.unpushable = true
  instance.zo = 0
  instance.zvel = 0
  instance.gravity = 400
  instance.shadowHeightMod = -3
  instance.notSolidStatic = true
  instance.notSolid = true
  instance.bounceOnce = true
end

Drop.functions = {
load = function (self)
  self.x = self.xstart
  self.y = self.ystart
end,

update = function (self, dt)
  zAxis(self, dt)
  if self.bounceOnce and self.zo == 0 then
    self.zvel = 50
    self.zo = -0.0001
    self.bounceOnce = nil
  end
  if self.zo == 0 then o.change_layer(self, 19) end

  sh.handleShadow(self)
end,

preSolve = function(self, a, b, coll, aob, bob)
  local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
  coll:setEnabled(false)
  if not otherF:isSensor() then
    if other.player and not other.triggers.posingForItem and (self.zo ~= 0 or other.zo == 0) then
      o.removeFromWorld(self)
      other.triggers.posingForItem = true
      self:onPlayerTouch()
      return
    end
  end
end,

draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]
  local zo = self.zo or 0
  local xtotal, ytotal = self.xstart, self.ystart + zo
  love.graphics.draw(
  sprite.img, frame, xtotal, ytotal, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end
end,

trans_draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]

  local xtotal, ytotal = trans.still_objects_coords(self)

  love.graphics.draw(
  sprite.img, frame,
  xtotal, ytotal, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   -- draw
  -- end
end
}

function Drop:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Drop, instance, init) -- add own functions and fields
  return instance
end

return Drop
