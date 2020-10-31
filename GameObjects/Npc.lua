local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local bubble = require "GameObjects.DialogueBubble.DialogueBubble"
local ls = require "lightSources"

local floor = math.floor

-- Rename to talky or something
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
  instance.sprite_info = im.spriteSettings.npcTestSprites
  instance.image_speed = 0.05
  instance.image_index = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.layer = 20
  instance.zo = 0
  instance.zvel = 0
  instance.gravity = 350
  instance.unpushable = true
end
-- 7, 17
NPC.functions = {
  load = function (self)
    -- bubble
    self.maBubble = bubble.addNew("yes this is what I am looking for you stupid piece of crap. Exactly this", self)
  end,

  unpausable_update = function (self, dt)
    -- we'll see
  end,

  update = function (self, dt)
    self.image_index = (self.image_index + dt*60*self.image_speed)
    while self.image_index >= self.sprite.frames do
      self.image_index = self.image_index - self.sprite.frames
    end
    self.x, self.y = self.body:getPosition()
  end,

  draw = function (self, td)
    local xtotal, ytotal = self.x, self.y

    if td then
      xtotal, ytotal = trans.moving_objects_coords(self)
    end

    if self.lightSource then
      -- After done with coords draw light source (gets drawn later, this just sets it up)
      self.lightSource.x, self.lightSource.y = xtotal, ytotal
      ls.drawSource(self.lightSource)
    end

    if self.spritebody then
      if self.spritejoint then self.spritejoint:destroy() end
      self.spritebody:setPosition(xtotal, ytotal)
      self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)
    end

    local sprite = self.sprite
    -- Check again in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[floor(self.image_index)]
    love.graphics.draw(
      sprite.img, frame, xtotal, ytotal, self.angle,
      sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
      sprite.cx, sprite.cy
    )
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
    self:draw(true)
  end
  }

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
