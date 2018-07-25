local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"

local Sword = {}

local floor = math.floor
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

function Sword.initialize(instance)
  instance.iox = 0
  instance.ioy = 0
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_speed = 0
  instance.triggers = {}
  instance.sprite_info = {
    {'Inventory/UseSwordL1', 3, padding = 2, width = 16, height = 15},
    spritefixture_properties = {
      shape = ps.shapes.swordSprite
    }
  }
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0
  }
  instance.creator = nil -- Object that swings me
  instance.side = nil -- down, right, left, up
end

Sword.functions = {

  -- This could also be a func called swing to be used in *swing animstate like so:
  -- -- Swing sword
  -- if instance.sword.exists then instance.sword:swing(dt) end
  -- Pros: no lag (player image_index can be fixed in early update. Position can't)
  -- Cons: One frame that the spritefixture hasen't determined yet who's front
  --       and who's back.
  early_update = function(self, dt)
    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      o.removeFromWorld(self)
    end

    -- Calculate sprite_index
    local frames = self.sprite.frames
    local phase = floor(cr.image_index * frames / cr.sprite.frames)
    local prevphase = self.previous_image_index
    self.image_index = phase

    -- Calculate offset due to sword swinging
    local sox, soy, angle = calculate_offset(self.side, phase)
    local creatorx, creatory = cr.body:getPosition()

    if phase ~= prevphase then
      if phase == 0 then
        if self.fixture then
          self.fixture:destroy()
        end
        self.fixture = love.physics.newFixture(self.body, ps.shapes.swordIgniting)
        self.fixture:setSensor(true)
      elseif phase == 1 then
        if self.fixture then
          self.fixture:destroy()
        end
        self.fixture = love.physics.newFixture(self.body, ps.shapes.swordSwing)
        self.fixture:setSensor(true)
      elseif phase == 2 then
        if self.fixture then
          self.fixture:destroy()
        end
        self.fixture = love.physics.newFixture(self.body, ps.shapes.swordStill)
        self.fixture:setSensor(true)
      end
    end

    -- Determine offset due to wielder's offset
    local wox, woy = cr.iox, cr.ioy

    -- Set position and angle
    self.body:setPosition(creatorx + sox + wox, creatory + soy + woy)
    self.body:setAngle(angle)
    self.angle = angle

    o.change_layer(self, cr.layer)
    self.previous_image_index = phase
  end,

  draw = function(self)
    local x, y = self.body:getPosition()
    self.x, self.y = x, y
    local sprite = self.sprite
    -- Check in case animation changed to something with fewer frames
    while self.image_index >= sprite.frames do
      self.image_index = self.image_index - sprite.frames
    end
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, x, y, self.angle,
    sprite.res_x_scale*self.x_scale, sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    -- love.graphics.polygon("line",
    -- self.body:getWorldPoints(self.spritefixture:getShape():getPoints()))
    if self.image_index ~= 1 then
      love.graphics.polygon("line",
      self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    else
      local cshx, cshy = self.body:getPosition()
      love.graphics.circle("line",
        cshx, cshy,
        self.fixture:getShape():getRadius())
    end
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    local cr = self.creator
    -- Check if I have to be destroyed
    if not cr then
      return
    end

    -- Find which fixture belongs to whom
    local myF
    local otherF
    if self == aob then
      myF = a
      otherF = b
      other = bob
    else
      myF = b
      otherF = a
      other = aob
    end

    if other.pushback and not self.hitWall then
      cr.body:applyLinearImpulse(0, -200)
      self.hitWall = true
    end
  end
}

function Sword:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Sword, instance, init) -- add own functions and fields
  return instance
end

return Sword
