local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local game = require "game"
local snd = require "sound"

local Intro = {}

function Intro.initialize(instance)
  instance.side = "right"
end

Intro.functions = {
  load = function()
    snd.play(glsounds.select)
  end,
}

function Intro:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Intro, instance, init) -- add own functions and fields
  return instance
end

return Intro
