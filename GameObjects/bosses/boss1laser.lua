local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local u = require "utilities"

local proj = require "GameObjects.enemies.projectile"

local Laser = {}

function Laser.initialize(instance)
  instance.grounded = false
  instance.levitating = true
  instance.maxspeed = 0
  instance.physical_properties.shape = ps.shapes.bosses.boss1.laser
  instance.direction = 0
  instance.sprite_info = im.spriteSettings.boss1TestSprites
  instance.hp = 1
  instance.boss1laser = true
  instance.image_index = 1
end

Laser.functions = {
  load = function (self)
    et.functions.load(self)
    self.sprite = im.sprites["arevcyeqLaser1"]
  end,

  draw = function (self)
    if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end
    self.spritebody:setPosition(self.x, self.y)
    self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

    local zo = self.zo or 0
    local xtotal, ytotal = self.x, self.y + zo

    local sprite = self.sprite
    local frames = self.sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
    end
    self.image_index = 1 - self.image_index
    local frame = sprite[self.image_index]

    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, 0,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, 0)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end,
}

function Laser:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(proj, instance) -- add parent functions and fields
  p.new(Laser, instance, init) -- add own functions and fields
  return instance
end

return Laser
