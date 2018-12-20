local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"

local Wasp = {}

function Wasp.initialize(instance)
end

Wasp.functions = {}

function Wasp:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Wasp, instance, init) -- add own functions and fields
  return instance
end

return Wasp
