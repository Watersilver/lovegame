local p = require "GameObjects.prototype"
local trans = require "transitions"
local u = require "utilities"

local lp = love.physics

local bt = {}

function bt.initialize(instance)
  instance.physical_properties = {
    bodyType = "dynamic",
    density = 40,
    gravityScaleFactor = 0,
    restitution = 0,
    linearDamping = 40,
    fixedRotation = true,
    masks = {PLAYERJUMPATTACKCAT}
  }
  instance.layer = 20
  instance.shieldWall = true
  instance.shielded = true
  instance.x_scale = 1
  instance.y_scale = 1
  instance.ballbreaker = true
  instance.pushback = true
  instance.zo = 0
end

bt.functions = {
  load = function(self)
    -- set up physical properties
    self.xlast = self.x
    self.ylast = self.y
  end,

  update = function(self)
    self.x, self.y = self.body:getPosition()

    -- Determine coordinates for transition
    self.xlast = self.x
    self.ylast = self.y
  end,

  setColour = function (self)
    if self.black then
      u.changeColour{r = 0.6 * COLORCONST, g = 0, b = 0}
    else
      u.changeColour{"white"}
    end
  end,

  draw = function(self, td)
    local resetColour = u.storeColour()

    self:setColour()

    local xtotal, ytotal = self.x, self.y - self.spriteOffset

    if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end
    self.spritebody:setPosition(xtotal, ytotal)
    self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

    local sprite = self.sprite
    -- Check again in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[math.floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)

    resetColour()

    -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
  end,

  trans_draw = function(self)
    local resetColour = u.storeColour()

    self:setColour()

    self.x, self.y = self.xlast, self.ylast - self.spriteOffset

    local xtotal, ytotal = trans.moving_objects_coords(self)

    if self.lightSource then
      -- After done with coords draw light source (gets drawn later, this just sets it up)
      self.lightSource.x, self.lightSource.y = xtotal, ytotal
      ls.drawSource(self.lightSource)
    end

    local sprite = self.sprite
    -- Check again in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[math.floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)

    resetColour()
  end,
}

function bt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(bt, instance, init) -- add own functions and fields
  return instance
end

return bt
