local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local sht = require "GameObjects.enemies.shooters.shooterTemplate"
local td = require "movement"; td = td.top_down
local sm = require "state_machine"
local u = require "utilities"
local snd = require "sound"

local redRockBug = {}

function redRockBug.initialize(instance)
  instance.sprite_info = im.spriteSettings.redRockBug
  instance.spritePathNoFacing = "Enemies/RedRockBug/walk_"
  instance.hp = 3
  instance.physical_properties.shape = ps.shapes.circleThreeFourths
  instance.attackDmg = 1
  instance.bulletDmg = 1.5
  -- instance.shootStill = 0.3
  -- instance.shootRandomly = true
  -- instance.inBetweenShotDurations = {
  --   {weight = 2, value = 2},
  --   {weight = 3, value = 3},
  --   {weight = 4, value = 4},
  --   {weight = 5, value = 7},
  -- }
  instance.targetPlayer = true
  instance.cooldown = 1
  instance.walkAndStop = true
  instance.walkingImage_speed = 0.1
  instance.walkDurations = {
    {weight = 10, value = 1},
    {weight = 20, value = 2},
    {weight = 20, value = 3},
    {weight = 2, value = 6},
  }
  instance.stillDurations = {
    {weight = 10, value = 1},
    {weight = 20, value = 2},
    {weight = 20, value = 3},
    {weight = 2, value = 6},
  }
  instance.bulletProps = {
    enemRock = true,
    sprite_info = im.spriteSettings.bullet
  }
  instance.shootSound = snd.load_sound{"Effects/Oracle_Link_Throw"}
end

redRockBug.functions = {}

function redRockBug:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(sht, instance) -- add parent functions and fields
  p.new(redRockBug, instance, init) -- add own functions and fields
  return instance
end

return redRockBug
