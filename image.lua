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
  floorOutside = {'Tiles/FloorOutside', 10, 10, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.floorOutside"},
  solidsOutside = {'Tiles/SolidsOutside', 11, 7, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.solidsOutside"},
  basicFriendlyInterior = {'Tiles/BasicFriendlyInterior', 11, 7, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.basicFriendlyInterior"},
  testbrick = {'Brick', 2, 2},
  testenemy = {'Enem', padding = 0, width = 16, height = 16},
  testsplosion = {'Testplosion', 5, padding = 2, width = 16, height = 16},
  testlift = {'LiftableTest', 1, width = 16, height = 16},
  mark = {'Inventory/UseMarkL1', 3, padding = 2, width = 16, height = 16},
  npcTestSprites = {
    {'NPCs/NpcTest/down', 2, padding = 2, width = 16, height = 16}
  },
  npcTest2Sprites = {
    {'NPCs/NpcTest2/down', 2, padding = 2, width = 16, height = 16}
  },
  npcTest3Sprites = {
    {'NPCs/NpcTest3/down', 2, padding = 2, width = 16, height = 16}
  },
  playerSprites = {
    -- {'Witch/walk_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/walk_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/walk_left', 8, padding = 0, width = 16, height = 16},
    {'Witch/walk_down', 4, padding = 2, width = 16, height = 16},
    {'Witch/push_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/push_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/push_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/grip_up', 4, padding = 2, width = 16, height = 16},
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
    {'Witch/hold_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/hold_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/hold_down', 4, padding = 2, width = 16, height = 16},
    {'Witch/shoot_up', 4, padding = 2, width = 16, height = 16},
    {'Witch/shoot_left', 4, padding = 2, width = 16, height = 16},
    {'Witch/shoot_down', 4, padding = 2, width = 16, height = 16},
    {'Witch/jump_down', 3, padding = 2, width = 16, height = 16},
    {'Witch/jump_left', 3, padding = 2, width = 16, height = 16},
    {'Witch/jump_up', 3, padding = 2, width = 16, height = 16},
    {'Witch/mark_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/recall_down', 1, padding = 2, width = 16, height = 16},
    {'Witch/drown_down', 2, padding = 2, width = 16, height = 16},
    {'Witch/climb_up', 2, padding = 2, width = 16, height = 16},
    {'Witch/plummet', 3, padding = 2, width = 16, height = 16},
    {'Witch/die', 7, padding = 2, width = 16, height = 16},
    {'Witch/shadow', 1, padding = 2, width = 16, height = 16},
    {'Witch/defaultGrass', 2, padding = 2, width = 16, height = 16},
    {'Witch/defaultWaterRipples', 4, padding = 2, width = 16, height = 6},
    {'health', 2, padding = 2, width = 8, height = 8},
    {'Test', 1, padding = 0},
    {'Plrun_strip12', 12, padding = 0, width = 16, height = 16}
  },
  playerSword = {'Inventory/UseSwordL1', 3, padding = 2, width = 16, height = 15},
  playerMissile = {'Inventory/UseMissileL1', 5, padding = 2, width = 4, height = 4}
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

function im.unload_sprite(img_name)
  im.sprites[img_name].times_loaded = im.sprites[img_name].times_loaded - 1
  if im.sprites[img_name].times_loaded == 0 then im.sprites[img_name] = nil end
end

-- Preload some stuff here
for _, plSprite in ipairs(im.spriteSettings.playerSprites) do
  im.load_sprite(plSprite)
end
im.load_sprite(im.spriteSettings.floorOutside)
im.load_sprite(im.spriteSettings.solidsOutside)
im.load_sprite(im.spriteSettings.basicFriendlyInterior)
im.load_sprite(im.spriteSettings.playerSword)
im.load_sprite(im.spriteSettings.playerMissile)

return im
