local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local o = require "GameObjects.objects"
local ps = require "physics_settings"
local bspl = require "GameObjects.Items.bombsplosion"
local shdrs = require "Shaders.shaders"
local counter = require "counter"
local utilities = require "utilities"
local u = require "utilities"
local chnr = require "GameObjects.Items.chainReaction"

local thr = require "GameObjects.Items.thrown"

local function destroyself(self)
  if not self.destroyedself then
    self.destroyedself = true
    o.removeFromWorld(self)
    if self.shadow then o.removeFromWorld(self.shadow) end
    self.shadow = nil
    self.creator.liftedOb = nil
    if self.iAmBomb then
      self.creator.triggers.bomb = true
      if self.persistentData.charged then
        local newChnr = chnr:new{
          x = self.x, y = self.y, layer = self.layer,
          dustAccident = u.ternaryOp(self.dustBomb, true, false)
        }
        o.addToWorld(newChnr)
      else
        local newBspl = bspl:new{
          x = self.x, y = self.y, layer = self.layer,
          dustAccident = u.ternaryOp(self.dustBomb, true, false)
        }
        o.addToWorld(newBspl)
      end
    end
  end
end


local floor = math.floor

-- for todown
local tdendOffset = {x = 0, y = -0.6 * ps.shapes.plshapeHeight}
local tdoffsets = {
  down = {
    {x = 0, y = 2 * ps.shapes.plshapeHeight},
    {x = 0, y = 1.7 * ps.shapes.plshapeHeight},
    {x = 0, y = 1.3 * ps.shapes.plshapeHeight},
    tdendOffset
  },
  right = {
    {x = 1.2 * ps.shapes.plshapeWidth, y = ps.shapes.plshapeHeight},
    {x = 0.75 * ps.shapes.plshapeWidth, y = 0.2 * ps.shapes.plshapeHeight},
    {x = 0.2 * ps.shapes.plshapeWidth, y = -0.1 * ps.shapes.plshapeHeight},
    tdendOffset
  },
  left = {
    {x = -1.2 * ps.shapes.plshapeWidth, y = ps.shapes.plshapeHeight},
    {x = -0.75 * ps.shapes.plshapeWidth, y = 0.2 * ps.shapes.plshapeHeight},
    {x = -0.2 * ps.shapes.plshapeWidth, y = -0.1 * ps.shapes.plshapeHeight},
    tdendOffset
  },
  up = {
    {x = 0, y = 0},
    {x = 0, y = -0.1 * ps.shapes.plshapeHeight},
    {x = 0, y = -0.3 * ps.shapes.plshapeHeight},
    tdendOffset
  }
}

-- For side scrolling
local ssendOffset = {x = 0, y = -0.8 * ps.shapes.plshapeHeight}
local ssoffsets = {
  down = {
    {x = 0, y = 2 * ps.shapes.plshapeHeight},
    {x = 0, y = 1.7 * ps.shapes.plshapeHeight},
    {x = 0, y = 1.3 * ps.shapes.plshapeHeight},
    ssendOffset
  },
  right = {
    {x = 1.2 * ps.shapes.plshapeWidth, y = ps.shapes.plshapeHeight},
    {x = 0.75 * ps.shapes.plshapeWidth, y = 0.2 * ps.shapes.plshapeHeight},
    {x = 0.2 * ps.shapes.plshapeWidth, y = -0.1 * ps.shapes.plshapeHeight},
    ssendOffset
  },
  left = {
    {x = -1.2 * ps.shapes.plshapeWidth, y = ps.shapes.plshapeHeight},
    {x = -0.75 * ps.shapes.plshapeWidth, y = 0.2 * ps.shapes.plshapeHeight},
    {x = -0.2 * ps.shapes.plshapeWidth, y = -0.1 * ps.shapes.plshapeHeight},
    ssendOffset
  },
  up = {
    {x = 0, y = 0},
    {x = 0, y = -0.1 * ps.shapes.plshapeHeight},
    {x = 0, y = -0.3 * ps.shapes.plshapeHeight},
    ssendOffset
  }
}

