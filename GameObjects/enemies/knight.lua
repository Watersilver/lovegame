local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local gsh = require "gamera_shake"

local Knight = {}

function Knight.initialize(instance)
  instance.maxspeedcharge = 222
  -- instance.sprite_info = { im.spriteSettings.testenemy }
  instance.sprite_info = im.spriteSettings.bullKnight
  instance.hp = 4 --love.math.random(3)
  instance.pushback = true
  instance.shielded = true
  instance.shieldWall = true
  instance.facing = "down"
  instance.sightWidth = 16
  instance.state = "wander"
  instance.maxChargeTime = 5
  instance.chargeTime = 0
  instance.resetBehaviour = 0.5
  instance.noticeSound = snd.load_sound({"Effects/Oracle_Sword_Tap"})
  instance.hitWallSound = snd.load_sound({"Effects/Oracle_ScentSeed"})
  instance.chargeSound = snd.load_sound({"Effects/Oracle_Link_LandRun"})
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
        snd.play(self.noticeSound)
        self.noticeTimer = 0.1
        local dx, dy = pl1.x - self.x, pl1.y - self.y
        -- self.direction = math.atan2(dy, dx)
        self._, self.direction = u.cartesianToPolar(dx, dy)
        -- figure out direction
      end
      -- Movement behaviour
      local vx, vy = self.body:getLinearVelocity()
      -- local x, y = self.body:getPosition()
      self.speed = math.sqrt(vx*vx + vy*vy)
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
      -- Set sprite
      local fac = self.facing
      if fac ~= "right" then
        self.sprite = im.sprites["Enemies/BullKnight/walk_" .. fac]
        self.x_scale = 1
      else
        self.sprite = im.sprites["Enemies/BullKnight/walk_left"]
        self.x_scale = -1
      end
      if self.speed > 0.1 then
        self.image_speed = 0.13 * 0.5
      else
        self.image_speed = 0
        self.image_index = 0
      end
    elseif self.state == "notice" then
      self.image_speed = 0.13 * 1.5
      self.noticeTimer = self.noticeTimer - dt
      if self.noticeTimer < 0 then
        self.state = "charge"
        self.chargeSoundTimer = 999
        self.chargeTime = 0
      end
      td.stand_still(self, dt)
    elseif self.state == "charge" then
      if self.chargeTime > self.maxChargeTime then
        self.shieldDown = false
        self.shieldWall = true
        self.state = "wander"
        self.behaviourTimer = 0
      end
      self.chargeTime = self.chargeTime + dt
      local wanderSpeed = self.maxspeed
      self.maxspeed = self.maxspeedcharge
      td.analogueWalk(self, dt)
      self.maxspeed = wanderSpeed
      if self.chargeSoundTimer >= 0.1 then
        self.chargeSoundTimer = 0
        snd.play(self.chargeSound)
      end
      self.chargeSoundTimer = self.chargeSoundTimer + dt
    elseif self.state == "stunned" then
      self.sprite = im.sprites["Enemies/BullKnight/stun_down"]
      self.image_speed = 0.13 * 0.5
      td.stand_still(self, dt)
      if self.behaviourTimer < 0 then
        self.shieldDown = false
        self.shieldWall = true
        self.state = "wander"
        self.behaviourTimer = 0
      end
    end
  end,

  hitSolidStatic = function (self, other, myF, otherF)
    if self.state == "charge" then
      if other.pushback then
        self.state = "stunned"
        gsh.newShake(mainCamera, "displacement")
        self.behaviourTimer = 2
        self.shieldDown = true
        self.shieldWall = false
        snd.play(self.hitWallSound)
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
    -- local fac = self.facing
    -- local fx, fy = 0, 0
    -- local dist = 10
    -- if fac == "up" then
    --   fy = -dist
    -- elseif fac == "down" then
    --   fy = dist
    -- elseif fac == "left" then
    --   fx = -dist
    -- else
    --   fx = dist
    -- end
    -- love.graphics.circle("fill", self.x + fx, self.y + fy, 1)

    -- exclamation mark
    if self.state == "notice" then
      -- love.graphics.circle("fill", self.x, self.y - 10, 1)
      -- love.graphics.rectangle("fill", self.x - 1, self.y - 24, 2, 10)
      local surpSprite = im.sprites['surprize']
      love.graphics.draw(
      surpSprite.img, surpSprite[math.floor(1)], self.x, self.y - 13, 0,
      1, 1,
      surpSprite.cx, surpSprite.cy)
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
