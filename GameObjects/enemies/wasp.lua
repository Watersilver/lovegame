local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"

local Wasp = {}

function Wasp.initialize(instance)
  instance.maxspeed = 80
  instance.sprite_info = im.spriteSettings.wasp
  instance.zo = - 2
  instance.flying = true -- can go through walls
  instance.controlledFlight = true
  instance.lowFlight = true
  instance.hp = 3 --love.math.random(3)
  instance.image_speed = 0.6
  instance.resetBehaviour = 0.5
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
end

Wasp.functions = {
  enemyLoad = function (self)
    sh.handleShadow(self)
  end,

  enemyUpdate = function (self, dt)
    -- Movement behaviour
    ebh.bounceOffScreenEdge(self)
    if self.behaviourTimer < 0 then
      ebh.beehaviour(self)
      self.behaviourTimer = love.math.random(2)
    end
    if self.invulnerable then
      self.direction = nil
    end
    td.analogueWalk(self, dt)
    if self.direction then
      if math.cos(self.direction) > 0 then
        self.x_scale = -1
      else
        self.x_scale = 1
      end
    end

    sh.handleShadow(self)
  end,
}

function Wasp:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Wasp, instance, init) -- add own functions and fields
  return instance
end

return Wasp