local function getOffsets()
  return game.room.sideScrolling and ssoffsets or tdoffsets
end

local Lifted = {}

function Lifted.initialize(instance)
  instance.transPersistent = true
  instance.seeThrough = true
  instance.persistentData = instance.persistentData or {}
end

Lifted.functions = {
  load = function (self)
    local cr = self.creator
    -- Set initial position
    local creatorx, creatory = cr.body:getPosition()
    local offsets = getOffsets()
    local offs = offsets[self.side][#offsets[self.side]-1]
    local xoff, yoff = offs.x, offs.y
    local fy = 0
    if cr.edgeFall and cr.edgeFall.step2 then
      fy = - cr.edgeFall.height
    end
    local x, y = creatorx + xoff, creatory + yoff - cr.height + cr.zo + fy

    self.x, self.y = x, y
    self.vibrPhase = 0
    self.startingTimer = self.timer
    if session.save.dinsPower and self.iAmBomb then self.myShader = shdrs["bombRedShader"] end

    self.sparkCounter = counter.new(.1)
  end,

  update = function (self, dt)
    local cr = self.creator

    if self.persistentData.charged and self.sparkCounter:update(dt) then
      local dx, dy = utilities.randomPointFromEllipse(self.sprite.width, self.sprite.height)
      session.particles:addColouredSpark{x = self.x + dx, y = self.y + dy}
    end

    -- Determine offset due to falling
    local fy = 0
    if cr.edgeFall and cr.edgeFall.step2 then
      fy = - cr.edgeFall.height
    end
    local xoff, yoff

    -- Determine offset due to lifting stage
    local offsets = getOffsets()
    if not self.lifted then
      local stage = floor(cr.liftingStage or 1)
      local offs = offsets[self.side][stage]
      xoff, yoff = offs.x, offs.y
      if stage == 4 then
        o.change_layer(self, cr.layer+1)
        self.lifted = true
      end
    else
      local offs = offsets[self.side][4]
      xoff, yoff = offs.x, offs.y
      -- Bobbing
      local cr_frame = floor(cr.image_index)
      self.angle = 0

      if (cr_frame + 1) % 5 == 0 then
        yoff = yoff + 1
      elseif (cr_frame + 2) % 5 == 0 then
        yoff = yoff - 3
      elseif (cr_frame + 3) % 5 == 0 then
        yoff = yoff - 4
      elseif (cr_frame + 4) % 5 == 0 then
        yoff = yoff - 3
      elseif (cr_frame) % 5 == 0 then
        yoff = yoff
      end

      -- For swaying
      -- local vert = self.side == "up" or self.side == "down"
      -- if cr_frame == 0 then
      --   yoff = yoff - 1
      --   if vert then
      --     self.angle = 0.1
      --     xoff = xoff + 1
      --     yoff = yoff + 0.5
      --   end
      -- elseif cr_frame == 1 then
      --   yoff = yoff - 3
      --   if vert then
      --     self.angle = 0.1
      --     xoff = xoff + 1
      --     yoff = yoff + 0.5
      --   end
      -- elseif cr_frame == 2 then
      --   yoff = yoff - 3
      -- elseif cr_frame == 3 then
      --   yoff = yoff - 2
      -- elseif cr_frame == 5 then
      --   yoff = yoff - 1
      --   if vert then
      --     self.angle = - 0.1
      --     xoff = xoff - 1
      --     yoff = yoff + 0.5
      --   end
      -- elseif cr_frame == 6 then
      --   yoff = yoff - 3
      --   if vert then
      --     self.angle = - 0.1
      --     xoff = xoff - 1
      --     yoff = yoff + 0.5
      --   end
      -- elseif cr_frame == 7 then
      --   yoff = yoff - 3
      -- elseif cr_frame == 8 then
      --   yoff = yoff - 2
      -- end
    end
    local crheight = cr.height

    -- Fix subpixel inaccuracies
    yoff = math.floor(yoff) + 0.5
    crheight = math.abs(crheight)

    -- Set position
    local creatorx, creatory = cr.body:getPosition()
    local x, y = creatorx + xoff, creatory + yoff - crheight + cr.zo + fy

    self.x, self.y = x, y

    -- life timer (for bombs)
    if self.timer then
      if self.timer < 0 then
        destroyself(self)
      end
      local vibrSpeedMod = 15 / (2 * self.timer / self.startingTimer - 0.25)
      if vibrSpeedMod < 0 or vibrSpeedMod > 50 then vibrSpeedMod = 50 end
      self.vibrPhase = self.vibrPhase + dt * vibrSpeedMod
      self.xvscale = math.sin(self.vibrPhase) * 0.1
      self.yvscale = math.cos(self.vibrPhase) * 0.1
      self.timer = self.timer - dt
    end

    -- lift_update is a function fed by what I was before I was lifted
    if self.lift_update then self.lift_update(self, dt) end

    if self.image_speed then
      self.image_index = (self.image_index + delta_time*60*self.image_speed)
      local frames = self.sprite.frames
      while self.image_index >= frames do
        self.image_index = self.image_index - frames
        -- if frames > 1 then trig.animation_end = true end
      end
    end
  end,

  draw = function (self, td)
    local x, y = self.x, self.y

    if td then
      x = x + trans.xtransform + game.transitioning.xmod - game.transitioning.progress * trans.xadjust
      y = y + trans.ytransform + game.transitioning.ymod - game.transitioning.progress * trans.yadjust
    end

    local sprite = self.sprite
    local frames = sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
      -- if frames > 1 then trig.animation_end = true end
    end
    local frame = sprite[math.floor(self.image_index)]
    local worldShader = love.graphics.getShader()

    if not self.persistentData.noshdr then
      love.graphics.setShader(self.inheritedShader or self.myShader)
    end
    if self.creator and not self.creator.invisible then
      love.graphics.draw(
      sprite.img, frame, x, y, self.angle,
      sprite.res_x_scale + (self.xvscale or 0), sprite.res_y_scale + (self.yvscale or 0),
      sprite.cx, sprite.cy)
    end

    love.graphics.setShader(worldShader)
  end,

  trans_draw = function (self)
    self:draw(true)
  end,

  get_thrown = function (self)

    local cr = self.creator
    local vx, vy
    local side = self.side
    local prevx, prevy = cr.body:getLinearVelocity()
    prevx, prevy = 1.5 * prevx, 1.5 * prevy
    local power

    if session.save.dinsPower and cr:holdingDirectionalKey() then
      power = 250
    else
      power = 100
    end
    if side == "up" then
      vx, vy = prevx, prevy - power
    elseif side == "left" then
      vx, vy = prevx - power, prevy
    elseif side == "down" then
      vx, vy = prevx, prevy + power
    else
      vx, vy = prevx + power, prevy
    end

    local thrownOb = thr:new{
      x = self.x, y = self.y,
      vx = vx, vy = vy,
      sprite_info = self.sprite_info,
      image_index = floor(self.image_index),
      image_speed = self.image_speed,
      layer = cr.layer + 1,
      throw_update = self.throw_update,
      throw_collision = self.throw_collision,
      explosionNumber = self.explosionNumber,
      explosionSprite = self.explosionSprite,
      explosionSpeed = self.explosionSpeed,
      explosionSound = self.explosionSound,
      myDrops = self.myDrops,
      persistentData = self.persistentData,
      iAmBomb = self.iAmBomb,
      timer = self.timer,
      vibrPhase = self.vibrPhase,
      dustBomb = self.dustBomb,
      startingTimer = self.startingTimer,
      inheritedShader = self.inheritedShader
    }
    o.addToWorld(thrownOb)

  end
}

function Lifted:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Lifted, instance, init) -- add own functions and fields
  return instance
end

return Lifted
