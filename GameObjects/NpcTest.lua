local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"

local floor = math.floor

local NPC = {}

function NPC.initialize(instance)
  instance.physical_properties = {
    bodyType = "static",
    fixedRotation = true,
    density = 160, --160 is 50 kg when combined with plshape dimensions(w 10, h 8)
    shape = ps.shapes.plshape,
    gravityScaleFactor = 0,
    restitution = 0,
    friction = 0,
    masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT}
  }
  instance.spritefixture_properties = {shape = ps.shapes.rect1x1}
  instance.sprite_info = {
    {'Witch/walk_up', 4, padding = 2, width = 16, height = 16}
  }
  instance.image_speed = 0
  instance.image_index = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.layer = 10
  instance.zo = 0
end

NPC.functions = {
draw = function (self)
  local xtotal, ytotal = self.body:getPosition()
  self.x, self.y = xtotal, ytotal

  if self.spritejoint then self.spritejoint:destroy() end
  self.spritebody:setPosition(xtotal, ytotal)
  self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

  local sprite = self.sprite
  -- Check again in case animation changed to something with fewer frames
  while self.image_index >= sprite.frames do
    self.image_index = self.image_index - sprite.frames
  end
  local frame = sprite[floor(self.image_index)]
  love.graphics.draw(
  sprite.img, frame, xtotal, ytotal, self.angle,
  sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
  sprite.cx, sprite.cy)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
  --
  -- love.graphics.setColor(COLORCONST, self.db.downcol, self.db.downcol, COLORCONST)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.downfixture:getShape():getPoints()))
  -- love.graphics.setColor(COLORCONST, self.db.upcol, self.db.upcol, COLORCONST)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.upfixture:getShape():getPoints()))
  -- love.graphics.setColor(COLORCONST, self.db.leftcol, self.db.leftcol, COLORCONST)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.leftfixture:getShape():getPoints()))
  -- love.graphics.setColor(COLORCONST, self.db.rightcol, self.db.rightcol, COLORCONST)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.rightfixture:getShape():getPoints()))
  -- love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
end,

trans_draw = function (self)

  self.x, self.y = self.body:getPosition()

  local xtotal, ytotal = trans.moving_objects_coords(self)

  local sprite = self.sprite
  -- Check again in case animation changed to something with fewer frames
  while self.image_index >= sprite.frames do
    self.image_index = self.image_index - sprite.frames
  end
  local frame = sprite[floor(self.image_index)]
  love.graphics.draw(
  sprite.img, frame, xtotal, ytotal, self.angle,
  sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
  sprite.cx, sprite.cy)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
  --
  -- love.graphics.setColor(COLORCONST, self.db.downcol, self.db.downcol, COLORCONST)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.downfixture:getShape():getPoints()))
  -- love.graphics.setColor(COLORCONST, self.db.upcol, self.db.upcol, COLORCONST)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.upfixture:getShape():getPoints()))
  -- love.graphics.setColor(COLORCONST, self.db.leftcol, self.db.leftcol, COLORCONST)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.leftfixture:getShape():getPoints()))
  -- love.graphics.setColor(COLORCONST, self.db.rightcol, self.db.rightcol, COLORCONST)
  -- love.graphics.polygon("line", self.body:getWorldPoints(self.rightfixture:getShape():getPoints()))
  -- love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
