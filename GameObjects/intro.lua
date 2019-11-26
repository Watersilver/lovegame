local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local game = require "game"
local im = require "image"
local snd = require "sound"
local inp = require "input"
local o = require "GameObjects.objects"

local Intro = {}

local beat = 3.77
local flashPoint = 15
local bgr2Point = 15.48
local farRearPoint = 20.5
local portalPoint = 25.25
local portalPoint2 = 28
local horseLookPoint1 = 29
local horseLookPoint2 = 32
local endPoint = 36

function Intro.initialize(instance)
  instance.side = "right"
  instance.ids[#instance.ids+1] = "introID"
  instance.counter = 0
  instance.image_index = 0
  instance.horsei_index = 0
  instance.ylinkh = -500
  instance.scalelh = 1
  instance.castleXMod = 0
  instance.horseXMod = 0
  instance.lhangle = 0
  instance.prtalIndex = 0
  instance.kidnx = 0
  instance.kidny = 0
  instance.kidnxMod = 10
  instance.kidnyMod = 0
  instance.kidscale = 1
  instance.portalScale = 1
  instance.kidAngle = 0
  instance.preCounter = 0
end

Intro.functions = {
  load = function()
    snd.bgmV2:load()
  end,

  delete = function()
    snd.bgmV2.overrideAndLoad()
  end,

  update = function(self, dt)
    if self.preCounter < 1.5 then
      self.preCounter = self.preCounter + dt
    else
      self.counter = self.counter + dt
      if not self.loadedIntroMusic then
        snd.bgmV2.overrideAndLoad("Intro")
        self.loadedIntroMusic = true
      end
    end
    if inp.enterPressed or inp.cancelPressed then
      snd.play(glsounds.select)
      o.removeFromWorld(self)
    end
    self.prtalIndex = self.prtalIndex + dt * 10
    while self.prtalIndex >= 2 do
      self.prtalIndex = self.prtalIndex - 2
    end
    self.image_index_prev = self.image_index
    self.image_index = self.image_index + dt*5
    if self.counter > bgr2Point then
      if self.counter < farRearPoint then
        self.ylinkh = self.ylinkh + dt * 200
        if self.ylinkh > -10 then
          self.ylinkh = -10
          -- self.scalelh = self.scalelh + dt * 2
          self.scalelh = self.scalelh + dt * 4
          if self.scalelh > 3 then
            self.lhangle = self.lhangle + dt * 3
          end
        end
      elseif self.castleXMod < 3.8 then
        self.horsei_index = self.horsei_index + dt*40
        self.castleXMod = self.castleXMod + dt
        self.horseXMod = self.horseXMod - 8 * dt
      elseif self.counter < portalPoint then
        self.horsei_index = self.horsei_index + dt*40
      else
        if not self.portalSounds then
          session.setMusicOverride()
          snd.bgmV2:load{previousFadeOut = math.huge}
          snd.play(glsounds.portal)
          self.portalSounds = true
        end
        self.kidnxMod = self.kidnxMod + dt * 4
        self.kidnyMod = self.kidnyMod + dt * 12
        self.kidnx = self.kidnx + dt * self.kidnxMod
        self.kidny = self.kidny - dt * self.kidnyMod
        self.kidscale = self.kidscale * 0.995
        self.kidAngle = self.kidAngle + dt * 12
        if self.counter > portalPoint2 then
          self.portalScale = self.portalScale * 0.993
        end
      end
    end
    if self.counter > endPoint then
      if self.counter > endPoint + 1 then
        o.removeFromWorld(self)
      end
    end
  end,

  draw = function(self)
    if self.counter < flashPoint then
      local bSprite = im.sprites.introBackground
      love.graphics.draw(bSprite.img, bSprite[0], camWidth * 0.5, camHeight * 0.5 - 15, 0,
      bSprite.res_x_scale, bSprite.res_y_scale, bSprite.cx, bSprite.cy)
    elseif self.counter < bgr2Point or self.counter > endPoint then
      love.graphics.rectangle("fill", 0, 0, camWidth, camHeight)
    elseif self.counter < farRearPoint then
      local bSprite = im.sprites.linkHorseback5
      love.graphics.draw(bSprite.img, bSprite[0], camWidth * 0.5 + 69, camHeight * 0.5 + self.ylinkh, self.lhangle,
      bSprite.res_x_scale * self.scalelh, bSprite.res_y_scale * self.scalelh, 94, 52)
    else
      local bSprite = im.sprites.introBackground2
      love.graphics.draw(bSprite.img, bSprite[0], self.castleXMod + camWidth * 0.5, camHeight * 0.5 - 15, 0,
      bSprite.res_x_scale, bSprite.res_y_scale, bSprite.cx, bSprite.cy)
      if self.counter < portalPoint then
        local sprite = im.sprites.linkHorseback6
        local frames = sprite.frames
        while self.horsei_index >= frames do
          self.horsei_index = self.horsei_index - frames
        end
        love.graphics.draw(
          sprite.img, sprite[math.floor(self.horsei_index)],
          self.horseXMod + camWidth * 0.7, camHeight * 0.73, 0,
          sprite.res_x_scale, sprite.res_y_scale, sprite.cx, sprite.cy
        )
      else
        local sprite = im.sprites.linkKidnappedPortal
        local image_index = self.prtalIndex
        love.graphics.draw(
          sprite.img, sprite[math.floor(image_index)],
          self.horseXMod + camWidth * 0.7 - 9 * 4.2 + self.kidnx, camHeight * 0.73 - 7.95 * 4.2 + self.kidny, 0,
          sprite.res_x_scale * self.portalScale, sprite.res_y_scale * self.portalScale, sprite.cx, sprite.cy
        )
        sprite = im.sprites.horseAlone
        image_index = (self.counter < horseLookPoint1 and 0) or (self.counter < horseLookPoint2 and 1 or 2)
        love.graphics.draw(
          sprite.img, sprite[math.floor(image_index)],
          self.horseXMod + camWidth * 0.7, camHeight * 0.73 + 14.9, 0,
          sprite.res_x_scale, sprite.res_y_scale, sprite.cx, sprite.cy
        )
        sprite = im.sprites.linkKidnapped
        image_index = 0
        love.graphics.draw(
          sprite.img, sprite[math.floor(image_index)],
          self.horseXMod + camWidth * 0.7 - 9 * 4.2 + self.kidnx, camHeight * 0.73 - 7.95 * 4.2 + self.kidny, self.kidAngle,
          sprite.res_x_scale * self.kidscale, sprite.res_y_scale * self.kidscale, sprite.cx, sprite.cy
        )
      end
    end
    -- At 15 music changes
    if self.counter < beat then
      local sprite = im.sprites.linkHorseback1
      local frames = sprite.frames
      while self.image_index >= frames do
        self.image_index = self.image_index - frames
      end
      love.graphics.draw(
        sprite.img, sprite[math.floor(self.image_index)],
        camWidth * 0.5, camHeight * 0.7, 0,
        sprite.res_x_scale, sprite.res_y_scale, sprite.cx, sprite.cy
      )
    elseif self.counter < beat * 2 then
      local sprite = im.sprites.linkHorseback2
      local frames = sprite.frames
      while self.image_index >= frames do
        self.image_index = self.image_index - frames
      end
      love.graphics.draw(
        sprite.img, sprite[math.floor(self.image_index)],
        camWidth * 0.5, camHeight * 0.725, 0,
        sprite.res_x_scale, sprite.res_y_scale, sprite.cx, sprite.cy
      )
    elseif self.counter < beat * 3 then
      local sprite = im.sprites.linkHorseback3
      local frames = sprite.frames
      while self.image_index >= frames do
        self.image_index = self.image_index - frames
      end
      love.graphics.draw(
        sprite.img, sprite[math.floor(self.image_index)],
        camWidth * 0.5, camHeight * 0.615, 0,
        sprite.res_x_scale, sprite.res_y_scale, sprite.cx, sprite.cy
      )
    elseif self.counter < flashPoint then
      local sprite = im.sprites.linkHorseback4
      local frames = sprite.frames
      while self.image_index >= frames do
        self.image_index = self.image_index - frames
      end
      love.graphics.draw(
        sprite.img, sprite[math.floor(self.image_index)],
        -- camWidth * 0.5, camHeight * 0.6, 0,
        camWidth * 0.5, camHeight * 0.75, 0,
        sprite.res_x_scale, sprite.res_y_scale, sprite.cx, sprite.cy
      )
    end
    local pr, pg, pb, pa = love.graphics.getColor()
    local fogAlpha = (math.floor((1 - self.counter / 6) * 14) / 14) * COLORCONST
    love.graphics.setColor(pr, pg, pb, fogAlpha)
    love.graphics.rectangle("fill", 0, 0, camWidth, camHeight)
    love.graphics.setColor(pr, pg, pb, pa)
  end
}

function Intro:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Intro, instance, init) -- add own functions and fields
  return instance
end

return Intro
