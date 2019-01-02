local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"

local Knight = {}

function Knight.initialize(instance)
  instance.maxspeedcharge = 222
  instance.sprite_info = { im.spriteSettings.testenemy }
  instance.hp = 4 --love.math.random(3)
  instance.shielded = true
  instance.shieldWall = true
  instance.facing = "down"
  instance.sightWidth = 16
  instance.state = "wander"
end

Knight.functions = {
  enemyUpdate = function (self, dt)
    -- Look for player
    if self.lookFor then self.canSeePlayer = self:lookFor(pl1) end
    -- Fortify self again after taking damage
    if self.invulnerableEnd then
      self.shieldDown = false
      self.shieldWall = true
    end
    -- do stuff depending on state
    if self.state == "wander" then
      if self.canSeePlayer then
        self.state = "notice"
        self.noticeTimer = 0.1
        local dx, dy = pl1.x - self.x, pl1.y - self.y
        self.direction = math.atan2(dy, dx)
        -- figure out direction
      end
      -- Movement behaviour
      if self.behaviourTimer < 0 then
        self.facing = ebh.randomize4dir(self, true)
        self.behaviourTimer = love.math.random(2)
      end
      if self.invulnerable and not self.shieldWall then
        local inp = self.input
        for dir, _ in pairs(inp) do
          inp[dir] = 0
        end
      end
      td.walk(self, dt)
    elseif self.state == "notice" then
      self.noticeTimer = self.noticeTimer - dt
      if self.noticeTimer < 0 then self.state = "charge" end
      td.stand_still(self, dt)
    elseif self.state == "charge" then
      local wanderSpeed = self.maxspeed
      self.maxspeed = self.maxspeedcharge
      td.analogueWalk(self, dt)
      self.maxspeed = wanderSpeed
    elseif self.state == "stunned" then
      td.stand_still(self, dt)
      if self.behaviourTimer < 0 then
        self.shieldDown = false
        self.shieldWall = true
        self.state = "wander"
        self.behaviourTimer = 0
      end
    end
  end,

  hitBySword = function (self, other, myF, otherF)
    ebh.propelledByHit(self, other, myF, otherF, 3, 1, 1, 0.5)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
    if self.state == "charge" then
      if other.pushback then
        self.state = "stunned"
        self.behaviourTimer = 2
        self.shieldDown = true
        self.shieldWall = false
      else
        self.state = "wander"
        self.behaviourTimer = 0
        self.moving = true
      end
    end
  end,

  draw = function (self)
    et.functions.draw(self)

    -- Facing debug
    local fac = self.facing
    local fx, fy = 0, 0
    local dist = 10
    if fac == "up" then
      fy = -dist
    elseif fac == "down" then
      fy = dist
    elseif fac == "left" then
      fx = -dist
    else
      fx = dist
    end
    love.graphics.circle("fill", self.x + fx, self.y + fy, 1)

    -- exclamation mark
    if self.state == "notice" then
      love.graphics.circle("fill", self.x, self.y - 10, 1)
      love.graphics.rectangle("fill", self.x - 1, self.y - 24, 2, 10)
    end
  end
}

function Knight:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Knight, instance, init) -- add own functions and fields
  return instance
end

return Knight
