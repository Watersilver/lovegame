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
  instance.sprite_info = { im.spriteSettings.testenemy4 }
  instance.hp = 1
end

Laser.functions = {
  load = function (self)
    et.functions.load(self)
  end,

  draw = function (self)
    proj.functions.draw(self)
    love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
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
