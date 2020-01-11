local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local expl = require "GameObjects.explode"
local o = require "GameObjects.objects"
local dc = require "GameObjects.Helpers.determine_colliders"
local snd = require "sound"
local drops = require "GameObjects.drops.drops"


local function throw_collision(self)
  local explOb = expl:new{
    x = self.x or self.xstart, y = self.y or self.ystart,
    layer = self.explLayer or self.layer,
    explosionNumber = self.explosionNumber,
    sprite_info = self.explosionSprite,
    image_speed = self.explosionSpeed,
    sounds = snd.load_sounds({explode = self.explosionSound})
  }
  o.addToWorld(explOb)
  drops.cheap(self.x, self.y)
end

local Brick = {}

function Brick.initialize(instance)
  -- instance.physical_properties = {
  --   tile = true,
  --   edgetable = ps.shapes.edgeRect1x1
  -- }
  instance.physical_properties = {
    shape = ps.shapes.circleAlmost1,
    masks = {PLAYERJUMPATTACKCAT}
  }
  instance.sprite_info = {
    {'Brick', 2, 2}
  }
  instance.explosionSprite = {im.spriteSettings.bushDestruction}
  instance.explosionNumber = 1
  instance.explosionSpeed = 0.3
  instance.explosionSound = {"Effects/Oracle_Bush_Cut"}
  instance.allsides = true
  instance.ballbreaker = true
  instance.liftable = true
  instance.throw_collision = throw_collision
  instance.explLayer = 25
  instance.lifterSpeedMod = 0.8
end

Brick.functions = {
draw = function (self)
  local x, y = self.body and self.body:getPosition() or self.xstart, self.ystart
  local sprite = self.sprite
  self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
  local frame = sprite[self.image_index]
  love.graphics.draw(
  sprite.img, frame, x, y, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   for i, fixture in ipairs(self.fixtures) do
  --     local shape = fixture:getShape()
  --     love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
  --   end
  -- end
end,

trans_draw = function (self)
  local xtotal, ytotal = trans.still_objects_coords(self)

  local sprite = self.sprite
  self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
  local frame = sprite[self.image_index]
  love.graphics.draw(
  sprite.img, frame, xtotal, ytotal, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   for i, fixture in ipairs(self.fixtures) do
  --     local shape = fixture:getShape()
  --     love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
  --   end
  -- end
end,

load = function(self)
  self.image_speed = 0
end,

beginContact = function(self, a, b, coll, aob, bob)

  -- Find which fixture belongs to whom
  local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
  if other.immasword then
    self:throw_collision()
    o.removeFromWorld(self)
    self.beginContact = nil
  end
end
}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
