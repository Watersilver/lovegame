local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local inp = require "input"
local dlg = require "dialogue"
local ls = require "lightSources"

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
  instance.unpushable = true
end

NPC.functions = {
  activate = function (self, dt)
    if self.activated then
      dlg.simpleWallOfText.setUp(
        {{{COLORCONST,COLORCONST,COLORCONST,COLORCONST},"\z
        Hi there, little monkey. \z
        This house's layout looks \z
        different from the outside, eh? \z
        Isn't it weird? ",
        {COLORCONST,COLORCONST/2,COLORCONST/2,COLORCONST},
        "I also don't have any furniture, for some reason. \z
        HAHAHAHAHAHAHAHAHAHAHAHAHAHAHA \z
        HAHAHAHAHAHAHAHAHAHAHAHAHAHAHA \z
        HAHAHAHAHAHAAAAAAAAAAAAAAARGH!"
        },
        -1, "left"},
        self.y,
        function() self.counter = 5 end
      )
      dlg.enable = true
      if self.activator then
        if self.activator.body then self.activator.body:setType("static") end
        if self.activator.player then inp.disable_controller(self.activator.player) end
      end
      self.counter = 0
    elseif self.active then
      -- self.counter = self.counter + dt
      if self.counter > 3 then self.active = false end
    else
      if self.activator then
        if self.activator.body then self.activator.body:setType("dynamic") end
        if self.activator.player then inp.enable_controller(self.activator.player) end
      end
    end
    -- fuck = self.counter
  end,

  unpausable_update = function (self, dt)
    if self.activated then
      self:activate(dt)
      self.activated = false
      self.active = true
    elseif self.active then
      self:activate(dt)
    elseif self.activator then
      self.unactivatable = false
      self:activate(dt)
      self.activator = nil
    end
  end,

  update = function (self, dt)
    self.image_index = (self.image_index + dt*60*self.image_speed)
    while self.image_index >= self.sprite.frames do
      self.image_index = self.image_index - self.sprite.frames
    end
  end,

  draw = function (self)
    local xtotal, ytotal = self.body:getPosition()
    self.x, self.y = xtotal, ytotal

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
