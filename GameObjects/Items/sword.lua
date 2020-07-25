local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local expl = require "GameObjects.explode"

local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"

local Sword = {}

local floor = math.floor
local clamp = u.clamp
local pi = math.pi

--  Calculate sword position and angle offset due to creator's side
local function calculate_offset(side, phase)
  local xoff, yoff, aoff = 0, 0, 0
  if side == "down" then
    if phase == 0 then
      xoff = - 12
      yoff = 4
      aoff = pi * 1.5
    elseif phase == 1 then
      xoff = - 9
      yoff = 14
      aoff = pi
    elseif phase == 2 then
      xoff = 3
      yoff = 15
      aoff = pi
    end
  elseif side == "right" then
    if phase == 0 then
      xoff = 0
      yoff = - 12
      aoff = 0
    elseif phase == 1 then
      xoff = 11
      yoff = - 10
      aoff = 0
    elseif phase == 2 then
      xoff = 14
      yoff = 4
      aoff = pi * 0.5
    end
  elseif side == "left" then
    if phase == 0 then
      xoff = 0
      yoff = - 12
      aoff = 0
    elseif phase == 1 then
      xoff = - 10
      yoff = - 11
      aoff = pi * 1.5
    elseif phase == 2 then
      xoff = - 14
      yoff = 4
      aoff = - pi * 0.5
    end
  elseif side == "up" then
    if phase == 0 then
      xoff = 14
      yoff = - 1
      aoff = pi * 0.5
    elseif phase == 1 then
      xoff = 11
      yoff = - 12
      aoff = 0
    elseif phase == 2 then
      xoff = - 4
      yoff = - 15
      aoff = 0
    end
  end
  return xoff, yoff, aoff
end

-- Position for spin attack
local spinPosition = {
  {xoff = 11, yoff = - 10, aoff = 0},
  {xoff = 9, yoff = 14, aoff = pi * 0.5},
  {xoff = - 9, yoff = 14, aoff = pi},
  {xoff = - 10, yoff = - 11, aoff = pi * 1.5},

  -- {xoff = 17, yoff = 4.5, aoff = pi * 0.25}, -- left
  -- {xoff = -17, yoff = 3.5, aoff = pi * 1.25}, -- right
  -- {xoff = 0, yoff = -15, aoff = pi * 1.75}, -- up
  -- {xoff = 0, yoff = 15, aoff = pi * 0.75}, -- down
}

local spinPosition2 = {
  {xoff = 17, yoff = 4.5, aoff = pi * 0.25}, -- left
  {xoff = -17, yoff = 3.5, aoff = pi * 1.25}, -- right
  {xoff = 0, yoff = -15, aoff = pi * 1.75}, -- up
  {xoff = 0, yoff = 15, aoff = pi * 0.75}, -- down
}

-- sword hit spark position offset table
local shso1 = 12
local shso2 = 11
local shso3 = 20
local shspot = {
  down = {
    [0] = {xoff = -shso1, yoff = 0},
    -- [1] = {xoff = -shso2, yoff = shso2},
    [1] = {xoff = 0, yoff = shso3},
    [2] = {xoff = 0, yoff = shso3}
  },
  right = {
    [0] = {xoff = 0, yoff = -shso1},
    -- [1] = {xoff = shso2, yoff = -shso2},
    [1] = {xoff = shso3, yoff = 0},
    [2] = {xoff = shso3, yoff = 0}
  },
  left = {
    [0] = {xoff = 0, yoff = -shso1},
    -- [1] = {xoff = -shso2, yoff = -shso2},
    [1] = {xoff = -shso3, yoff = 0},
    [2] = {xoff = -shso3, yoff = 0}
  },
  up = {
    [0] = {xoff = shso1, yoff = 0},
    -- [1] = {xoff = shso2, yoff = shso2},
    [1] = {xoff = 0, yoff = -shso3},
    [2] = {xoff = 0, yoff = -shso3}
  }
}

function Sword.initialize(instance)

  instance.transPersistent = true
  instance.sword = true
  instance.immasword = true
  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.triggers = {}
  instance.sprite_info = {im.spriteSettings.playerSword}
  instance.spritefixture_properties = {shape = ps.shapes.swordSprite}
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    -- DONT SET MASKS HERE BECAUSE IT HAS NO INITIAL SHAPE,
    -- SO NO INITIAL FIXTURE. SET IN UPDATE
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
  elseif session.save.dinsPower then
    instance.myShader = shdrs["itemRedShader"]
  end
end

