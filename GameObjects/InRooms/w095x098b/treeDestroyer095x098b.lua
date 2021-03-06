local p = require "GameObjects.prototype"
local parent = require "GameObjects.objDestrOnMissilleContact"

local dc = require "GameObjects.Helpers.determine_colliders"

local PC = {}

function PC.initialize(instance)
  instance.saveNote = "td095x099" -- Provide to only happen once
  instance.objDestLayer = 13 -- change in init if you want
  instance.soundEffect = "Oracle_Bush_Cut" -- change in init if you want
  instance.graphicEffect = "bushDestruction" -- change in init if you want
  instance.fanfareWaitTime = 1
end

PC.functions = {}

function PC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(parent, instance) -- add parent functions and fields
  p.new(PC, instance, init) -- add own functions and fields
  return instance
end

return PC
