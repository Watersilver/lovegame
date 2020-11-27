local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local u = require "utilities"
local gsh = require "gamera_shake"

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
  instance.attackDmg = 3
  instance.explosive = true
  instance.blowUpForce = 56
  instance.damCounter = 2
  instance.boss1laser = true
  instance.canBeRolledThrough = false
  instance.canBeBullrushed = false
  instance.image_index = 1
  instance.sounds = snd.load_sounds({
    laserSound = {"Effects/OOA_Boss_Shoot"}
  })
end

Laser.functions = {
  load = function (self)
    et.functions.load(self)
    self.sprite = im.sprites["boss1/arevcyeqLaser1"]
    self.laserSoundInterval = 0.15
    self.laserTimer = 0
  end,

  early_update = function (self, dt)
    self.laserTimer = self.laserTimer + dt
    if self.laserTimer > self.laserSoundInterval then
      snd.play(self.sounds.laserSound)
      self.laserTimer = 0
    end
  end,

  hitByMissile = function () end,

  draw = function (self)
    gsh.newShake(mainCamera, "displacement", 0.2, 0.05, 0.5)
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
