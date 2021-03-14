local u = require "utilities"
local ps = require "physics_settings"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local o = require "GameObjects.objects"
local game = require "game"
local im = require "image"
local ebh = require "enemy_behaviours"

local Boss2Eye = {}

function Boss2Eye.initialize(instance)
  instance.goThroughEnemies = true
  instance.grounded = true
  instance.levitating = true
  instance.layer = 11
  instance.sprite_info = im.spriteSettings.boss2
  instance.hp = 50
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.side = 1
  instance.shielded = false
  -- instance.shieldWall = true
  instance.physical_properties.shape = ps.shapes.bosses.boss2.eye
  instance.spritefixture_properties = nil
  instance.image_index = 0
  instance.eyelidState = 2
  instance.drop = "noDrop"
  instance.shieldTimer = 0
  instance.fullyOpenTimer = 0
end

Boss2Eye.functions = {
  load = function (self)
    self.sprite = (self.side > 0) and im.sprites["Bosses/boss2/LeftEye"] or im.sprites["Bosses/boss2/RightEye"]
  end,

  enemyUpdate = function (self, dt)
    self.image_index = u.clamp(0, self.shielded and 2 or (self.pain and self.pain or self.eyelidState), 2)

    if not self.head.enabled then return end

    -- Recover from pain
    self.shieldTimer = self.shieldTimer - dt
    if self.shieldTimer < 0 then
      self.shieldTimer = 0
      self.fullyOpenTimer = self.fullyOpenTimer - dt
      self.shielded = false
      if self.pain then self.pain = 1 end
    end

    if self.fullyOpenTimer < 0 then
      self.fullyOpenTimer = 0
      self.pain = nil
    end
  end,

  late_update = function (self)
    local head = self.head
    if not head then return o.removeFromWorld(self) end

    -- offset from middle of head
    local xoffset, yoffset
    xoffset = self.side * 33
    yoffset = 4
    -- Head eye position changes when image index changes
    -- Take care of that here
    local intii = math.floor(head.image_index)
    if intii == 1 then
      yoffset = yoffset - 8
    elseif intii == 2 then
      yoffset = yoffset - 16
    end
    xoffset, yoffset = u.rotate2d(xoffset, yoffset, head.angle)

    local x, y = xoffset + head.x, yoffset + head.y
    self.body:setPosition(x, y)
    self.x, self.y = x, y
    self.angle = head.angle
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
    if not self.head.enabled then return end

    ebh.damagedByHit(self, other, myF, otherF)
    self:gotHurt()
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  hitByBombsplosion = function (self, other, myF, otherF)
  end,

  hitByBullrush = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
  end,

  destroy = function (self)
    -- What happens when I get destroyed.
  end,

  -- draw = function (self)
  --
  --   -- Draw enemy the default way
  --   et.functions.draw(self)
  --
  --   -- Draw extra stuff like eyes and hands.
  --
  --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end,

  gotHurt = function (self)
    self.shielded = true
    self.shieldTimer = 1
    self.fullyOpenTimer = 0.5
    self.pain = 2
  end,

  refreshComponents = function (self)
    self.bombGoesThrough = true
    self.goThroughPlayer = not self.head.enabled
    self.pushback = self.head.enabled
    self.harmless = not self.head.enabled
    self.ballbreaker = self.head.enabled
    self.attackDodger = not self.head.enabled
  end,
}

function Boss2Eye:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss2Eye, instance, init) -- add own functions and fields
  return instance
end

return Boss2Eye
