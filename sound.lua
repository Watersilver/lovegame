local gs = require "game_settings"
local u = require "utilities"

local snd = {}

snd.silence = {"Silence"}
snd.ovrwrld1 = {
  day = {
    name = "zelOverworld",
    introName = "zelOverworldIntro"
  },
  night = {
    name = "nightloop.local",
    introName = "nightintro.local"
  }
}
snd.soundbalancetest = {name = "soundbalancetest.local"}

---@type table<string, love.Source>
snd.sounds = {}
snd.bgm = {} -- Background Music
-- snd.bgs = nil -- Background Sound

---@type love.Source[]
local soundsToBePlayed = {}

---@return love.Source
function snd.load_sound(snd_info)
  local snd_name = snd_info.name or snd_info[1]
  local extension = snd_info.extension or ".ogg"
  local folder = snd_info.folder or "Sounds/"

  -- if it already exists, don't add it again
  if not snd.sounds[snd_name] then
    snd.sounds[snd_name] = love.audio.newSource( folder .. snd_name .. extension, "static" )
  end

  return snd.sounds[snd_name]
end

function snd.getMasterVolume()
  return gs.master_volume or 1
end

-- local prevMasterVolume = snd.getMasterVolume()
---@param newVol number
function snd.setMasterVolume(newVol)
  ---@diagnostic disable-next-line: undefined-field
  if type(newVol) ~= 'number' then love.errorhandler("newVol wasn't number") end

  -- prevMasterVolume = snd.getMasterVolume()
  gs.master_volume = newVol
end

function snd.getSoundVolume()
  return snd.getMasterVolume() * gs.sound_volume
end

-- local prevSoundVolume = snd.getSoundVolume()
---@param newVol number
function snd.setSoundVolume(newVol)
  ---@diagnostic disable-next-line: undefined-field
  if type(newVol) ~= 'number' then love.errorhandler("newVol wasn't number") end

  -- prevSoundVolume = snd.getSoundVolume()
  gs.sound_volume = newVol
end

function snd.getMusicVolume()
  return gs.music_volume * snd.getMasterVolume()
end

local prevMusicVolume = snd.getMusicVolume()
---@param newVol number
function snd.setMusicVolume(newVol)
  ---@diagnostic disable-next-line: undefined-field
  if type(newVol) ~= 'number' then love.errorhandler("newVol wasn't number") end

  prevMusicVolume = snd.getMusicVolume()
  gs.music_volume = newVol
end

-- Function that returns a table with the sources to the object that calls it
function snd.load_sounds(sounds_info)
  local snd_table = {}
  -- WARNING name in the below for loop is NOT the file name of the sound,
  -- it is the name that the object will refer to the sound as
  for name, snd_info in pairs(sounds_info) do
    snd_table[name] = snd.load_sound(snd_info)
  end
  return snd_table
end

---Doesn't actually play the sound, just adds it to soundsToBePlayed table. If given a list it chooses random
---@param sound love.Source | love.Source[] | nil
function snd.play(sound)
  if not sound then return end
  if not sound.type then return snd.play(u.listPickRandom(sound)) end

  -- Make sure I don't add a sound twice
  sound:stop()
  for _, soundFromTable in ipairs(soundsToBePlayed) do
    if sound == soundFromTable then return end
  end
  table.insert(soundsToBePlayed, sound)
end


