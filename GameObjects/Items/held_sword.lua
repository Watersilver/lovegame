local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local im = require "image"
local shdrs = require "Shaders.shaders"
local lighting = require "ScreenEffects.lighting.lighting"
local utilities= require "utilities"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local HeldSword = {}

local floor = math.floor
local pi = math.pi

--  Calculate HeldSword position and angle offset due to creator's side
local function calculate_offset(side)
  local xoff, yoff, aoff = 0, 0, 0
  if side == "down" then
    xoff = 3
    yoff = 13
    aoff = pi
  elseif side == "right" then
    xoff = 11
    yoff = 4
    aoff = pi * 0.5
  elseif side == "left" then
    xoff = - 11
    yoff = 4
    aoff = - pi * 0.5
  elseif side == "up" then
    xoff = - 4
    yoff = - 11
    aoff = 0
  end
  return xoff, yoff, aoff
end

local function drawLight(x, y, r, a, t, lr)
  lighting.applyLight{
    x = x, y = y,
    type = 'dynamic',
    rgba = {r=1,g=1,b=1,a=1},
    dynamic_options = {radius = lr * (r + a * math.sin(t))},
  }
  lighting.applyLight{
    x = x, y = y,
    type = 'dynamic',
    rgba = {r=1,g=1,b=1,a=0.5},
    dynamic_options = {radius = lr * (2 * r + 2 * a * math.sin(t))},
  }
end

function HeldSword.initialize(instance)

  instance.transPersistent = true
  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.image_index = 2
  instance.triggers = {}
  instance.sprite_info = im.spriteSettings.playerSword
  instance.spritefixture_properties = {shape = ps.shapes.swordSprite}
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    sensor = true,
    density = 0,
    shape = ps.shapes.swordHeld,
    categories = {PLAYERATTACKCAT},
    -- masks = {FLOORCAT}
  }
  instance.creator = nil -- Object that swings me
  instance.side = nil -- down, right, left, up
  instance.seeThrough = true
  instance.minZo = - ps.shapes.plshapeHeight * 0.9
  if shdrs.swordCustomShader and session.save.customSwordAvailable and session.save.customSwordEnabled then
    local secondaryR = 0.65 + session.save.swordR * 0.35
    local secondaryG = 0.65 + session.save.swordG * 0.35
    local secondaryB = 0.65 + session.save.swordB * 0.35
    shdrs.swordCustomShader:send("rgb",
    session.save.swordR,
    session.save.swordG,
    session.save.swordB,
    secondaryR, secondaryG, secondaryB,
    1) -- send one extra value to offset bug
    instance.myShader = shdrs.swordCustomShader
  else
    -- if session.save.dinsPower then instance.myShader = shdrs["itemRedShader"] end
    if session.save.dinsPower then instance.myShader = shdrs.swordHeldShader end
  end
  instance.chargedShader = shdrs.swordChargeShader
  instance.chargedShaderFreq = 1 / 5
  instance.chargedShaderPhase = instance.chargedShaderFreq
  instance.chargedRGB = {0,0,0,0,0,0}

  instance.lightTimers = {}
  instance.lightReadiness = 0

  -- Noise
  instance.noiseData = love.image.newImageData(40, 38)
  instance.noiseImg = love.graphics.newImage(instance.noiseData)
  instance.noiseT = 0
  instance.noiseX, instance.noiseY = -love.math.random() * 100000, -love.math.random() * 100000
  instance.noiseOpacityT = 0
  instance.noiseOpacityX, instance.noiseOpacityY = -love.math.random() * 100000, -love.math.random() * 100000
end

