local gs = require "game_settings"

local snd = {}

snd.silence = {"Silence"}
snd.ovrwrld1 = {day = {name = "zelOverworld", introName = "zelOverworldIntro"}, night = "nightTest"}

snd.sounds = {}
snd.bgm = {} -- Background Music
snd.bgs = nil -- Background Sound

local soundsToBePlayed = {}

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

-- Doesn't actually play the sound, just adds it to soundsToBePlayed table
function snd.play(sound)
  -- Make sure I don't add a sound twice
  sound:stop()
  for _, soundFromTable in ipairs(soundsToBePlayed) do
    if sound == soundFromTable then return end
  end
  table.insert(soundsToBePlayed, sound)
end

-- Used in the main update every frame to play soundsToBePlayed
function snd.play_soundsToBePlayed()
  for i, sound in ipairs(soundsToBePlayed) do
    if gs.soundsOn then sound:play() end
    soundsToBePlayed[i] = nil
  end
end

function snd.bgm:load(music_info, force_replay, just_load)
  if not music_info then self.next = nil; return end
  self.last_loaded_music_info = music_info
  local next_name = music_info.name or music_info[1]
  local next_extension = music_info.extension or ".ogg"
  local next_folder = music_info.folder or "Sounds/"
  self.nextName = next_folder .. next_name .. next_extension
  self.next = love.audio.newSource( self.nextName, "stream" )
  self.next:setLooping(true)
  snd.bgm:setFadeState(music_info.fadeType, self.next)
  self.onTransitionEnd = music_info.onTransitionEnd or false
  if self.current and not just_load then
    if force_replay or (self.currentName ~= self.nextName) then
      self.current:stop()
      self.current = nil
    end
  end
end

-- Used in main update
function snd.bgm:update(dt)
  -- If current song doesn't exist, play next
  if not self.current then
    -- If next doesn't exist either do nothing
    if not self.next then return end
    -- If music is off do nothing
    if not gs.musicOn then return end
    self.current = self.next
    self.currentName = self.nextName
    self.current:play()
  else
    if not gs.musicOn then
      self.current:stop()
      -- delete current and reset next so I can resume music that's cut off.
      self.next = self.current
      self.current = nil
    end
  end
  snd.bgm:handleFade(dt)
end

function snd.bgm:setFadeState(newFadeState, source)
  source = source or self.current
  self.fadeState = {}
  if source then
    if newFadeState == "fadeout" then
      self.fadeState.fading = true
      self.fadeState.targetVolume = 0
      self.fadeState.timer = 0
      self.fadeState.duration = 2
      self.fadeState.startingVolume = source:getVolume()
    end
  end
end

function snd.bgm:handleFade(dt)
  if self.fadeState.fading and self.current then
    self.fadeState.timer = self.fadeState.timer + dt
    if self.fadeState.timer > self.fadeState.duration then
      self.fadeState.timer = self.fadeState.duration
      self.fadeState.fading = nil
      self.current:setVolume(self.fadeState.targetVolume)
      return
    end
    local volMod = self.fadeState.timer / self.fadeState.duration
    local newVol = self.fadeState.startingVolume + (self.fadeState.targetVolume - self.fadeState.startingVolume) * volMod
    self.current:setVolume(newVol)
  end
end


-- BGM ver2
local silentSource = {
  getVolume = function() return 0 end,
  isPlaying = function() return false end,
  setLooping = function() end,
  setVolume = function() end,
  play = function() end,
  stop = function() end,
  update = function() end,
}

-- bgm with intro
local bgmV2Source = {
  setLooping = function(self, bool)
    self.main:setLooping(bool)
  end,
  isPlaying = function(self)
    return self[self.section]:isPlaying()
  end,
  play = function(self)
    self[self.section]:play()
    self.stopped = false
  end,
  stop = function(self)
    self[self.section]:stop()
    self.section = self.intro and "intro" or "main"
    self.stopped = true
  end,
  setVolume = function(self, vol)
    self[self.section]:setVolume(vol)
  end,
  getVolume = function(self)
    return self[self.section]:getVolume()
  end
}
bgmV2Source.new = function(sourceInfo)
  if sourceInfo.introName then
    bgmV2Source.intro = love.audio.newSource( sourceInfo.folder .. sourceInfo.introName .. sourceInfo.extension, "stream" )
    bgmV2Source.section = "intro"
  else
    bgmV2Source.intro = nil
    bgmV2Source.section = "main"
  end
  bgmV2Source.main = love.audio.newSource( sourceInfo.folder .. sourceInfo.name .. sourceInfo.extension, "stream" )
  return bgmV2Source
end
bgmV2Source.update = function(dt)
  if bgmV2Source.section == "intro" then
    if not bgmV2Source.intro:isPlaying() then
      bgmV2Source.section = "main"
      bgmV2Source.main:setVolume(bgmV2Source.intro:getVolume())
      bgmV2Source.main:play()
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

    bgmv2.source:setLooping(true)
    bgmv2.source:setVolume(0)
    bgmv2.source:play()
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

function snd.bgmV2.overrideAndLoad(override_info)
  session.setMusicOverride(override_info)
  snd.bgmV2.getMusicAndload()
end

function snd.bgmV2:update(dt)
  if gs.musicOn then
    -- bgm with intro
    self.source.update(dt)

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
    elseif self.source:getVolume() ~= self.current.targetVolume then
      -- Fade to target volume
      fadeToVolume(self.source, self.current.targetVolume, self.current.fadeSpeed, dt)
    end
  else
    self.source:setVolume(0)
  end
end

return snd
