local gs = require "game_settings"

local snd = {}

snd.silence = {"Silence"}

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

return snd