HeldSword.functions = {

  updateNoise = function(self, opacity, dt)

    self.noiseT = self.noiseT + dt * 2
    local nx, ny = self.noiseX, self.noiseY
    local nt = self.noiseT

    self.noiseOpacityT = self.noiseOpacityT + dt * 2
    local nopx, nopy = self.noiseOpacityX, self.noiseOpacityY
    local nopt = self.noiseOpacityT

    self.noiseData:mapPixel(
      function(x, y)
        local val = love.math.noise(nx + x, ny + y, nt)
        local op = love.math.noise(nopx + x, nopy + y, nopt)

        val = val - 0.3
        -- val = val / 0.5
        val = utilities.clamp(0, val, 1)

        -- if we have a different noise for each colour we get interesting rgb effect
        return val, val, op, opacity
      end
    )

    -- v1 Removed Image:getData and Image:refresh, use Image:replacePixels instead
    self.noiseImg:replacePixels(self.noiseData)
  end,

  load = function(self)
    self.image_speed = 0.1
    self.sprite = im.sprites['Inventory/sword/held_start']
  end,

  unstoppable_update = function(self)
    local cr = self.creator
    if not cr then return end
    local x, y = self.body:getPosition()
    y = y + (cr.fake_zo or 0)

    local lt = self.lightTimers
    if #lt < 5 then
      for i = 1,5 do
        lt[i] = math.pi * 2 * love.math.random()
      end
    end

    local dir = 0
    if self.side == "up" then
      dir = math.pi / 2
    elseif self.side == "down" then
      dir = 3 * math.pi / 2
    elseif self.side == "left" then
      dir = math.pi
    end

    local lr = self.lightReadiness

    drawLight(x,y,3,2,lt[1], lr)
    local xoff, yoff = utilities.polarToCartesian(3, dir)
    drawLight(x + xoff,y + yoff,3,2,lt[2], lr)
    xoff, yoff = utilities.polarToCartesian(-3, dir)
    drawLight(x + xoff,y + yoff,3,2,lt[3], lr)
    xoff, yoff = utilities.polarToCartesian(5, dir)
    drawLight(x + xoff,y + yoff,3,2,lt[4], lr)
    xoff, yoff = utilities.polarToCartesian(-5, dir)
    drawLight(x + xoff,y + yoff,3,2,lt[5], lr)
  end,

  -- This could also be a func called swing to be used in *swing animstate like so:
  -- -- Swing HeldSword
  -- if instance.HeldSword.exists then instance.HeldSword:swing(dt) end
  -- Pros: no lag (player image_index can be fixed in early update. Position can't)
  -- Cons: One frame that the spritefixture hasen't determined yet who's front
  --       and who's back.
  early_update = function(self, dt)
    local lt = self.lightTimers
    if #lt < 5 then
      for i = 1,5 do
        lt[i] = math.pi * 2 * love.math.random()
      end
    end
    for i, t in ipairs(lt) do
      lt[i] = t + delta_time * (0.1 * love.math.random() + 1)
      while lt[i] >= math.pi * 2 do
        lt[i] = lt[i] - math.pi * 2
      end
    end
    self.lightReadiness = self.lightReadiness + dt * 0.5
    if self.lightReadiness > 1 then self.lightReadiness = 1 end

    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      o.removeFromWorld(self)
      return
    end
    if self.weld and (not self.weld:isDestroyed()) then self.weld:destroy() end

    -- Calculate offset due to HeldSword swinging
    local sox, soy, angle = calculate_offset(self.side)
    local creatorx, creatory = cr.body:getPosition()

    -- Determine offset due to falling
    local fy = 0
    if cr.edgeFall and cr.edgeFall.step2 then
      fy = - cr.edgeFall.height
    end

    -- Set position and physical angle
    self.body:setPosition(creatorx + sox, creatory + soy + cr.zo + fy)
    self.body:setAngle(angle)

    -- Drawing angle
    self.angle = angle

    -- Weld
    self.weld = love.physics.newWeldJoint(cr.body, self.body, creatorx + sox, creatory + soy + cr.zo, true)

    -- Check if I'm on the air
    if cr.zo ~= 0 then
      self.onAir = true
      self.zo = cr.zo + self.minZo
    else
      self.onAir = false
      self.zo = self.minZo
    end

    if self.onAir then
      self.fixture:setCategory(PLAYERJUMPATTACKCAT)
    else
      self.fixture:setCategory(PLAYERATTACKCAT)
    end

    o.change_layer(self, cr.layer)

    self.x_scale = 1
    if self.side == "right" then
      self.x_scale = -1
    end

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

    if self.animation_end and not self.isLooping then
      self.sprite = im.sprites['Inventory/sword/held']
      self.image_speed = 0.8
      self.isLooping = true
    end

    -- shader and effects
    local opacity = 1
    if not self.isLooping then
      opacity = self.image_index / self.sprite.frames
    end
    self:updateNoise(opacity, dt)
    shdrs.swordHeldShader:send('noise', self.noiseImg)
    shdrs.swordHeldShader:send('frames', self.sprite.frames)
    shdrs.swordHeldShader:send('rgb', self.sprite.frames)

    local r = 0.94
    local g = 0
    local b = 1
    local secondaryR = 0.975
    local secondaryG = 0.65
    local secondaryB = 1

    if cr.spinCharged then
      -- relative luminance: 0.2126 * R + 0.7152 * G + 0.0722 * B
      self.chargedShaderPhase = self.chargedShaderPhase + dt
      if self.chargedShaderPhase > self.chargedShaderFreq then
        self.chargedShaderPhase = self.chargedShaderPhase - self.chargedShaderFreq
        while self.chargedShaderPhase > self.chargedShaderFreq do
          self.chargedShaderPhase = self.chargedShaderPhase - self.chargedShaderFreq
        end
        local randHue = love.math.random()
        local c = self.chargedRGB
        c[1], c[2], c[3] = HSL(randHue, 1, 0.5, 1)
        c[4], c[5], c[6] = HSL(randHue, 1, 0.75, 1)
      end
      r = self.chargedRGB[1]
      g = self.chargedRGB[2]
      b = self.chargedRGB[3]
      secondaryR = self.chargedRGB[4]
      secondaryG = self.chargedRGB[5]
      secondaryB = self.chargedRGB[6]
    elseif shdrs.swordCustomShader and session.save.customSwordAvailable and session.save.customSwordEnabled then
      r = session.save.swordR
      g = session.save.swordG
      b = session.save.swordB
      secondaryR = 0.65 + session.save.swordR * 0.35
      secondaryG = 0.65 + session.save.swordG * 0.35
      secondaryB = 0.65 + session.save.swordB * 0.35
    elseif session.save.dinsPower then
      r = 1
      g = 0
      b = 0
      secondaryR = 1
      secondaryG = 0.65
      secondaryB = 0.65
    end

    shdrs.swordHeldShader:send("rgb",
    r, g, b,
    secondaryR, secondaryG, secondaryB,
    1) -- send one extra value to offset bug
    self.currentShader = shdrs.swordHeldShader
  end,

  draw = function(self, td)
    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      return
    end

    local x, y = self.body:getPosition()
    y = y + (cr.fake_zo or 0)

    if self.spritejoint then
      self.spritejoint:destroy()
      if not self.spritejoint:isDestroyed() then self.spritejoint:destroy() end
      self.spritejoint = nil
    end

    if td then
      x = x + trans.xtransform + game.transitioning.xmod - game.transitioning.progress * trans.xadjust
      y = y + trans.ytransform + game.transitioning.ymod - game.transitioning.progress * trans.yadjust
    else
      self.spritebody:setPosition(x, y)
      self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)
    end

    self.x, self.y = x, y
    local sprite = self.sprite
    -- Check in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[math.floor(self.image_index)]
    local worldShader = love.graphics.getShader()
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setShader(self.currentShader)
    love.graphics.draw(
    sprite.img, frame, x, y, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setShader(worldShader)
    love.graphics.setColor(pr, pg, pb, pa)

    -- love.graphics.draw(self.noiseImg, x, y)

    -- Debug
    -- love.graphics.polygon("line",
    -- self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
    -- love.graphics.polygon("line",
    -- self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end,

  trans_draw = function(self)
    self:draw(true)
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      return
    end

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is grass, do nothing
    if other.grass then return end

    -- If other is attackDodger, do nothing
    if other.attackDodger then return end

    -- If below edge, treat as wall
    if other.edge then
      if not ec.swordBelowEdge(other, cr) then return end
    elseif other.dungeonEdge then
      if not ec.belowDungeonEdge(other, cr) then return end
    end

    -- This will destroy held sword and create a sword that is stabbing
    cr.triggers.stab = true

  end
}

function HeldSword:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(HeldSword, instance, init) -- add own functions and fields
  return instance
end

return HeldSword
