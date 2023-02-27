local game = require 'game'
local daynight1 = require 'ScreenEffects.lighting.daynight1'

---@type table<string, {table?: {r: number[], g: number[], b: number[]}, determine: fun(): {r: number[], g: number[], b: number[]}}>
local ambientTable = {
  black = {
    table = {
      r = {0,0,0,1},
      g = {0,0,0,1},
      b = {0,0,0,1}
    }
  },
  dull = {
    table = {
      r = {0.3, 0, 0.3, 1},
      g = {0, 0.7, 0.3, 1},
      b = {0, 0, 0.7, 1}
    }
  },
  forestCurse1 = {
    table = {
      r = {0.2, 0, 0, 1},
      g = {0.2, 0.05, 0, 1},
      b = {0, 0, 0.2, 1}
    }
  },
  forestMagic = {
    table = {
      r = {0.5, 0.1, 0, 1},
      g = {0, 1, 0, 1},
      b = {0, 0.2, 0.7, 1}
    }
  },
  midnight = {
    table = {
      r = {0.05, 0, 0.1, 1},
      g = {0, 0.1, 0, 1},
      b = {0, 0, 0.1, 1}
    }
  },
  cozy = {
    table = {
      r = {0.7, 0.1, 0, 1},
      g = {0, 0.6, 0, 1},
      b = {0, 0, 0.5, 1}
    }
  },
  fullLight = {
    table = {
      r = {1, 0, 0, 1},
      g = {0, 1, 0, 1},
      b = {0, 0, 1, 1}
    }
  },
  daynight1 = {
    determine = function() return daynight1.call(session.save.time) end
  }
}

---@return { r: number[], g: number[], b: number[] }
local function determineAmbient()

  local t = game.room.ambientLightType

  if type(t) == 'table' then return t end

  if type(t) == 'function' then return t() end

  local a = ambientTable[t]

  if not a then return ambientTable.fullLight.table end

  if a.table then return a.table end

  return a.determine()
end

return determineAmbient
