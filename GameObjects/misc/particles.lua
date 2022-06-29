local p = require "GameObjects.prototype"
local u = require "utilities"

local Particles = {}

function Particles.initialize(instance)
  instance.simpleSparks = {}
  instance.age = 0
  instance.layer = 25
  instance.transPersistent = true
end

Particles.functions = {
  updateAge = function (self, dt)
    self.age = self.age + dt
    -- Set lifetime back to 0 if too high and ensure spark lifetime doesn't get ruined.
    -- Probably won't need to do that because too high are thousands of years apparently
  end,

  updateSimpleSparks = function (self, dt)
    local sparkInfo = nil
    local age = self.age
    local simpleSparks = self.simpleSparks
    for i = 1,#simpleSparks do
      -- delete sparks whose time is past
      while simpleSparks[i] ~= nil and age - simpleSparks[i].birth >= simpleSparks[i].lifespan do
        simpleSparks[i], simpleSparks[#simpleSparks] = simpleSparks[#simpleSparks], simpleSparks[i]
        table.remove(simpleSparks)
      end
      sparkInfo = simpleSparks[i]
      -- if sparkInfo has been deleted break
      if sparkInfo == nil then return end

      -- do the updating
      sparkInfo.y = sparkInfo.y - dt * 5
    end
  end,

  addSpark = function (self, sparkInfo)
    sparkInfo.birth = self.age
    sparkInfo.lifespan = sparkInfo.lifespan or 1
    table.insert(self.simpleSparks, sparkInfo)
  end,

  update = function (self, dt)
    self:updateAge(dt)
    self:updateSimpleSparks(dt)
  end,

  draw = function (self)
    for _, sparkInfo in ipairs(self.simpleSparks) do
      love.graphics.rectangle("fill", sparkInfo.x, sparkInfo.y, 1, 1);
    end
  end
}

function Particles:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Particles, instance, init) -- add own functions and fields
  return instance
end

return Particles
