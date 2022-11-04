local snd = require "sound"
local o = require "GameObjects.objects"
local im = require "image"

local function createEffect (creator, onExplEnd)
  local appearEffect = (require "GameObjects.explode"):new{
    x = creator.x, y = creator.y,
    layer = creator.layer,
    image_speed = 0.3,
    explosion_sprite = im.spriteSettings.playerAppearEffect,
    sound = glsounds.appearVanish,
    onExplEnd = onExplEnd
  }
  o.addToWorld(appearEffect)
end

local function spawnHeart (appearEffect)
  local heart = (require "GameObjects.drops.heart"):new{
    xstart = appearEffect.x, ystart = appearEffect.y,
  }
  o.addToWorld(heart)
end

local function spawnFairy (appearEffect)
  local fairy = (require "GameObjects.drops.fairy"):new{
    xstart = appearEffect.x, ystart = appearEffect.y,
    inertiaDuration = 0.5
  }
  o.addToWorld(fairy)
end

-- Common magic dust effects to avoid repeating code
local magic_dust_effects = {
  createHeart = function (creator) createEffect(creator, spawnHeart) end,
  createFairy = function (creator) createEffect(creator, spawnFairy) end,

  disappearEffect = function (self)
    local appearEffect = (require "GameObjects.explode"):new{
      x = self.x, y = self.y,
      layer = self.layer,
      image_speed = 0.2,
      explosion_sprite = im.spriteSettings.playerDissapearMbox,
      sound = glsounds.appearVanish,
    }
    o.addToWorld(appearEffect)
  end,

  burn = function (fuel)
    fuel[GCON.md.choose] = nil
    local fire = (require "GameObjects.fire"):new{
      x = fuel.x, y = fuel.y,
      layer = fuel.creator and fuel.creator.layer - 1 or fuel.layer + 1,
      fuel = fuel
    }
    o.addToWorld(fire)
  end,

  blow = function (eye)
    eye[GCON.md.choose] = nil
    local wind = (require "GameObjects.whirlwind"):new{
      x = eye.x, y = eye.y,
      layer = eye.creator and eye.creator.layer - 1 or eye.layer + 1,
      eye = eye
    }
    o.addToWorld(wind)
  end,

  createFrozenBlock = function (freezee)
    snd.play(glsounds.ice)
    local layer
    if pl1 and pl1.exists then
      layer = math.min(freezee.layer + 1, pl1.layer - 1)
    else
      layer = freezee.layer + 1
    end
    local frBlock = (require "GameObjects.frozenBox"):new{
      xstart = freezee.x,
      ystart = freezee.y,
      x = freezee.x,
      y = freezee.y,
      layer = layer,
      sprite_info = freezee.sprite_info,
      image_index = math.floor(freezee.image_index),
    }

    -- -- Can't react anymore... Right?
    -- frBlock[GCON.md.choose] = nil

    if freezee.fixture then
      frBlock.physical_properties.shape = freezee.fixture:getShape()
    end
    o.removeFromWorld(freezee)
    o.addToWorld(frBlock)
  end,

  createBomb = function (bombee)
    local layer
    if pl1 and pl1.exists then
      layer = math.min(bombee.layer + 1, pl1.layer - 1)
    else
      layer = bombee.layer + 1
    end
    local bomb = (require "GameObjects.Items.thrown"):new{
      xstart = bombee.x,
      ystart = bombee.y,
      x = bombee.x,
      y = bombee.y,
      layer = layer,
      iAmBomb = true,
      dustBomb = true,
      bounces = 1,
      timer = 2,
      sprite_info = bombee.sprite_info,
      image_index = math.floor(bombee.image_index),
      zo = 0,
      vx = 0,
      vy = 0,
    }

    -- -- Can't react anymore... Right?
    -- bomb[GCON.md.choose] = nil

    o.removeFromWorld(bombee)
    o.addToWorld(bomb)
  end,

  createStone = function (stonee)
    snd.play(glsounds.stone)
    local layer
    if pl1 and pl1.exists then
      layer = math.min(stonee.layer + 1, pl1.layer - 1)
    else
      layer = stonee.layer + 1
    end
    local stBlock = (require "GameObjects.RockTest"):new{
      xstart = stonee.x,
      ystart = stonee.y,
      x = stonee.x,
      y = stonee.y,
      layer = layer,
      sprite_info = stonee.sprite_info,
      image_index = math.floor(stonee.image_index),
      lift_info = stonee.petrifiedLI or "petrified",
      petrified = true
    }

    -- -- Can't react anymore... Right?
    -- stBlock[GCON.md.choose] = nil

    if stonee.fixture then
      stBlock.physical_properties.shape = stonee.fixture:getShape()
    end
    o.removeFromWorld(stonee)
    o.addToWorld(stBlock)
  end,

  createPlant = function (plantee)
    snd.play(glsounds.plant)
    local layer
    if pl1 and pl1.exists then
      layer = math.min(plantee.layer + 1, pl1.layer - 1)
    else
      layer = plantee.layer + 1
    end
    local plBlock = (require "GameObjects.softLiftable"):new{
      xstart = plantee.x,
      ystart = plantee.y,
      x = plantee.x,
      y = plantee.y,
      layer = layer,
      sprite_info = plantee.sprite_info,
      image_index = math.floor(plantee.image_index),
      lift_info = plantee.plantifiedLI or "plantified",
      plantified = true
    }

    -- -- Can't react anymore... Right?
    -- plBlock[GCON.md.choose] = nil

    if plantee.fixture then
      plBlock.physical_properties.shape = plantee.fixture:getShape()
    end
    o.removeFromWorld(plantee)
    o.addToWorld(plBlock)
  end,
}

return magic_dust_effects