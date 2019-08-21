local p = require "GameObjects.prototype"
local gs = require "game_settings"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local Missile = {}

local floor = math.floor
local pi = math.pi
local sqrt = math.sqrt

local emptyFunc = function() end

--  Calculate sword position and angle offset due to creator's side
local function calculate_offset(side, phase)
  local xoff, yoff, aoff = 0, 0, 0
  if side == "down" then
    xoff = 0
    yoff = 3
  elseif side == "right" then
    xoff = 9
    yoff = 3
  elseif side == "left" then
    xoff = - 9
    yoff = 3
  elseif side == "up" then
    xoff = 0
    yoff = - 7
  end
  return xoff, yoff
end

function Missile.initialize(instance)
  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.triggers = {}
  instance.sprite_info = {
    im.spriteSettings.playerMissile,
    im.spriteSettings.playerMissileOutline
  }
  -- instance.spritefixture_properties = {shape = ps.shapes.swordSprite}
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    sensor = true,
    density = 0,
    shape = ps.shapes.missile,
    categories = {PLAYERATTACKCAT},
    -- masks = {FLOORCAT}
  }
  instance.creator = nil -- Object that swings me
  instance.side = nil -- down, right, left, up
  instance.seeThrough = true
  instance.immamissile = true
  if session.save.missileShader then
    instance.myShader = shdrs[session.save.missileShader]
  else
    if session.save.nayrusWisdom then instance.myShader = shdrs["itemBlueShader"] end
  end
end

Missile.functions = {
  load = function (self)
    self.sox, self.soy = calculate_offset(self.side)
    self.x, self.y = 0, 0
    session.mslQueue:add(self)
    self.outlineSprite = im.sprites["Inventory/UseMissileOutlineL1"]
  end,

  early_update = function(self, dt)
    local cr = self.creator

    if self.weld and not self.weld:isDestroyed() then self.weld:destroy(); self.weld = nil end

    if not self.fired then

      if cr.missile_cooldown then
        local stage = cr.missile_cooldown/cr.missile_cooldown_limit
        self.image_index = stage * (self.sprite.frames - 1)
      end

      -- Determine offset due to falling
      local fy = 0
      if cr.edgeFall and cr.edgeFall.step2 then
        fy = - cr.edgeFall.height
      end

      -- Set position
      local creatorx, creatory = cr.body:getPosition()
      local x, y = creatorx + self.sox, creatory + self.soy + cr.zo + fy
      self.body:setPosition(x, y)

      -- Weld
      self.weld = love.physics.newWeldJoint(cr.body, self.body, x, y, true)

      local layeradjust = 0
      if self.side == "up" then layeradjust = -1 end
      o.change_layer(self, cr.layer+layeradjust)
    -- else
    --   self.weld = nil
    end

  end,

  update = function(self, dt)
    -- if self.spritejoint then self.spritejoint:destroy() end
    local x, y = self.body:getPosition()
    -- self.spritebody:setPosition(x, y)
    -- self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

    self.x, self.y = x, y

    if self.broken and self.fired and self.image_index ~= 0 then
      self.body:setLinearVelocity(0, 0)
      self.image_index = self.image_index - dt * 60
      if self.image_index < 0 then
        self.image_index = 0
        self.trans_draw = emptyFunc
        self.draw = emptyFunc
        self.update = emptyFunc
        self.early_update = emptyFunc
        -- Stop colliding
        self.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
      end
    end
    if self.pastMslLim then
      if not self.broken then self.image_index = self.image_index - dt * 60 end
      if self.image_index < 0 then
        self.image_index = 0
        o.removeFromWorld(self)
      end
    end
    if not self.outOfBounds then
      if x < 0 or x > game.room.width then
        self.outOfBounds = true
        self.trans_draw = emptyFunc
      elseif y < 0 or y > game.room.height then
        self.outOfBounds = true
        self.trans_draw = emptyFunc
      end
    end
  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    if td then
      x = x + trans.xtransform
      y = y + trans.ytransform
    end

    self.x, self.y = x, y
    local sprite = self.sprite
    -- Check in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[floor(self.image_index)]
    local worldShader = love.graphics.getShader()

    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)

    if self.hitBySword and self.image_index >= 4 then
      local outlineSprite = self.outlineSprite
      love.graphics.draw(
      outlineSprite.img, outlineSprite[0], x, y, 0,
      outlineSprite.res_x_scale*self.x_scale,
      outlineSprite.res_y_scale*self.y_scale,
      outlineSprite.cx, outlineSprite.cy)
    end

    love.graphics.setShader(worldShader)

    -- Debug
    -- love.graphics.polygon("line",
    -- self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    -- love.graphics.polygon("line",
    -- self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.circle("line", x, y, self.fixture:getShape():getRadius())
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    local cr = self.creator

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Check if other is dodger
    if other.attackDodger then
      return
    end

    -- Check if I will be broken
    if other.ballbreaker == true then
      if not other.edge then
        self.broken = true
      else
        if other.side == "down" then
          self.broken = true
        elseif other.side == "left" then
          if self.x < other.xstart - 8 then self.broken = true end
        else
          if self.x > other.xstart + 8 then self.broken = true end
        end
      end
      if other.zo then
        if other.zo < -5 and (not other.ballbreakerEvenIfHigh) then
          self.broken = nil
        end
      end
    end

    -- Check if propelled by sword
    if other.sword == true then
      local speed = 200
      -- local prevvx, prevvy = self.body:getLinearVelocity()
      self.hitBySword = true

      if cr and cr.exists then snd.play(cr.sounds.swordShoot) end

      local xadjust, yadjust
      local side = other.side
      if side == "left" or side == "right" then
        xadjust, yadjust = 0, 4
      elseif side == "up" then
        xadjust, yadjust = -3, 0
      else
        xadjust, yadjust = 3, 0
      end

      local adj, opp = self.x - cr.x - xadjust, self.y - cr.y - yadjust
      local hyp = sqrt(adj*adj + opp*opp)

      self.body:setLinearVelocity(speed*adj/hyp, speed*opp/hyp)
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
  end,

  delete = function(self)
    if self.pastMslLim then

    else
      session.mslQueue:remove()
    end
    if self == self.creator.missile then self.creator.missile = nil end
  end
}

function Missile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Missile, instance, init) -- add own functions and fields
  return instance
end

return Missile
