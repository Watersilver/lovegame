-- Day night lighting cycle function

local newPiecewise = require 'piecewise'
local u = require 'utilities'

local dawn = {
  r = {0, 0, 0.2},
  g = {0, 0.065, 0.2},
  b = {0, 0, 0.3}
}

local sunrise = {
  r = {0.6, 0, 0},
  g = {0.3, 0.4, 0},
  b = {0.3, 0, 0.4}
}

local morning = {
  r = {0.5, 0.5, 0},
  g = {0, 0.7, 0.3},
  b = {0, 0, 0.7}
}

local day = {
  r = {0.9, 0, 0},
  g = {0, 0.9, 0},
  b = {0, 0, 0.9}
}

local midday = {
  r = {1, 1, 0},
  g = {0.2, 1, 0},
  b = {1, 1, 0.6}
}

local afternoon = {
  r = {0.5, 0, 0},
  g = {0, 0.6, 0},
  b = {0, 0, 0.7}
}

local twilight = {
  r = {0.6, 0, 0},
  g = {0.3, 0.3, 0},
  b = {0.5, 0, 0.3}
}

local dusk = {
  r = {0.3, 0, 0.3},
  g = {0, 0.2, 0},
  b = {0.3, 0, 0.3}
}

local moonlessNight = {
  r = {0, 0, 0},
  g = {0, 0, 0},
  b = {0, 0, 0}
}

local night = {
  r = {0, 0, 0.1},
  g = {0, 0.05, 0.1},
  b = {0, 0, 0.1}
}

local fullMoon = {
  r = {0, 0, 0.4},
  g = {0, 0.15, 0.4},
  b = {0, 0, 0.4}
}

local function getNight()
  local moon = session.getMoonPhase()
  if moon == "full" then return fullMoon end
  if moon == 'half' then return night end
  return moonlessNight
end

local daynight1 = newPiecewise({value = 0})
daynight1.newSubfunction(function(_, f)
  return getNight()
end, {value = 5})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(getNight(), dawn, f)
end, {value = 6})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(dawn, sunrise, f)
end, {value = 7})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(sunrise, morning, f)
end, {value = 8})
daynight1.newSubfunction(function(_, f)
  return morning
end, {value = 9})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(morning, day, f)
end, {value = 10})
daynight1.newSubfunction(function(_, f)
  return day
end, {value = 11})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(day, midday, f)
end, {value = 12})
daynight1.newSubfunction(function(_, f)
  return midday
end, {value = 14})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(midday, day, f)
end, {value = 15})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(day, afternoon, f)
end, {value = 17})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(afternoon, twilight, f)
end, {value = 18})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(twilight, dusk, f)
end, {value = 19})
daynight1.newSubfunction(function(_, f)
  return u.rgbLerp(dusk, getNight(), f)
end, {value = 21})
daynight1.newSubfunction(function(_, f)
  return getNight()
end, {value = 24})

return daynight1