function snd.playFootstepSound(tile, inShallowWater)
  if tile then
    if u.anyOf(tile.tileType, {"tile", "ice"}) then
      snd.play(glsounds.footsteps.rockrun)
    elseif u.anyOf(tile.tileType, {"grass", "flowers"}) then
      snd.play(glsounds.footsteps.grassrun)
    elseif u.anyOf(tile.tileType, {"gravel", "gravelyRock", "snowGravel", "icyGravel", "icyDirt"}) then
      snd.play(glsounds.footsteps.gravelrun)
    elseif u.anyOf(tile.tileType, {"deepGrass", "deepSnowGrass"}) then
      snd.play(glsounds.footsteps.grasswalk)
    elseif u.anyOf(tile.tileType, {"mud", "waterlily"}) then
      snd.play(glsounds.footsteps.mudrun)
    elseif u.anyOf(tile.tileType, {"water", "sea"}) then
      snd.play(glsounds.footsteps.waterwalk)
    elseif u.anyOf(tile.tileType, {"snowGrass"}) then
      snd.play(glsounds.footsteps.snowsoftrun)
    elseif u.anyOf(tile.tileType, {"snow"}) then
      snd.play(glsounds.footsteps.snowhardrun)
    elseif u.anyOf(tile.tileType, {"sand"}) then
      snd.play(glsounds.footsteps.sandrun)
    elseif u.anyOf(tile.tileType, {"wood"}) then
      snd.play(glsounds.footsteps.woodrun)
    -- Commented out because it echoes like its in an interior
    -- elseif u.anyOf(tile.tileType, {"tile"}) then
    --   snd.play(glsounds.footsteps.tilerun)
    else
      snd.play(glsounds.footsteps.dirtrun)
    end
  elseif inShallowWater then
    snd.play(glsounds.footsteps.mudrun)
  else
    snd.play(glsounds.footsteps.dirtrun)
  end
end


function snd.playJumpSound(tile, inShallowWater)
  if tile then
    if u.anyOf(tile.tileType, {"tile", "ice"}) then
      snd.play(glsounds.tommusic.stone_jump)
    elseif u.anyOf(tile.tileType, {"grass", "flowers"}) then
      snd.play(glsounds.tommusic.dirt_jump)
    elseif u.anyOf(tile.tileType, {"gravel", "gravelyRock", "snowGravel", "icyGravel", "icyDirt"}) then
      snd.play(glsounds.footsteps.gravelrun)
      snd.play(glsounds.tommusic.dirt_jump)
    elseif u.anyOf(tile.tileType, {"deepGrass", "deepSnowGrass"}) then
      snd.play(glsounds.footsteps.grasswalk)
      snd.play(glsounds.tommusic.dirt_jump)
    elseif u.anyOf(tile.tileType, {"mud", "waterlily"}) then
      snd.play(glsounds.footsteps.mudrun)
      snd.play(glsounds.tommusic.water_jump)
    elseif u.anyOf(tile.tileType, {"water", "sea"}) then
      snd.play(glsounds.tommusic.water_jump)
    elseif u.anyOf(tile.tileType, {"snowGrass"}) then
      snd.play(glsounds.footsteps.snowsoftrun)
      snd.play(glsounds.tommusic.dirt_jump)
    elseif u.anyOf(tile.tileType, {"snow"}) then
      snd.play(glsounds.footsteps.snowhardrun)
      snd.play(glsounds.tommusic.dirt_jump)
    elseif u.anyOf(tile.tileType, {"sand"}) then
      snd.play(glsounds.footsteps.sandrun)
      snd.play(glsounds.tommusic.dirt_jump)
    elseif u.anyOf(tile.tileType, {"wood"}) then
      snd.play(glsounds.tommusic.wood_jump)
    else
      snd.play(glsounds.tommusic.dirt_jump)
    end
  elseif inShallowWater then
    snd.play(glsounds.tommusic.water_jump)
  else
    snd.play(glsounds.tommusic.dirt_jump)
  end
end


