local p = require "GameObjects.prototype"
local gs = require "game_settings"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local utilities = require "utilities"
local counter   = require "counter"
local mdust     = require "GameObjects.Items.mdust"

-- missile light
local lighting = require 'ScreenEffects.lighting.lighting'

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local Missile = {}

local floor = math.floor
local pi = math.pi
local sqrt = math.sqrt

local emptyFunc = function() end

local creation_alpha_table = {[7] = 1}
local animation_alpha_table = {first = 1, last = 1, [0] = 1, [4] = 0.6, [7] = 1}
local destruction_alpha_table = {[-1] = 1, [0] = 1}

function Missile.initialize(instance)
  -- missile light
  instance.angle = 0
  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.triggers = {}
  instance.sprite_info = im.spriteSettings.playerMissile
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
  instance.light_intensity = 0
end


function Missile.getDeflected(self, deflector, sword)
  local speed = 200
  -- local prevvx, prevvy = self.body:getLinearVelocity()
  self.deflected = true

  if deflector and deflector.exists then
    snd.play(deflector.sounds.swordShoot)

    local xadjust, yadjust
    local side = sword.side
    if side == "left" or side == "right" then
      xadjust, yadjust = 0, 4
    elseif side == "up" then
      xadjust, yadjust = -3, 0
    else
      xadjust, yadjust = 3, 0
    end

    local adj, opp = self.x - deflector.x - xadjust, self.y - deflector.y - yadjust
    local hyp = sqrt(adj*adj + opp*opp)

    self.body:setLinearVelocity(speed*adj/hyp, speed*opp/hyp)
  end

end


