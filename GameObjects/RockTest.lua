local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local im = require "image"
local shdrs = require "Shaders.shaders"
local trans = require "transitions"
local expl = require "GameObjects.explode"
local o = require "GameObjects.objects"
local snd = require "sound"
local drops = require "GameObjects.drops.drops"
local u = require "utilities"

local dc = require "GameObjects.Helpers.determine_colliders"



local lp = love.physics

local rt = {}

local sprite_info = {im.spriteSettings.liftableRock}

local explosion_sprite = im.spriteSettings.rockDestruction
local explosion_sound = {"Effects/Oracle_Rock_Shatter"}

local function throw_collision(self)
  expl.commonExplosion(self)
  drops.normal(self.x, self.y)
end

function rt.initialize(instance)
  instance.sprite_info = sprite_info
  instance.contacts = 0
  instance.physical_properties = {
    shape = ps.shapes.circleAlmost1,
    masks = {PLAYERJUMPATTACKCAT}
  }
  instance.layer = 15
  instance.liftable = true
  instance.strongPushover = true
  instance.pushback = true
  instance.ballbreaker = true
  instance.image_index = 0
  instance.breakableByUpgradedSword = true
  instance.throw_collision = throw_collision
end

rt.functions = {

  onMdustTouch = function (self, other)
    local reaction = u.chooseFromChanceTable{
      -- chance of plant
      {value = other.createPlant, chance = 0.03},
      -- chance of exploding
      {value = other.createBomb, chance = 0.02},
      -- If none of the above happens, nothing happens
      -- {value = nil, chance = 1},
    }
    if not reaction then return end
    if reaction == other.createFire then self.onMdustTouch = nil
    else o.removeFromWorld(self) end
    reaction(self)
  end,

  load = function(self)
    self.image_speed = 0
    if self.petrified then
      self.myShader = shdrs.stoneShader
    end
  end,

  draw = function (self)
    local x, y = self.xstart, self.ystart
    local sprite = self.sprite
    self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
    local frame = sprite[self.image_index]
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
  end,

  trans_draw = function (self)
    local xtotal, ytotal = trans.still_objects_coords(self)

    local sprite = self.sprite
    self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
    local frame = sprite[self.image_index]
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    self.contacts = self.contacts + 1
    if (session.save.dinsPower and other.immasword) or (other.immabombsplosion and other.poweredUp) then
      throw_collision(self)
      o.removeFromWorld(self)
    elseif not self.petrified and other.immamdust and not other.hasReacted and self.onMdustTouch then
      other.hasReacted = true
      self.onMdustTouch(self, other)
    end
  end,

  endContact = function(self, a, b, coll)
    self.contacts = self.contacts - 1
  end,
}

function rt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(rt, instance, init) -- add own functions and fields
  return instance
end

return rt