function snd.playLandSound(tile, inShallowWater)
  if tile then
    if u.anyOf(tile.tileType, {"tile", "ice"}) then
      snd.play(glsounds.tommusic.stone_land)
    elseif u.anyOf(tile.tileType, {"grass", "flowers"}) then
      snd.play(glsounds.tommusic.dirt_land)
    elseif u.anyOf(tile.tileType, {"gravel", "gravelyRock", "snowGravel", "icyGravel", "icyDirt"}) then
      snd.play(glsounds.footsteps.gravelrun)
      snd.play(glsounds.tommusic.dirt_land)
    elseif u.anyOf(tile.tileType, {"deepGrass", "deepSnowGrass"}) then
      snd.play(glsounds.footsteps.grasswalk)
      snd.play(glsounds.tommusic.dirt_land)
    elseif u.anyOf(tile.tileType, {"mud", "waterlily"}) then
      snd.play(glsounds.footsteps.mudrun)
      snd.play(glsounds.tommusic.water_land)
    elseif u.anyOf(tile.tileType, {"water", "sea"}) then
      snd.play(glsounds.tommusic.water_land)
    elseif u.anyOf(tile.tileType, {"snowGrass"}) then
      snd.play(glsounds.footsteps.snowsoftrun)
      -- snd.play(glsounds.tommusic.dirt_land)
    elseif u.anyOf(tile.tileType, {"snow"}) then
      snd.play(glsounds.footsteps.snowhardrun)
      snd.play(glsounds.tommusic.dirt_land)
    elseif u.anyOf(tile.tileType, {"sand"}) then
      snd.play(glsounds.footsteps.sandrun)
    elseif u.anyOf(tile.tileType, {"wood"}) then
      snd.play(glsounds.tommusic.wood_land)
    else
      snd.play(glsounds.tommusic.dirt_land)
    end
  elseif inShallowWater then
    snd.play(glsounds.tommusic.water_land)
  else
    snd.play(glsounds.tommusic.dirt_land)
  end
end


-- Used in the main update every frame to play soundsToBePlayed
function snd.play_soundsToBePlayed()
  for i, sound in ipairs(soundsToBePlayed) do
    if gs.soundsOn then
      sound:setVolume(snd.getSoundVolume())
      sound:play()
    end
    soundsToBePlayed[i] = nil
  end
end



-- BGM ver2
local silentSource = {
  getVolume = function() return 0 end,
  isPlaying = function() return false end,
  setLooping = function(loop) end,
  setVolume = function(self, vol) end,
  play = function() end,
  stop = function() end,
  update = function(self, dt) end,
  pause = function() end,
  resume = function() end,
  muffle = function() end,
  unmuffle = function() end
}

-- bgm with intro
local bgmV2Source = {
  setLooping = function(self, bool)
    self.shouldBeLooping = bool
    self.main:setLooping(bool)
  end,
  isPlaying = function(self)
    return self[self.section]:isPlaying()
  end,
  play = function(self)
    self[self.section]:play()
    self.shouldBePlaying = true
    self.stopped = false
  end,
  stop = function(self)
    self[self.section]:stop()
    self.section = self.intro and "intro" or "main"
    self.shouldBePlaying = false
    self.stopped = true
  end,
  setVolume = function(self, vol)
    self.volume = vol
    local mod = self.muffled and 0.2 or 1
    self[self.section]:setVolume(self.volume * mod)
  end,
  getVolume = function(self)
    -- return self[self.section]:getVolume()
    return self.volume
  end,
  pause = function(self)
    if self.paused then return end
    self.paused = true
    self.shouldBePlaying = false
    self[self.section]:pause()
  end,
  resume = function(self)
    if not self.paused then return end
    self.paused = false
    self.shouldBePlaying = true
    self[self.section]:play()
  end,
  muffle = function(self)
    self.muffled = true
    self:setVolume(self:getVolume())
  end,
  unmuffle = function(self)
    self.muffled = false
    self:setVolume(self:getVolume())
  end,
}
bgmV2Source.new = function(sourceInfo)
  if sourceInfo.introName then
    bgmV2Source.intro = love.audio.newSource( sourceInfo.folder .. sourceInfo.introName .. sourceInfo.extension, "stream" )
    bgmV2Source.section = "intro"
  else
    bgmV2Source.intro = nil
    bgmV2Source.section = "main"
  end
  bgmV2Source.shouldBePlaying = false
  bgmV2Source.shouldBeLooping = false
  bgmV2Source.main = love.audio.newSource( sourceInfo.folder .. sourceInfo.name .. sourceInfo.extension, "stream" )
  bgmV2Source.volume = bgmV2Source.main:getVolume()
  return bgmV2Source
end
bgmV2Source.update = function(self, dt)
  if self.section == "intro" then
    if not self.intro:isPlaying() then
      self.section = "main"
      self.main:setVolume(self.intro:getVolume())
      self.main:play()
    end
  end
end


