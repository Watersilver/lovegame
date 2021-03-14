local u = require "utilities"
local ps = require "physics_settings"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local o = require "GameObjects.objects"
local game = require "game"
local im = require "image"

local Boss2Hand = {}

function Boss2Hand.initialize(instance)
  instance.goThroughEnemies = true
  instance.grounded = true
  instance.levitating = true
  instance.layer = 11
  instance.sprite_info = im.spriteSettings.boss2
  instance.hp = 1
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  -- instance.shielded = true
  -- instance.shieldWall = true
  instance.physical_properties.shape = ps.shapes.bosses.boss2.hand
  instance.spritefixture_properties = nil
  instance.image_index = 0
  instance.drop = "noDrop"
end

Boss2Hand.functions = {
  load = function (self)
    self.sprite = im.sprites["Bosses/boss2/HandFront"]

    local HandBack = require "GameObjects.bosses.boss2.handBack"
    self.handBack = HandBack:new{
      x_scale = self.x_scale, parent = self
    }
    o.addToWorld(self.handBack)
  end,

  enemyUpdate = function (self)
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
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

  refreshComponents = function (self)
    self.bombGoesThrough = true
    self.goThroughPlayer = not self.head.enabled
    self.pushback = self.head.enabled
    self.harmless = not self.head.enabled
    self.ballbreaker = self.head.enabled
    self.attackDodger = not self.head.enabled
  end,
}

function Boss2Hand:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss2Hand, instance, init) -- add own functions and fields
  return instance
end

return Boss2Hand
