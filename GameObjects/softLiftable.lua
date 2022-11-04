local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local expl = require "GameObjects.explode"
local o = require "GameObjects.objects"
local dc = require "GameObjects.Helpers.determine_colliders"
local snd = require "sound"
local u = require "utilities"
local mdust = require "GameObjects.Items.mdust"
local drops = require "GameObjects.drops.drops"
local shdrs = require "Shaders.shaders"
local FM = require ("GameObjects.FloorDetectors.floorMarker")
local FU = require ("GameObjects.FloorDetectors.floorUnmarker")
local magic_dust_effects = require("GameObjects.Helpers.magic_dust_effects")

local function throw_collision(self)
  local explOb = expl:new{
    x = self.x or self.xstart, y = self.y or self.ystart,
    layer = self.explLayer or self.layer,
    explosionNumber = self.explosionNumber,
    sprite_info = self.explosionSprite,
    image_speed = self.explosionSpeed,
    sounds = snd.load_sounds({explode = self.explosionSound})
  }
  o.addToWorld(explOb)
  if self.myDrops then
    self:myDrops()
  end
end

local Brick = {}

function Brick.initialize(instance)
  -- instance.physical_properties = {
  --   tile = true,
  --   edgetable = ps.shapes.edgeRect1x1
  -- }
  instance.physical_properties = {
    shape = ps.shapes.circleAlmost1,
    masks = {PLAYERJUMPATTACKCAT}
  }
  instance.sprite_info = {
    {'Brick', 2, 2}
  }
  instance.explosionSprite = {im.spriteSettings.bushDestruction}
  instance.explosionNumber = 1
  instance.explosionSpeed = 0.3
  instance.explosionSound = {"Effects/Oracle_Bush_Cut"}
  instance.allsides = true
  instance.ballbreaker = true
  instance.liftable = true
  instance.lift_info = "softLiftable"
  instance.sprintThrough = true
  instance.pushover = true
  instance.throw_collision = throw_collision
  instance.explLayer = 25
  instance.lifterSpeedMod = 0.8
  instance.freezable = true
end

Brick.functions = {
  [GCON.md.choose] = function ()
    return u.chooseFromChanceTable{
      -- chance of stoning
      {value = GCON.md.reaction.stone, chance = 0.1},
      -- chance of exploding
      {value = GCON.md.reaction.bomb, chance = 0.02},
      -- chance of freezing
      {value = GCON.md.reaction.ice, chance = 0.25},
      -- chance of burning
      {value = GCON.md.reaction.fire, chance = 0.25},
      -- chance of getting blown
      {value = GCON.md.reaction.wind, chance = 0.25},
      -- If none of the above happens, nothing happens
      {value = GCON.md.reaction.nothing, chance = 1},
    }
  end,

  [GCON.md.reaction.stone] = function (self)
    magic_dust_effects.createStone(self)
  end,

  [GCON.md.reaction.bomb] = function (self)
    magic_dust_effects.createBomb(self)
  end,

  [GCON.md.reaction.ice] = function (self)
    magic_dust_effects.createFrozenBlock(self)
  end,

  [GCON.md.reaction.fire] = function (self)
    magic_dust_effects.burn(self)
  end,

  [GCON.md.reaction.wind] = function (self)
    magic_dust_effects.blow(self)
  end,

  myDrops = function (self)
    drops.cheap(self.x, self.y)
  end,

  onFireEnd = function (self)
    if self.myDrops then
      self:myDrops()
    end
    o.removeFromWorld(self)
  end,

  onWhirlwindStart = function (self)
    self:throw_collision()
    o.removeFromWorld(self)
  end,

  load = function(self)
    self.persistentData = {
      drops = self.drops
    }

    self.image_speed = 0
    if self.plantified then
      self.myShader = shdrs.plantShader
    end
    local x, y = self.body:getPosition()
    local myFm = FM:new{x = x, y = y}
    o.addToWorld(myFm)
  end,

  destroy = function (self)
    local myFu = FU:new{x = self.x, y = self.y}
    o.addToWorld(myFu)
  end,

  draw = function (self)
    local x, y = self.body and self.body:getPosition() or self.xstart, self.ystart
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
    -- if self.body then
    --   for i, fixture in ipairs(self.fixtures) do
    --     local shape = fixture:getShape()
    --     love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
    --   end
    -- end
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
    -- if self.body then
    --   for i, fixture in ipairs(self.fixtures) do
    --     local shape = fixture:getShape()
    --     love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
    --   end
    -- end
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if other.immasword or other.immabombsplosion then
      self:throw_collision()
      o.removeFromWorld(self)
      self.beginContact = nil
    end
  end
}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