local function fadeToVolume(source, targetVol, vChangPerSec, dt)
  local curVol = source:getVolume()
  if source ~= silentSource and curVol ~= targetVol then
    if curVol > targetVol then
      local newVol = curVol - vChangPerSec * dt
      if newVol < targetVol then newVol = targetVol end
      source:setVolume(newVol)
    else
      local newVol = curVol + vChangPerSec * dt
      if newVol > targetVol then newVol = targetVol end
      source:setVolume(newVol)
    end
  end
end

local function playNextSource(bgmv2)
  bgmv2.silenceTimer = 0
  bgmv2.current = bgmv2.next
  if bgmv2.source:isPlaying() then bgmv2.source:stop() end
  if bgmv2.next.name then
    -- bgmv2.source = love.audio.newSource( bgmv2.next.folder .. bgmv2.next.name .. bgmv2.next.extension, "stream" )
    -- bgm with intro
    bgmv2.source = bgmV2Source.new( bgmv2.next )

    bgmv2.source:setVolume(0)
    bgmv2.source:play()
    bgmv2.source:setLooping(true)
  else
    bgmv2.source = silentSource
  end
end

snd.bgmV2 = {
  current = {},
  next = {},
  silenceTimer = 0,
  source = silentSource
}

---@class MusicInfo
---@field name? string
---@field introName? string
---@field folder? string
---@field extension? string
---@field targetVolume? number
---@field forceRestart? boolean
---@field previousFadeOut? number
---@field fadeSpeed? number
---@field silenceDuration? number

function snd.bgmV2:load(piece_info)
  if not piece_info then
    piece_info = {}
  elseif type(piece_info) == "string" then
    piece_info = {name = piece_info}
  end
  self.next = {
    name = piece_info.name,
    introName = piece_info.introName,
    folder = piece_info.folder or "Sounds/Music/",
    extension = piece_info.extension or ".ogg",
    targetVolume = piece_info.targetVolume or 1,
    forceRestart = piece_info.forceRestart or false,
    previousFadeOut = piece_info.previousFadeOut or 5,
    fadeSpeed = piece_info.fadeSpeed or math.huge,
    silenceDuration = piece_info.silenceDuration or 0
  }
end

function snd.bgmV2.getMusicAndload()
  snd.bgmV2:load(session.getMusic())
end

function snd.bgmV2:pause()
  if self.source and self.source:isPlaying() then
    self.source:pause()
  end
end

function snd.bgmV2:resume()
  if self.source and not self.source:isPlaying() then
    self.source:play()
  end
end

function snd.bgmV2:muffle()
  if self.source then
    self.source:muffle()
  end
end

function snd.bgmV2:unmuffle()
  if self.source then
    self.source:unmuffle()
  end
end

function snd.bgmV2.overrideAndLoad(override_info)
  session.setMusicOverride(override_info)
  snd.bgmV2.getMusicAndload()
end

function snd.bgmV2:update(dt)
  if gs.musicOn then
    -- bgm with intro
    self.source:update(dt)

    -- Count silence time
    if self.source:getVolume() == 0 then self.silenceTimer = self.silenceTimer + dt end
    if self.current.name ~= self.next.name or self.next.forceRestart then
      -- If next piece is different or piece must restart, fade out current, then load next
      fadeToVolume(self.source, 0, self.next.previousFadeOut, dt)
      if self.source:getVolume() == 0 then
        -- Stay silent for a while and then start new piece
        if self.silenceTimer > self.next.silenceDuration then
          playNextSource(self)
        end
      end
    elseif self.current.targetVolume ~= self.next.targetVolume then
      -- If same piece with diff target vol, set new target
      self.current.targetVolume = self.next.targetVolume
    elseif self.source:getVolume() ~= self.current.targetVolume or prevMusicVolume ~= snd.getMusicVolume() then
      -- Fade to target volume
      fadeToVolume(self.source, self.current.targetVolume * snd.getMusicVolume(), self.current.fadeSpeed, dt)
    elseif not self.source:isPlaying() and self.source.shouldBeLooping and self.source.shouldBePlaying then
      -- Hatchet job but fixes looping main stopping for no reason....
      -- self.source.main:rewind()
      -- self.source.main:play()
      self.source:seek(0)
      self.source:play()
    end
  else
    self.source:setVolume(0)
  end
end

return snd