Missile.functions = {
  compute_offset = function (self)
    local side = self.side
    local cr = self.creator
    if side == "down" then
      self.sox = 0
      self.soy = 3
    elseif side == "right" then
      self.sox = 7
      self.soy = 3
    elseif side == "left" then
      self.sox = - 7
      self.soy = 3
    elseif side == "up" then
      self.sox = 0
      self.soy = -2
    end

    local ii = math.floor(cr.image_index)
    if ii == 1 or ii == 2 or ii == 6 or ii == 7 then
      self.soy = self.soy - 3
    elseif ii == 3 or ii == 8 then
      self.soy = self.soy - 2
    elseif ii == 0 or ii == 5 then
      self.soy = self.soy - 1
    end

    local horside = (side == 'right' and 1) or (side == 'left' and -1) or 0
    if ii < 3 then
      if horside ~= 0 then
        self.sox = self.sox - horside * 1
      end
    elseif ii > 4 and ii < 8 then
      if horside ~= 0 then
        self.sox = self.sox - horside * 1
      end
    end
  end,

  load = function (self)
    self:compute_offset()
    self.x, self.y = 0, 0
    session.mslQueue:add(self)
    self.outlineSprite = im.sprites["Inventory/missile/outline"]

    self.sparkCounter = counter.new(.2)

    if session.save.nayrusWisdom then
      self.poweredUp = true
    end

    local r, g, b = utilities.hslToRgb(love.math.random(), 1, 0.5)

    if session.wornRing == 'ringRainbow' then
      self.rgba = {
        r= r,
        g= g,
        b= b,
        a= 1
      }
    end

    self.layer_timer = 0.5
  end,

  early_update = function(self, dt)
    self.light_intensity = self.light_intensity + dt * 4
    if self.light_intensity > 1 then self.light_intensity = 1 end

    local cr = self.creator

    if self.weld and not self.weld:isDestroyed() then self.weld:destroy(); self.weld = nil end

    if self.charged and self.sparkCounter:update(dt) then
      local dx, dy = utilities.randomPointFromEllipse(4, 4, true)
      session.particles:addColouredSpark{x = self.x + dx, y = self.y + dy}
    end

    if self.pastMslLim then
      self.broken = true
    end

    if not self.fired then

      if not cr or not cr.exists then
        self.broken = true
        return
      end

      if cr.missile_start_counter then
        local stage = cr.missile_start_counter/cr.missile_start_duration
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
      if self.side == "up" then
        layeradjust = - 1
      elseif self.side == "left" or self.side == "right" then
        if cr.image_index < 3 then
          layeradjust = - 1
        end
      end
      o.change_layer(self, cr.layer+layeradjust)
    end

    if self.layer_timer > 0 then
      self.layer_timer = self.layer_timer - dt
      if self.layer_timer < 0 then
        o.change_layer(self, cr.layer)
      end
    end
  end,

  update = function(self, dt)
    local cr = self.creator

    if not cr or not cr.exists then
      self.broken = true
    end

    if self.fired then
      if not self.broken then
        if self.sprite ~= im.sprites['Inventory/missile/animation'] then
          self.sprite = im.sprites['Inventory/missile/animation']
          self.image_index = love.math.random() * self.sprite.frames
          self.angle = math.pi * (love.math.random(4) - 1) / 2
          self.image_speed = 0.2
        end
      else
        if self.sprite ~= im.sprites['Inventory/missile/destruction'] then
          self.sprite = im.sprites['Inventory/missile/destruction']
          self.image_index = 0
          self.image_speed = 0.3
        end
      end
    end

    -- if self.spritejoint then self.spritejoint:destroy() end
    local x, y = self.body:getPosition()
    -- self.spritebody:setPosition(x, y)
    -- self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)

    self.x, self.y = x, y

    self.animation_end = false
    self.image_index = (self.image_index + dt*60*self.image_speed)
    local frames = self.sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
      if frames > 1 then self.animation_end = true end
    end
    while self.image_index < 0 do
      self.image_index = self.image_index + frames
      if frames > 1 then self.animation_end = true end
    end

    if self.broken then
      if self.dust and not self.outOfBounds and not self.pastMslLim then
        o.addToWorld(self.dust)
      end
      self.dust = nil

      if self.fired then
        if self.animation_end then
          -- self.trans_draw = emptyFunc
          -- self.draw = emptyFunc
          -- self.update = emptyFunc
          -- self.early_update = emptyFunc
          self.image_index = self.sprite.frames - 1
          self.image_speed = 0
          o.removeFromWorld(self)
        end
      end

      self.body:setLinearVelocity(0, 0)
      if not self.itsoverjoker then
        self.itsoverjoker = true
        -- Stop colliding
        self.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
      end
    else
      if self.charged then
        if not self.dust then
          self.dust = mdust:new{
            creator = cr,
            side = cr:getFacing(),
            layer = cr:getFacing() == "up" and cr.layer - 1 or cr.layer + 1
          }
        end
        self.dust.x = self.x
        self.dust.y = self.y
        self.dust.xstart = self.x
        self.dust.ystart = self.y
      end
    end
    if not self.outOfBounds then
      local sprite = self.sprite
      local sw2 = sprite.width*0.5
      local sh2 = sprite.height*0.5
      if x < -sw2 or x > game.room.width + sw2 then
        self.outOfBounds = true
        self.broken = true
        self.trans_draw = emptyFunc
      elseif y < -sh2 or y > game.room.height + sh2 then
        self.outOfBounds = true
        self.broken = true
        self.trans_draw = emptyFunc
      end
    end
  end,

  late_update = function(self, dt)
    self:compute_offset()
  end,

  unstoppable_update = function(self)

    local x, y = self.x, self.y

    if game.transitioning and game.transitioning.type == 'scrolling' then
      self.x, self.y = self.body:getPosition()
      x, y = trans.moving_objects_coords(self)
      self.x, self.y = x, y
    end

    -- missile light
    local alpha_table = animation_alpha_table
    if self.sprite == im.sprites["Inventory/missile/creation"] then
      alpha_table = creation_alpha_table
    elseif self.sprite == im.sprites["Inventory/missile/destruction"] then
      alpha_table = destruction_alpha_table
    end
    local a = utilities.compute_alpha_from_table(self.image_index, self.sprite.frames, alpha_table, self.onPreviousRoom, game.transitioning)
    if self.rgba then
      self.rgba.a = a
    end
    a = self.light_intensity * a
    -- local rgba = self.rgba and self.rgba or (self.poweredUp and {r=0,g=0.5,b=1,a=1} or {r=0,g=1,b=0,a=1})
    lighting.applyLight{
      -- type = 'missile',
      type = 'dynamic',
      x = x,
      y = y,
      dynamic_options = {radius = a * 4},
      rgba = {r=1,g=1,b=1,a=1},
      scale = 1
    }
  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    local sprite = self.sprite
    -- Check in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[floor(self.image_index)]
    local worldShader = love.graphics.getShader()

    if shdrs.missileCustomShader and session.save.customMissileAvailable and session.save.customMissileEnabled then
      local secondaryR = 0.65 + session.save.missileR * 0.35
      local secondaryG = 0.65 + session.save.missileG * 0.35
      local secondaryB = 0.65 + session.save.missileB * 0.35
      shdrs.missileCustomShader:send(
        "rgb",
        session.save.missileR,
        session.save.missileG,
        session.save.missileB,
        secondaryR, secondaryG, secondaryB,
        1
      ) -- send one extra value to offset bug
      self.myShader = shdrs.missileCustomShader
    else
      if self.poweredUp then self.myShader = shdrs["itemBlueShader"] end
    end

    if shdrs.missileCustomShader and self.rgba then
      local r = 1 - self.rgba.r
      local g = 1 - self.rgba.g
      local b = 1 - self.rgba.b
      local secondaryR = 0.65 + r * 0.35
      local secondaryG = 0.65 + g * 0.35
      local secondaryB = 0.65 + b * 0.35
      shdrs.missileCustomShader:send(
        "rgb",
        r,
        g,
        b,
        secondaryR, secondaryG, secondaryB,
        1
      ) -- send one extra value to offset bug
      self.myShader = shdrs.missileCustomShader
    end

    love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, x, y, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)

    if self.deflected and self.sprite == im.sprites['Inventory/missile/animation'] then
      local outlineSprite = self.outlineSprite
      love.graphics.draw(
      outlineSprite.img, outlineSprite[math.floor(outlineSprite.frames * (self.image_index / (sprite.frames)))], x, y, 0,
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
    if other.immasword then
      Missile.getDeflected(self, cr, other)
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
  end,

  delete = function(self)
    if not self.pastMslLim then
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
