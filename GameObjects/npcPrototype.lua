local ps = require "physics_settings"
local u = require "utilities"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local lighting = require "ScreenEffects.lighting.lighting"

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

NPC.functions = {
  turn = function (self, side)
    if self.facing == side then return end
    self.facing = side
    self.x_scale = 1
    self.sprite = im.sprites[self.spritepath .. side]
    -- self.sprite = im.sprites["NPCs/ResqueGirl/" .. side]
    if side == "right" then
      self.x_scale = -1
      self.sprite = im.sprites[self.spritepath .. "left"]
      -- self.sprite = im.sprites["NPCs/ResqueGirl/left"]
    end
  end,

  faceTowards = function (self, other)
    if other and other.exists then
      local xdis = other.x - self.x
      local ydis = other.y - self.y
      if math.abs(xdis) > math.abs(ydis) then
        if xdis > 0 then self:turn("right") else self:turn("left") end
      else
        if ydis > 0 then self:turn("down") else self:turn("up") end
      end
    end
  end,

  applyLights = function(self, x, y)
    if self.lights then
      local l = {}
      for _, light in ipairs(self.lights) do
        for key, value in pairs(light) do
          l[key] = value
        end
        if l.x == nil then l.x = x end
        if l.y == nil then l.y = y end
      end
      lighting.applyLight(l)
    end
  end,

  draw = function (self)
    local xtotal, ytotal
    if self.body then
      xtotal, ytotal = self.body:getPosition()
      self.x, self.y = xtotal, ytotal
    else
      xtotal, ytotal = self.x, self.y
    end
    ytotal = ytotal + self.zo

    self:applyLights(xtotal, ytotal)

    if self.spritebody then
      if self.spritejoint then self.spritejoint:destroy() end
      self.spritebody:setPosition(xtotal, ytotal)
      if self.body then self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0) end
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
    sprite.cx, sprite.cy)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    --
    -- love.graphics.setColor(1, self.db.downcol, self.db.downcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.downfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.upcol, self.db.upcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.upfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.leftcol, self.db.leftcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.leftfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.rightcol, self.db.rightcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.rightfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, 1, 1, 1)
  end,

  trans_draw = function (self)

    if self.body then
      self.x, self.y = self.body:getPosition()
    end

    local xtotal, ytotal = trans.moving_objects_coords(self)
    ytotal = ytotal + self.zo

    self:applyLights(xtotal, ytotal)

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
    -- love.graphics.setColor(1, self.db.downcol, self.db.downcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.downfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.upcol, self.db.upcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.upfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.leftcol, self.db.leftcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.leftfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, self.db.rightcol, self.db.rightcol, 1)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.rightfixture:getShape():getPoints()))
    -- love.graphics.setColor(1, 1, 1, 1)
  end
  }

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
