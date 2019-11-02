-- removes scaled sprite blurriness
love.graphics.setDefaultFilter("nearest")

local floor = math.floor

-- Will try to avoid gaps for adjacent tiles by making them slightly bigger
-- Set to nullify by setting to 0
local dw = 0.1
local dh = dw

local im = {}

-- For animated background
local giiSpeed = 3
local gii1234float = 0
local giiMax = 4
im.globimage_index1234 = gii1234float
local gii1213table = {1, 0, 2, [0] = 0}
im.globimage_index1213 = gii1213table[im.globimage_index1234]

function im.updateGlobalImageIndexes(dt)
  gii1234float = gii1234float + giiSpeed * dt
  while gii1234float >= giiMax do gii1234float = gii1234float - giiMax end
  im.globimage_index1234 = floor(gii1234float)
  im.globimage_index1213 = gii1213table[im.globimage_index1234]
end

im.spriteSettings = {
  testtiles = {'Tiles/TestTiles', 4, 7},
  zeldarip = {'Tiles/zeldarip', 16, 71, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.zeldarip"},
  floorOutside = {'Tiles/FloorOutside', 10, 10, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.floorOutside"},
  solidsOutside = {'Tiles/SolidsOutside', 11, 7, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.solidsOutside"},
  basicFriendlyInterior = {'Tiles/BasicFriendlyInterior', 11, 7, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.basicFriendlyInterior"},
  testbrick = {'Brick', 2, 2},
  testenemy = {'Enem', padding = 0, width = 16, height = 16},
  testenemy2 = {'Enem2', padding = 0, width = 15*0.5, height = 11*0.5},
  testenemy3 = {'Enem3', padding = 0, width = 18*0.5, height = 15*0.5},
  testenemy4 = {'Enem4', 2, padding = 2, width = 16, height = 16},
  testsplosion = {'Testplosion', 5, padding = 2, width = 16, height = 16},
  testlift = {'LiftableTest', 1, width = 16, height = 16},
  liftableRock = {'LiftableRock', padding = 0, width = 15, height = 15},
  rockDestruction = {'RockDestruction', 4, padding = 2, width = 30, height = 22},
  woodDestruction = {'WoodDestruction', 4, padding = 2, width = 30, height = 22},
  rockPlummet = {'RockPlummet', 3, padding = 2, width = 10, height = 10},
  rockSink = {'RockSink', 3, padding = 2, width = 24, height = 16},
  bushDestruction = {'BushDestruction', 8, padding = 2, width = 30, height = 34},
  grassDestruction = {'GrassDestruction', 8, padding = 2, width = 30, height = 34},
  swordHitWall = {'SwordHitWall', 2, padding = 2, width = 16, height = 16},
  enemyExplosion = {'EnemyExplosion', 4, padding = 2, width = 30, height = 30},
  mark = {'Inventory/UseMarkL1', 3, padding = 2, width = 16, height = 16},
  -- NPCS
  npcTestSprites = {
    {'NPCs/NpcTest/down', 2, padding = 2, width = 16, height = 16}
  },
  npcTest2Sprites = {
    {'NPCs/NpcTest2/down', 2, padding = 2, width = 16, height = 16}
  },
  npcTest3Sprites = {
    {'NPCs/NpcTest3/down', 2, padding = 2, width = 16, height = 16}
  },
  owlStatue = {
    {'NPCs/owlStatue/down', 2, padding = 2, width = 24, height = 16}
  },
  chest = {
    {'NPCs/Chest/down', 2, padding = 2, width = 16, height = 16}
  },
  sign = {
    {'NPCs/Sign/down', 2, padding = 2, width = 16, height = 16}
  },

  -- drops
  dropHeart = {
    {'Drops/heart', 1, padding = 0, width = 7, height = 7}
  },
  dropRupee = {
    {'Drops/rupee', 1, padding = 0, width = 5, height = 11}
  },
  dropRupee5 = {
    {'Drops/rupee5', 1, padding = 0, width = 7, height = 14}
  },
  dropRupee20 = {
    {'Drops/rupee20', 1, padding = 0, width = 7, height = 14}
  },
  dropRupee100 = {
    {'Drops/rupee100', 1, padding = 0, width = 11, height = 16}
  },
  dropRupee200 = {
    {'Drops/rupee200', 1, padding = 0, width = 11, height = 16}
  },
  dropFairy = {
    {'Drops/fairy', 1, padding = 0, width = 8, height = 11}
  },

  pieceOfHeart = {
    {'pieceOfHeart', 1, padding = 0, width = 16, height = 15}
  },

  -- menu stuff
  triforce = {'Menu/menuTriforce', 4, padding = 1, width = 28, height = 24},
  tunics = {'tunics', 4, padding = 1, width = 16, height = 13},
  swordSkill = {'swordSkill', 4, padding = 1, width = 16, height = 13},
  missileSkill = {'missileSkill', 4, padding = 1, width = 16, height = 13},
  mobilitySkill = {'mobilitySkill', 4, padding = 1, width = 9, height = 13},

  boss1TestSprites = {
    -- {'boss1/arevcyeq', padding = 0, width = 18, height = 30},
    {'boss1/arevcyeq', 4, padding = 2, width = 24, height = 28},
    -- {'boss1/arevcyeqLH', 2, padding = 2, width = 8, height = 9},
    {'boss1/arevcyeqLH', 2, padding = 2, width = 15, height = 10},
    {'boss1/arevcyeqRH', padding = 0, width = 12, height = 12},
    {'boss1/arevcyeqLaser1', 2, padding = 0, width = 26, height = 107}
  },
  boss1Orb = {'boss1/arevcyeqOrb', padding = 0, width = 16, height = 16},
  boss1LiftableOrb = {'boss1/arevcyeqLiftableOrb', padding = 0, width = 16, height = 16},
  boss1OrbShadow = {'boss1/arevcyeqOrbShadow', 1, padding = 2, width = 16, height = 16},
  playerSprites = {
    {'Witch/walk_left', 2, padding = 2, width = 16, height = 16},
    {'Witch/walk_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/walk_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/push_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/push_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/push_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/grip_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/grip_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/grip_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/lifting_up', 1, padding = 2, width = 16, height = 16},
    {'Witch/lifting_left', 1, padding = 2, width = 16, height = 16},
    {'Witch/lifting_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/lifted_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/lifted_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/lifted_down', 4, padding = 2, width = 16, height = 16},
    {'Witch/halt_up', 1, padding = 2, width = 16, height = 16},
    {'Witch/halt_left', 1, padding = 2, width = 16, height = 16},
    {'Witch/halt_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/hurt_up', 1, padding = 2, width = 16, height = 16},
    {'Witch/hurt_left', 1, padding = 2, width = 16, height = 16},
    {'Witch/hurt_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/still_up', 1, padding = 2, width = 16, height = 16},
    {'Witch/still_left', 1, padding = 2, width = 16, height = 16},
    {'Witch/still_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/swing_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/swing_left', 2, padding = 2, width = 16, height = 16},
    {'Witch/swing_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/hold_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/hold_left', 2, padding = 2, width = 16, height = 16},
    {'Witch/hold_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/shoot_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/shoot_left', 2, padding = 2, width = 16, height = 16},
    {'Witch/shoot_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/jump_down', 4, padding = 2, width = 16, height = 16},
    {'Witch/jump_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/jump_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/mark_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/recall_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/display_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/drown_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/climb_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/plummet', 3, padding = 2, width = 16, height = 16},
    {'Witch/die', 7, padding = 2, width = 16, height = 16},
    {'Witch/shadow', 1, padding = 2, width = 16, height = 16},
    {'Witch/defaultGrass', 2, padding = 2, width = 16, height = 16},
    {'Witch/defaultWaterRipples', 4, padding = 2, width = 16, height = 6},
    {'health', 5, padding = 2, width = 7, height = 7},
    {'rupees', 1, padding = 0, width = 7, height = 7},
    {'Test', 1, padding = 0},
  },
  playerSword = {'Inventory/UseSwordL1', 3, padding = 2, width = 16, height = 15},
  playerMissile = {'Inventory/UseMissileL1', 5, padding = 2, width = 4, height = 4},
  playerMissileOutline = {'Inventory/UseMissileOutlineL1', 1, padding = 2, width = 6, height = 6},
  -- Enemy sprites
  bullKnight = {
    {'Enemies/BullKnight/walk_left', 2, padding = 2, width = 16, height = 16},
    {'Enemies/BullKnight/walk_up', 2, padding = 2, width = 16, height = 16},
    {'Enemies/BullKnight/walk_down', 2, padding = 2, width = 16, height = 16},
    {'Enemies/BullKnight/stun_down', 2, padding = 2, width = 16, height = 16},
    {'surprize', 2, padding = 2, width = 16, height = 16},
  },
  slime = {
    {'Enemies/Slime/slime', 2, padding = 2, width = 16, height = 16}
  },
  wasp = {
    {'Enemies/Wasp/wasp', 2, padding = 2, width = 16, height = 16}
  },
  raven = {
    {'Enemies/Raven/raven', 2, padding = 2, width = 16, height = 16}
  },
  crow = {
    {'Enemies/Crow/crow', 2, padding = 2, width = 16, height = 16}
  },

  -- HUD
  clock = {"clock", 1, padding = 0, width = 19, height = 19},
  clockHand = {"clockHand", 2, padding = 2, width = 7, height = 26},
}

im.sprites = {}

function im.load_sprite(args)

  local img_name
  if type(args) == "string" then
    img_name = args
  else
    img_name = args.img_name or args[1]
  end

  -- if it already exists, don't add it again
  if not im.sprites[img_name] then
    -- store optional arguments in local memory
    local rows = args.rows or args[2] or 1
    local columns = args.columns or args[3] or 1
    local padding = args.padding or args[4] or 1

    -- Prepare sprite
    local sprite = {}
    -- Load image
    sprite.img = love.graphics.newImage("Sprites/" .. img_name .. ".png")
    local img = sprite.img

    -- Determine the width and height of each quad
    local imgw = img:getWidth()
    local imgh = img:getHeight()
    local width = --[[math.ceil(]](imgw / rows)--[[)]] - 2 * padding
    local height = --[[math.ceil(]](imgh / columns)--[[)]] - 2 * padding

    -- Determine x and y scale because of the image resolution
    if args.width then
      sprite.res_x_scale = args.width / width
      sprite.res_y_scale = args.height / height
    else
      sprite.res_x_scale = 1
      sprite.res_y_scale = 1
    end

    sprite.width, sprite.height = args.width, args.height

    -- Determine center
    sprite.cx = width * 0.5 + dw -- sprite.cx = width * 0.5
    sprite.cy = height * 0.5 + dh -- sprite.cy = height * 0.5

    -- Slice image WARNING: This table starts from ZERO!!!!
    local frames = 0
    for j = 0, columns-1 do
      for i = 0, rows-1 do
        sprite[frames] = love.graphics.newQuad(
        padding-dw*0.5+i*(width + 2 * padding ), --x= padding+i*(width + 2 * padding ),
        padding-dh*0.5+j*(height + 2 * padding ), --y= padding+j*(height + 2 * padding ),
        width+dw, height+dh, --width, height,
        img:getDimensions())
        frames = frames + 1
      end
    end
    sprite.frames = frames
    -- Initialize counter that stores how many times this image was loaded
    sprite.times_loaded = 0
    im.sprites[img_name] = sprite
  end

  local sprite = im.sprites[img_name]
  -- The sprite must only be able to be removed from memory if this is zero
  sprite.times_loaded = sprite.times_loaded + 1

  return sprite
end

function im.replace_sprite(oldImageName, newSpriteBlueprint)
  -- Get new image name
  local img_name
  if type(newSpriteBlueprint) == "string" then
    img_name = newSpriteBlueprint
  else
    img_name = newSpriteBlueprint.img_name or newSpriteBlueprint[1]
  end
  -- load new sprite
  local newSprite = im.load_sprite(newSpriteBlueprint)
  -- Remember the right amount of times loaded
  local timesLoaded = im.sprites[oldImageName] and im.sprites[oldImageName].times_loaded or 1
  newSprite.times_loaded = timesLoaded
  -- Delete normal sprite load
  im.sprites[img_name] = nil
  -- Do the replacing
  im.sprites[oldImageName] = newSprite
end

function im.unload_sprite(img_name)
  im.sprites[img_name].times_loaded = im.sprites[img_name].times_loaded - 1
  if im.sprites[img_name].times_loaded == 0 then im.sprites[img_name] = nil end
end

function im.reloadPlSprites()
  for i, plSprite in ipairs(im.spriteSettings.playerSprites) do
    -- preserve times_loaded to avoid bugs
    local timesLoaded = im.sprites[plSprite[1]].times_loaded
    im.sprites[plSprite[1]] = nil
    -- reload sprites
    im.load_sprite(plSprite).times_loaded = timesLoaded
  end
end

-- Preload some stuff here
for _, plSprite in ipairs(im.spriteSettings.playerSprites) do
  im.load_sprite(plSprite)
end
im.load_sprite(im.spriteSettings.floorOutside)
im.load_sprite(im.spriteSettings.solidsOutside)
im.load_sprite(im.spriteSettings.zeldarip)
im.load_sprite(im.spriteSettings.basicFriendlyInterior)
im.load_sprite(im.spriteSettings.playerSword)
im.load_sprite(im.spriteSettings.playerMissile)
im.load_sprite(im.spriteSettings.clock)
im.load_sprite(im.spriteSettings.clockHand)
im.load_sprite(im.spriteSettings.triforce)
im.load_sprite(im.spriteSettings.tunics)
im.load_sprite(im.spriteSettings.swordSkill)
im.load_sprite(im.spriteSettings.missileSkill)
im.load_sprite(im.spriteSettings.mobilitySkill)

return im
