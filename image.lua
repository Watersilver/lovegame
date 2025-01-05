local utilities = require "utilities"
-- removes scaled sprite blurriness
love.graphics.setDefaultFilter("nearest", "nearest")

local floor = math.floor

-- Will try to avoid gaps for adjacent tiles by making them slightly bigger
-- Set to nullify by setting to 0
local dw = 0.0
local dh = dw

local im = {}

-- For animated background
local giiSpeed = 3
local giiFastSpeed = 12
local gii1234float = 0
local giiFast1234float = 0
local gii4loopfloat = 0
local giiMax = 4
local giiLoopMax = 6
im.globimage_index1234 = gii1234float
im.globimageFast_index1234 = giiFast1234float
local gii1213table = {1, 0, 2, [0] = 0}
im.globimage_index1213 = gii1213table[im.globimage_index1234]
local gii4loopTable = {[0] = 0, 1, 2, 3, 2, 1}
im.globimage_index4loop = gii4loopTable[floor(gii4loopfloat)]

function im.updateGlobalImageIndexes(dt)
  gii1234float = gii1234float + giiSpeed * dt
  while gii1234float >= giiMax do gii1234float = gii1234float - giiMax end
  giiFast1234float = giiFast1234float + giiFastSpeed * dt
  while giiFast1234float >= giiMax do giiFast1234float = giiFast1234float - giiMax end
  gii4loopfloat = gii4loopfloat + giiSpeed * dt
  while gii4loopfloat >= giiLoopMax do gii4loopfloat = gii4loopfloat - giiLoopMax end
  im.globimage_index1234 = floor(gii1234float)
  im.globimageFast_index1234 = floor(giiFast1234float)
  im.globimage_index1213 = gii1213table[im.globimage_index1234]
  im.globimage_index4loop = gii4loopTable[floor(gii4loopfloat)]
end

-- im.spriteSettings.floor,
-- im.spriteSettings.walls,
-- im.spriteSettings.portals,
-- im.spriteSettings.edges,
-- im.spriteSettings.clutter,