Sword.functions = {
  load = function (self)
    if self.spin then
      self.fixture = love.physics.newFixture(self.body, ps.shapes.swordSwingWide, 0)
      self.fixture:setMask(SPRITECAT)
      self.spinFreq = 1 / 60
      self.spinPhase = self.spinFreq
      self.spanPositionKeys = {} -- table to avoid same position
    end
  end,

  -- This could also be a func called swing to be used in *swing animstate like so:
  -- -- Swing sword
  -- if instance.sword.exists then instance.sword:swing(dt) end
  -- Pros: no lag (player image_index can be fixed in early update. Position can't)
  -- Cons: One frame that the spritefixture hasen't determined yet who's front
  --       and who's back.
  early_update = function(self, dt)
    local cr = self.creator
    -- Check if I have to be destroyed
    if (not cr) then
      o.removeFromWorld(self)
    end

    -- Check if I'm on the air
    if cr.zo ~= 0 then
      self.onAir = true
      self.zo = cr.zo + self.minZo
    else
      self.onAir = false
      self.zo = self.minZo
    end

    if self.weld and (not self.weld:isDestroyed()) then self.weld:destroy() end

    -- Calculate sprite_index
    local phase
    if not self.stab then
      phase = floor(cr.image_index * self.sprite.frames / cr.sprite.frames)
      self.image_index = phase
    else
      self.image_index = 2
      phase = self.image_index
    end
    self.phase = phase
    local prevphase = self.previous_image_index

    -- -- Calculate offset due to sword swinging
    -- local sox, soy, angle = calculate_offset(self.side, phase)
    -- local creatorx, creatory = cr.body:getPosition()

    local sox, soy, angle

    -- Handle spin attack stuff
    if self.spin then
      if self.hitWall then
        if not self.hitWallAgainCounter then self.hitWallAgainCounter = 0 end
        self.hitWallAgainCounter = self.hitWallAgainCounter + dt
        if self.hitWallAgainCounter > 0.4 then
          self.hitWallAgainCounter = nil
          self.hitWall = false
        end
      end

      self.spinPhase = self.spinPhase + dt
      if self.spinPhase >= self.spinFreq then
        self.spinPhase = self.spinPhase - self.spinFreq
        local a = self.spanPositionKeys

        -- do the following if I want to use only spinPosition table
        -- works well with freq 1/30
        -- local spindex = u.chooseKeyFromTable(
        --   spinPosition,
        --   -- inelegant but I can't unpack
        --   a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]
        -- )
        -- if #a == #spinPosition - 1 then
        --   for i, v in ipairs(a) do
        --     a[i] = nil
        --   end
        -- end
        -- table.insert(a, spindex)
        -- self.sox, self.soy, self.angle =
        -- spinPosition[spindex].xoff, spinPosition[spindex].yoff, spinPosition[spindex].aoff

        -- do the following if I want to use both spinPosition tables
        -- works well with freq 1/60
        if not self.sp then self.sp = spinPosition end
        local spindex = u.chooseKeyFromTable(
          self.sp,
          -- inelegant but I can't unpack
          a[1], a[2], a[3], a[4]
          --a[5], a[6], a[7], a[8]
        )
        table.insert(a, spindex)
        self.sox, self.soy, self.angle =
        self.sp[spindex].xoff, self.sp[spindex].yoff, self.sp[spindex].aoff
        if #a == #self.sp then
          for i, v in ipairs(a) do
            a[i] = nil
          end
          if self.sp == spinPosition then
            self.sp = spinPosition2
          else
            self.sp = spinPosition
          end
        end
      end
      sox, soy, angle = self.sox, self.soy, self.angle
    else

      if phase ~= prevphase then

        if self.fixture then
          self.fixture:destroy()
        end
        if phase == 0 then
          self.fixture = love.physics.newFixture(self.body, ps.shapes.swordIgniting, 0)
        elseif phase == 1 then
          self.fixture = love.physics.newFixture(self.body, ps.shapes.swordSwingWide, 0)
        elseif phase == 2 then
          self.fixture = love.physics.newFixture(self.body, ps.shapes.swordStill, 0)
        end
        self.fixture:setMask(SPRITECAT)
        self.fixture:setSensor(true)

      end

      -- Calculate offset due to sword swinging
      sox, soy, angle = calculate_offset(self.side, phase)

    end

    if self.onAir then
      self.fixture:setCategory(PLAYERJUMPATTACKCAT)
    else
      self.fixture:setCategory(PLAYERATTACKCAT)
    end


    -- Determine offset due to wielder's offset
    local wox, woy = cr.iox, cr.ioy

    -- Determine offset due to falling
    local fy = 0
    if cr.edgeFall and cr.edgeFall.step2 then
      fy = - cr.edgeFall.height
    end

    -- Set position and angle
    local creatorx, creatory = cr.body:getPosition()
    local x, y = creatorx + sox + wox, creatory + soy + woy + cr.zo + fy
    self.body:setPosition(x, y)
    self.body:setAngle(angle)
    if not self.x then self.x, self.y = x, y end -- to avoid crashing because of nil

    if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end
    self.spritebody:setPosition(x, y)
    self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)


    -- Drawing angle
    self.angle = angle

    -- Weld
    self.weld = love.physics.newWeldJoint(cr.body, self.body, x, y, true)

    o.change_layer(self, cr.layer)
    self.previous_image_index = phase
  end,

  draw = function(self, td)
    local x, y = self.body:getPosition()

    if td then
      x = x + trans.xtransform + game.transitioning.xmod - game.transitioning.progress * trans.xadjust
      y = y + trans.ytransform + game.transitioning.ymod - game.transitioning.progress * trans.yadjust
    end

    self.x, self.y = x, y
    local sprite = self.sprite
    -- Check in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[self.image_index]
    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)
    if self.creator and not self.creator.invisible then
      love.graphics.draw(
      sprite.img, frame, x, y, self.angle,
      sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
      sprite.cx, sprite.cy)
    end
    love.graphics.setShader(worldShader)

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

    -- If other is grass, at most play a sound (implemented via grass explosion)
    if other.grass then return end

    local pushback = other.pushback

    -- If below edge, treat as wall
    if other.edge then
      if ec.swordBelowEdge(other, cr) then pushback = true else return end
    elseif other.dungeonEdge then
      pushback = ec.belowDungeonEdge(other, cr)
    end

    if (pushback) and not self.hitWall and not other.attackDodger then
      local lvx, lvy = cr.body:getLinearVelocity()
      local crmass = cr.body:getMass()
      local _, crbrakes = session.getAthlectics()
      crbrakes = clamp(0, crbrakes, cr.brakesLim)
      cr.body:applyLinearImpulse(-lvx * crmass, -lvy * crmass)
      local px, py
      if not self.spin then
        if self.side == "down" then
          px, py = 0, -10 * crmass * crbrakes
        elseif self.side == "right" then
          px, py = -10 * crmass * crbrakes, 0
        elseif self.side == "left" then
          px, py = 10 * crmass * crbrakes, 0
        elseif self.side == "up" then
          px, py = 0, 10 * crmass * crbrakes
        end
      else
        px, py = u.normalize2d(cr.x - self.x, cr.y - self.y)
        px, py = px * 22 * crmass * crbrakes, py * 22 * crmass * crbrakes
      end
      cr.body:applyLinearImpulse(px, py)
      self.hitWall = true
      if (other.static and not (other.breakableByUpgradedSword and session.save.dinsPower)) or other.forceSwordSound then
        local exoff, eyoff
        if self.spin then
          exoff, eyoff = u.polarToCartesian(15, self.angle - pi * 0.25 + (love.math.random() * pi * 0.25 - pi * 0.125))
        else
          local explOffset = shspot[self.side][self.phase]
          exoff, eyoff = explOffset.xoff, explOffset.yoff
        end
        local explOb = expl:new{
          x = cr.x + exoff, y = cr.y + cr.zo + eyoff,
          layer = self.layer,
          explosionNumber = self.explosionNumber or 1,
          explosion_sprite = self.hitWallSprite or im.spriteSettings.swordHitWall,
          image_speed = self.hitWallImageSpeed or 0.5,
          nosound = true
        }
        o.addToWorld(explOb)
        snd.play(cr.sounds.swordTap1)
      elseif other.shieldWall and other.shielded and not ((other.weakShield or other.mediumShield) and session.save.dinsPower) then
        local exoff, eyoff
        if self.spin then
          exoff, eyoff = u.polarToCartesian(15, self.angle - pi * 0.25 + (love.math.random() * pi * 0.25 - pi * 0.125))
        else
          local explOffset = shspot[self.side][self.phase]
          exoff, eyoff = explOffset.xoff, explOffset.yoff
        end
        local explOb = expl:new{
          x = cr.x + exoff, y = cr.y + cr.zo + eyoff,
          layer = self.layer,
          explosionNumber = self.explosionNumber or 1,
          explosion_sprite = self.hitWallSprite or im.spriteSettings.swordHitWall,
          image_speed = self.hitWallImageSpeed or 0.5,
          nosound = true
        }
        o.addToWorld(explOb)
        snd.play(cr.sounds.swordTap2)
      end
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    -- to avoid glitches, especially during spin attack
    -- it could make the player fall from
    -- an edge from the wrong side
    coll:setEnabled(false)
  end
}

function Sword:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Sword, instance, init) -- add own functions and fields
  return instance
end

return Sword