im.spriteSettings = {
  testtiles = {'Tiles/TestTiles', 4, 7},
  floor = {'Tiles/Floor', 8, 33, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.floor"},
  walls = {'Tiles/Walls', 7, 39, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.walls"},
  portals = {'Tiles/Portals', 5, 3, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.portals"},
  edges = {'Tiles/Edges', 2, 2, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.edges"},
  clutter = {'Tiles/Clutter', 8, 11, padding = 2, width = 16, height = 16, positionstring = "im.spriteSettings.clutter"},
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
  rainSplash = {'RainSplash', 3, padding = 2, width = 7, height = 6},
  rockDestruction = {'RockDestruction', 4, padding = 2, width = 30, height = 22},
  woodDestruction = {'WoodDestruction', 4, padding = 2, width = 30, height = 22},
  rockPlummet = {'RockPlummet', 3, padding = 2, width = 10, height = 10},
  rockSink = {'RockSink', 3, padding = 2, width = 24, height = 16},
  bushDestruction = {'BushDestruction', 8, padding = 2, width = 30, height = 34},
  grassDestruction = {'GrassDestruction', 8, padding = 2, width = 30, height = 34},
  swordHitWall = {'SwordHitWall', 2, padding = 2, width = 16, height = 16},
  enemyExplosion = {'EnemyExplosion', 4, 4, padding = 0, width = 64, height = 64},
  teleportEffect = {'TeleportEffect', 4, 4, padding = 0, width = 64, height = 64},
  smallExplosion1 = {'Effects/small-explosion-1', 7, padding = 0, width = 32, height = 32},
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
    {'NPCs/owlStatue/asleep', 3, padding = 2, width = 16, height = 16},
    {'NPCs/owlStatue/awake', 12, padding = 2, width = 16, height = 22, oy = 3}
  },
  chest = {
    {'NPCs/Chest/down', 2, padding = 2, width = 16, height = 16}
  },
  sign = {
    {'NPCs/Sign/down', 2, padding = 2, width = 16, height = 16}
  },

  -- drops
  dropHeart = {
    {'Drops/heart', 4, padding = 2, width = 10, height = 8}
  },
  dropRupee = {
    {'Drops/rupee', 7, padding = 0, width = 8, height = 8}
  },
  dropRupee5 = {
    {'Drops/rupee5', 8, padding = 0, width = 9, height = 9}
  },
  dropRupee20 = {
    {'Drops/rupee20', 8, padding = 0, width = 11, height = 11}
  },
  dropRupee100 = {
    {'Drops/rupee100', 9, padding = 0, width = 12, height = 12}
  },
  dropRupee200 = {
    {'Drops/rupee200', 7, padding = 0, width = 16, height = 16}
  },
  dropFairy = {
    {'Drops/fairy', 2, padding = 2, width = 16, height = 17}
  },

  pieceOfHeart = {
    {'pieceOfHeart', 4, padding = 2, width = 9, height = 15}
  },

  -- menu stuff
  triforce = {'Menu/menuTriforce', 4, padding = 1, width = 28, height = 24},
  tunics = {'tunics', 4, padding = 1, width = 16, height = 13},
  swordSkill = {'swordSkill', 4, padding = 1, width = 16, height = 13},
  missileSkill = {'missileSkill', 4, padding = 1, width = 16, height = 13},
  mobilitySkill = {'mobilitySkill', 4, padding = 1, width = 9, height = 13},

  playerSprites = {
    {'Witch/walk_left', 10, padding = 0, width = 32, height = 32},
    {'Witch/walk_up', 10, padding = 0, width = 32, height = 32},
    {'Witch/walk_down', 10, padding = 0, width = 32, height = 32},
    {'Witch/push_up', 8, padding = 0, width = 32, height = 32},
    {'Witch/push_left', 8, padding = 0, width = 32, height = 32},
    {'Witch/push_down', 8, padding = 0, width = 32, height = 32},
    {'Witch/grip_up', 8, padding = 0, width = 32, height = 32},
    {'Witch/grip_left', 8, padding = 0, width = 32, height = 32},
    {'Witch/grip_down', 8, padding = 0, width = 32, height = 32},
    {'Witch/lifting_up', 1, padding = 0, width = 32, height = 32},
    {'Witch/lifting_left', 1, padding = 0, width = 32, height = 32},
    {'Witch/lifting_down', 1, padding = 0, width = 32, height = 32},
    {'Witch/carry_up', 10, padding = 0, width = 32, height = 32},
    {'Witch/carry_left', 10, padding = 0, width = 32, height = 32},
    {'Witch/carry_down', 10, padding = 0, width = 32, height = 32},
    {'Witch/skid_up', 6, padding = 0, width = 32, height = 32},
    {'Witch/skid_left', 6, padding = 0, width = 32, height = 32},
    {'Witch/skid_down', 6, padding = 0, width = 32, height = 32},
    {'Witch/hurt_up', 2, padding = 0, width = 32, height = 32},
    {'Witch/hurt_left', 2, padding = 0, width = 32, height = 32},
    {'Witch/hurt_down', 2, padding = 0, width = 32, height = 32},
    {'Witch/idle_up', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_left', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_down', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_shoot_up', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_shoot_left', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_shoot_down', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_carry_up', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_carry_left', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_carry_down', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_hold_up', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_hold_left', 1, padding = 0, width = 32, height = 32},
    {'Witch/idle_hold_down', 1, padding = 0, width = 32, height = 32},
    {'Witch/riding_start_up', 3, padding = 0, width = 32, height = 32},
    {'Witch/riding_start_left', 3, padding = 0, width = 32, height = 32},
    {'Witch/riding_start_down', 3, padding = 0, width = 32, height = 32},
    {'Witch/broom_left', 3, padding = 0, width = 32, height = 32},
    {'Witch/broom_up', 3, padding = 0, width = 32, height = 32},
    {'Witch/broom_down', 3, padding = 0, width = 32, height = 32},
    {'Witch/swing_up', 2, padding = 0, width = 32, height = 32},
    {'Witch/swing_left', 2, padding = 0, width = 32, height = 32},
    {'Witch/swing_down', 2, padding = 0, width = 32, height = 32},
    {'Witch/hold_up', 10, padding = 0, width = 32, height = 32},
    {'Witch/hold_left', 10, padding = 0, width = 32, height = 32},
    {'Witch/hold_down', 10, padding = 0, width = 32, height = 32},
    {'Witch/shoot_up', 10, padding = 0, width = 32, height = 32},
    {'Witch/shoot_left', 10, padding = 0, width = 32, height = 32},
    {'Witch/shoot_down', 10, padding = 0, width = 32, height = 32},
    {'Witch/jump_down', 3, padding = 0, width = 32, height = 32},
    {'Witch/jump_left', 3, padding = 0, width = 32, height = 32},
    {'Witch/jump_up', 3, padding = 0, width = 32, height = 32},
    {'Witch/idle_landing_down', 4, padding = 0, width = 32, height = 32},
    {'Witch/idle_landing_left', 4, padding = 0, width = 32, height = 32},
    {'Witch/idle_landing_up', 4, padding = 0, width = 32, height = 32},
    {'Witch/dash_down', 8, padding = 0, width = 32, height = 32},
    {'Witch/dash_left', 8, padding = 0, width = 32, height = 32},
    {'Witch/dash_up', 8, padding = 0, width = 32, height = 32},
    {'Witch/mdust_down', 2, padding = 0, width = 32, height = 32},
    {'Witch/mdust_left', 2, padding = 0, width = 32, height = 32},
    {'Witch/mdust_up', 2, padding = 0, width = 32, height = 32},
    {'Witch/mark_down', 1, padding = 0, width = 32, height = 32},
    {'Witch/recall_down', 1, padding = 0, width = 32, height = 32},
    {'Witch/fallen_down', 1, padding = 0, width = 32, height = 32},
    {'Witch/display_down', 2, padding = 0, width = 32, height = 32},
    {'Witch/eating_down', 17, padding = 0, width = 32, height = 32},
    {'Witch/drinking_down', 10, padding = 0, width = 32, height = 32},
    {'Witch/sleeping_down', 7, padding = 0, width = 32, height = 32},
    {'Witch/flute_down', 6, padding = 0, width = 32, height = 32},
    {'Witch/drown_down', 8, padding = 0, width = 32, height = 32},
    {'Witch/climb_up', 6, padding = 0, width = 32, height = 32},
    {'Witch/plummet', 11, padding = 0, width = 32, height = 32},
    {'Witch/die', 2, padding = 0, width = 32, height = 32},
    {'Witch/shadow', 1, padding = 2, width = 16, height = 16},
    {'Witch/defaultGrass', 2, padding = 2, width = 16, height = 16},
    {'Witch/wake_down', 3, padding = 0, width = 32, height = 32},
    {'Witch/defaultWaterRipples', 4, padding = 2, width = 16, height = 6}
  },
  note = {'note', 1, padding = 0, width = 7, height = 12},
  playerSword = {
    {'Inventory/sword/draw', 4, padding = 0, width = 40, height = 38},
    {'Inventory/sword/held', 30, padding = 0, width = 40, height = 38},
    {'Inventory/sword/held_start', 8, padding = 0, width = 40, height = 38},
    {'Inventory/sword/stab', 5, padding = 0, width = 40, height = 38},
  },
  playerMissile = {
    {'Inventory/missile/creation', 2, padding = 0, width = 16, height = 16},
    {'Inventory/missile/animation', 7, padding = 0, width = 16, height = 16},
    {'Inventory/missile/destruction', 5, padding = 0, width = 16, height = 16},
    {'Inventory/missile/outline', 3, padding = 0, width = 16, height = 16}
  },
  playerBomb = {'Inventory/UseBomb', 4, padding = 2, width = 12, height = 12},
  playerDust = {'Inventory/UseSpeedL1', 3, padding = 2, width = 10, height = 10},
  playerBlast = {'Inventory/UseBombsplosionL1', 8, padding = 0, width = 64, height = 64, oy = 26},
  playerMdust = {'Inventory/UseSprinkle', 6, padding = 2, width = 24, height = 10},
  playerMbox = {'Inventory/UseMagicBox', 4, padding = 2, width = 16, height = 16},
  playerDissapearMbox = {'Inventory/DissapearEffect', 3, padding = 2, width = 16, height = 16},
  playerAppearEffect = {'Inventory/AppearEffect', 3, padding = 2, width = 16, height = 16},
  -- Mystery effects
  fire = {'Fire', 4, padding = 2, width = 14, height = 16},
  whirlwind = {'Whirlwind', 1, padding = 2, width = 16, height = 16},
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
  ghost = {
    {'Enemies/Ghost/ghost', 2, padding = 2, width = 16, height = 15}
  },
  raven = {
    {'Enemies/Raven/raven', 2, padding = 2, width = 24, height = 16}
  },
  crow = {
    {'Enemies/Crow/crow', 2, padding = 2, width = 16, height = 16}
  },
  chopper = {
    {'Enemies/Chopper/chopper', 2, padding = 2, width = 16, height = 16}
  },
  chaser = {
    {'Enemies/Chaser/chasing', 3, padding = 2, width = 16, height = 16},
    {'Enemies/Chaser/waiting', 1, padding = 2, width = 14, height = 15},
  },
  bladeTrap = {
    {'Enemies/BladeTrap/bladeTrap', 4, padding = 2, width = 16, height = 16}
  },
  beetle = {
    {'Enemies/Beetle/beetle', 2, padding = 2, width = 16, height = 16}
  },
  mummy = {
    {'Enemies/Mummy/mummy', 2, padding = 2, width = 16, height = 16}
  },
  skeleton = {
    {'Enemies/Skeleton/down', 2, padding = 2, width = 16, height = 16},
    {'Enemies/Skeleton/up', 2, padding = 2, width = 16, height = 16},
    {'Enemies/Skeleton/left', 2, padding = 2, width = 16, height = 16},
    {'Enemies/Skeleton/jump', 1, padding = 2, width = 16, height = 16}
  },
  bat = {
    {'Enemies/Bat/bat', 2, padding = 2, width = 16, height = 10}
  },
  jumpy = {
    {'Enemies/Jumpy/jumpy', 2, padding = 2, width = 16, height = 16}
  },
  zora = {
    {'Enemies/Zora/zora', 4, padding = 2, width = 16, height = 16}
  },
  robe = {
    {'Enemies/Robe/robe', 4, padding = 2, width = 15, height = 16}
  },
  leever = {
    {'Enemies/Leever/down', 2, padding = 2, width = 16, height = 16},
    {'Enemies/Leever/digging', 2, padding = 2, width = 16, height = 16},
    {'Enemies/Leever/up', 2, padding = 2, width = 16, height = 16},
    {'Enemies/Leever/left', 2, padding = 2, width = 16, height = 16},
  },
  blueHand = {
    {'Enemies/BlueHand/hand', 2, padding = 2, width = 16, height = 16},
    {'Enemies/BlueHand/digging', 2, padding = 2, width = 16, height = 16},
  },
  redHand = {
    {'Enemies/RedHand/hand', 2, padding = 2, width = 16, height = 16},
  },
  jellyfish = {
    {'Enemies/Jellyfish/float', 2, padding = 2, width = 15, height = 18},
    {'Enemies/Jellyfish/shock', 2, padding = 2, width = 16, height = 15},
  },
  jellysmall = {
    {'Enemies/Jellyfish/small', 1, padding = 2, width = 8, height = 10}
  },
  fireMissile = {
    {'Enemies/FireMissile/fireMissile', 2, padding = 2, width = 10, height = 10}
  },
  bone = {
    {'Enemies/Bone/bone', 1, padding = 2, width = 10, height = 10}
  },
  bullet = {
    {'Enemies/Bullet/bullet', 1, padding = 2, width = 10, height = 10}
  },
  dragonFire = {
    {'Bosses/boss3/dragonFire', 4, padding = 2, width = 8, height = 12}
  },
  dragonShockwave = {
    {'Bosses/boss3/shockwave', 4, padding = 2, width = 12, height = 44}
  },
  robeMissile = {
    {'Enemies/Robe/attack', 4, padding = 2, width = 12, height = 12}
  },
  enemySword = {
    {'Enemies/Sword/sword', 1, padding = 2, width = 8, height = 15}
  },
  hoodedSkeleton = {
    {'Enemies/HoodedSkeleton/walk_left', 2, padding = 2, width = 16, height = 16},
    {'Enemies/HoodedSkeleton/walk_up', 2, padding = 2, width = 16, height = 16},
    {'Enemies/HoodedSkeleton/walk_down', 2, padding = 2, width = 16, height = 16},
  },
  mimic = {
    {'Enemies/Mimic/walk_left', 2, padding = 2, width = 16, height = 16},
    {'Enemies/Mimic/walk_up', 2, padding = 2, width = 16, height = 16},
    {'Enemies/Mimic/walk_down', 2, padding = 2, width = 16, height = 16},
  },
  redRockBug = {
    {'Enemies/RedRockBug/walk_left', 2, padding = 2, width = 15, height = 16},
    {'Enemies/RedRockBug/walk_up', 2, padding = 2, width = 16, height = 15},
    {'Enemies/RedRockBug/walk_down', 2, padding = 2, width = 16, height = 15},
  },
  blob = {
    {'Enemies/Blob/walk', 4, padding = 2, width = 14, height = 16},
    {'Enemies/Blob/transwalk', 4, padding = 2, width = 14, height = 16},
    {'Enemies/Blob/shock', 4, padding = 2, width = 13, height = 16},
  },
  swarmFire = {
    {'Enemies/swarm/Fire', 4, padding = 2, width = 14, height = 16}
  },

  -- Bosses
  -- Boss 1
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

  -- Boss 2
  boss2 = {
    {'Bosses/boss2/Head', 4, padding = 2, width = 94, height = 89},
    {'Bosses/boss2/HeadFront', 2, padding = 2, width = 94, height = 63},
    {'Bosses/boss2/LeftEye', 3, padding = 2, width = 18, height = 19},
    {'Bosses/boss2/RightEye', 3, padding = 2, width = 18, height = 19},
    {'Bosses/boss2/LeftEyeMad', 3, padding = 2, width = 18, height = 19},
    {'Bosses/boss2/RightEyeMad', 3, padding = 2, width = 18, height = 19},
    {'Bosses/boss2/HandFront', 1, padding = 2, width = 36, height = 24},
    {'Bosses/boss2/HandBack', 2, padding = 2, width = 53, height = 60}
  },

  boss3 = {
    {'Bosses/boss3/boss3', 6, 4, padding = 2, width = 56, height = 68},
  },

  boss4 = {
    {'Bosses/boss4/boss4', 4, padding = 2, width = 28, height = 29},
    {'Bosses/boss4/shield', 5, padding = 2, width = 16, height = 24},
    {'Bosses/boss4/wreckingBall', 8, padding = 2, width = 16, height = 16},
    {'Bosses/boss4/spikes', 2, padding = 2, width = 22, height = 20},
    {'Bosses/boss4/chainLink', 1, padding = 0, width = 8, height = 8},
  },

  boss5 = {
    -- Head components
    {'Bosses/boss5/headOutline', 3, 3, padding = 2, width = 24, height = 21},
    {'Bosses/boss5/headShadows', 3, 3, padding = 2, width = 24, height = 21},
    {'Bosses/boss5/headHighlights', 3, 3, padding = 2, width = 24, height = 21},
    {'Bosses/boss5/headStem', 3, 3, padding = 2, width = 24, height = 21},
    {'Bosses/boss5/headFeatures', 3, 3, padding = 2, width = 24, height = 21},
    {'Bosses/boss5/headBackground', 3, 3, padding = 2, width = 24, height = 21},

    -- Down facing components
    {'Bosses/boss5/downOutline', 2, 2, padding = 2, width = 33, height = 20},
    {'Bosses/boss5/downShadows', 2, 2, padding = 2, width = 33, height = 20},
    {'Bosses/boss5/downHighlights', 2, 2, padding = 2, width = 33, height = 20},

    -- Left facing components
    {'Bosses/boss5/leftOutline', 2, 2, padding = 2, width = 24, height = 19},
    {'Bosses/boss5/leftShadows', 2, 2, padding = 2, width = 24, height = 19},
    {'Bosses/boss5/leftHighlights', 2, 2, padding = 2, width = 24, height = 19},

    -- Up facing components
    {'Bosses/boss5/upOutline', 2, 2, padding = 2, width = 32, height = 20},
    {'Bosses/boss5/upShadows', 2, 2, padding = 2, width = 32, height = 20},
    {'Bosses/boss5/upHighlights', 2, 2, padding = 2, width = 32, height = 20},
  },

  -- Misc
  torch = {
    {'Misc/Torch/out', 1, padding = 2, width = 16, height = 16},
    {'Misc/Torch/lit', 4, padding = 2, width = 16, height = 16},
  },
  eyeStatue = {
    {'Misc/EyeStatue/statue', 10, padding = 2, width = 16, height = 16},
  },
  door = {
    {'Door', 2, 2}
  },
  regeneratingPlant = {
    {'Misc/RegeneratingPlant/plant', 3, padding = 2, width = 14, height = 14},
  },
  button = {
    {'Misc/Button/brown', 2, padding = 2, width = 10, height = 10},
  },
  -- chesspieces
  pawn = {
    {'Misc/Chess/pawn', 5, padding = 2, width = 11, height = 16},
  },
  bishop = {
    {'Misc/Chess/bishop', 1, padding = 2, width = 13, height = 24},
  },
  knight = {
    {'Misc/Chess/knight', 2, padding = 2, width = 16, height = 20},
  },
  rook = {
    {'Misc/Chess/rook', 2, padding = 2, width = 16, height = 20},
  },
  queen = {
    {'Misc/Chess/queen', 1, padding = 2, width = 16, height = 39},
  },
  king = {
    {'Misc/Chess/king', 1, padding = 2, width = 16, height = 41},
  },

  -- HUD
  clock = {"clock", 1, padding = 0, width = 19, height = 19},
  clockHand = {"clockHand", 2, padding = 2, width = 7, height = 26},
}

im.sprites = {}

---@param args string|[string]|{img_name: string, rows: number, columns: number, padding: number, width?: number, height?: number, oy?: number, cx?: number, cy?: number}
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
    ---@class Sprite
    local sprite = {
      framesX = rows,
      framesY = columns
    }

    -- Load image
    if not img_name then
      print('ass')
    else
      if type(img_name) == 'table' then
        utilities.printTable('img_name', img_name, 2)
      end
    end
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
    sprite.oy = args.oy

    -- Determine center
    sprite.cx = (args.cx or width * 0.5) + dw*0.5
    sprite.cy = (args.cy or height * 0.5) + dh*0.5

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
    sprite.name = img_name
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
  if session.save.saveName and session.save.saveName:upper() == "ZELDA" then
    local altSkins = require "altSkins"
    for _, plSprite in ipairs(im.spriteSettings.playerSprites) do
      local sname = plSprite[1]:gsub("Witch/", '')
      local s
      for _, altSpr in ipairs(altSkins.zeldaPlayerSprites) do
        if altSpr[1]:gsub("Zelda/", '') == sname then s = altSpr end
      end
      if s then
        im.replace_sprite(plSprite[1], s)
      end
    end
  else
    for i, plSprite in ipairs(im.spriteSettings.playerSprites) do
      -- preserve times_loaded to avoid bugs
      local timesLoaded = im.sprites[plSprite[1]].times_loaded
      im.sprites[plSprite[1]] = nil
      -- reload sprites
      im.load_sprite(plSprite).times_loaded = timesLoaded
    end

    -- Player sprite replace code
    -- if true then
    --   local altSkins = require "altSkins"
    --   for _, plSprite in ipairs(im.spriteSettings.playerSprites) do
    --     local sname = plSprite[1]:gsub("Witch/", '')
    --     local s
    --     for _, altSpr in ipairs(altSkins.placeholder) do
    --       if altSpr[1]:gsub("Witch/", '') == sname then s = altSpr end
    --     end
    --     if s then
    --       im.replace_sprite(plSprite[1], s)
    --     end
    --   end
    -- end
  end
end

-- Preload some stuff here
for _, plSprite in ipairs(im.spriteSettings.playerSprites) do
  im.load_sprite(plSprite)
end
im.load_sprite{'rupees', 1, padding = 0, width = 7, height = 7}
im.load_sprite{'Test', 1, padding = 0}
im.load_sprite(im.spriteSettings.note)
im.load_sprite(im.spriteSettings.floorOutside)
im.load_sprite(im.spriteSettings.solidsOutside)
im.load_sprite(im.spriteSettings.basicFriendlyInterior)
for _, swdSprite in ipairs(im.spriteSettings.playerSword) do
  im.load_sprite(swdSprite)
end
for _, mslSprite in ipairs(im.spriteSettings.playerMissile) do
  im.load_sprite(mslSprite)
end
im.load_sprite(im.spriteSettings.playerBomb)
im.load_sprite(im.spriteSettings.playerDust)
im.load_sprite(im.spriteSettings.clock)
im.load_sprite(im.spriteSettings.clockHand)
im.load_sprite(im.spriteSettings.triforce)
im.load_sprite(im.spriteSettings.rainSplash)
im.load_sprite(im.spriteSettings.tunics)
im.load_sprite(im.spriteSettings.swordSkill)
im.load_sprite(im.spriteSettings.missileSkill)
im.load_sprite(im.spriteSettings.mobilitySkill)
im.load_sprite(im.spriteSettings.floor)
im.load_sprite(im.spriteSettings.walls)
im.load_sprite(im.spriteSettings.portals)
im.load_sprite(im.spriteSettings.edges)
im.load_sprite(im.spriteSettings.clutter)
im.load_sprite(im.spriteSettings.fire)
im.load_sprite(im.spriteSettings.smallExplosion1)
im.load_sprite{'linkHorseback1', 5, padding = 0, width = 15 * 5, height = 31 * 5}
im.load_sprite{'linkHorseback2', 4, padding = 0, width = 32 * 5, height = 50 * 5}
im.load_sprite{'linkHorseback3', 4, padding = 0, width = 44 * 5, height = 70 * 5}
im.load_sprite{'linkHorseback4', 4, padding = 0, width = 88 * 5, height = 140 * 5}
im.load_sprite{'linkHorseback5', 1, padding = 0, width = 160 * 5, height = 256 * 5}
im.load_sprite{'linkHorseback6', 4, padding = 0, width = 68 * 4.2, height = 60 * 4.2}
im.load_sprite{'linkKidnappedPortal', 2, padding = 1, width = 16 * 4.2, height = 16 * 4.2}
im.load_sprite{'horseAlone', 3, padding = 0, width = 68 * 4.2, height = 53 * 4.2}
im.load_sprite{'linkKidnapped', 1, padding = 0, width = 24 * 4.2, height = 16 * 4.2}
im.load_sprite{'introBackground', 1, padding = 0, width = 160 * 5, height = 96 * 5}
im.load_sprite{'introBackground2', 1, padding = 0, width = 192 * 4.2, height = 144 * 4.2}

-- HUD
im.load_sprite{'HUD/healthbar', 1, padding = 0, width = 51, height = 8}
im.load_sprite{'HUD/healthbar_fill', 5, padding = 3, width = 1, height = 2}

return im
