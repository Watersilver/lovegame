local weather = require 'GameObjects.weather'

-- Day night lighting cycle function

local newPiecewise = require 'piecewise'
local u = require 'utilities'

local dawn = {
  r = {0.75, 0.37, 0.75},
  g = {0.65, 0.5, 0.5},
  b = {0.5, 0, 0.6}
}

local morning = {
  r = {0.7, 0.5, 0.25},
  g = {0, 0.8, 0.7},
  b = {0, 0, 0.95}
}

local day = {
  r = {1, 0, 0},
  g = {0, 1, 0},
  b = {0, 0, 1}
}

local rain = {
  r = {0.44, 0, 0.4},
  g = {0, 0.48, 0},
  b = {0, 0, 0.85}
}

local twilight = {
  r = {0.75, 0, 0},
  g = {0.65, 0.5, 0.5},
  b = {0.5, 0, 0.6}
}

local fullMoon = {
  r = {0.25, 0.8, 1},
  g = {0, 0.5, 0.9},
  b = {0, 0, 1}
}

local night = {
  r = {0, 0, 0.75},
  g = {0, 0.16, 0.75},
  b = {0, 0, 1}
}

local moonlessNight = {
  r = {0, 0, 0.5},
  g = {0, 0, 0.64},
  b = {0, 0, 0.5}
}

local function getWeatherOf(exteriorLight)
  local w = weather:get()
  if math.max(w.rainIntensity, w.snowIntensity) > 0.31 then
    return rain
  else
    return exteriorLight
  end
end

local function getNight()
  local moon = session.getMoonPhase()
  if moon == "full" then return fullMoon end
  if moon == 'half' then return night end
  return moonlessNight
end

-- local chosenTable = 0
-- local wasSwitchPressed = false
-- local l = {
--   {1, 0, 0},
--   {0, 1, 0},
--   {0, 0, 1}
-- }
-- local col = 1
-- local row = 1
-- local function picker()
--   if love.keyboard.isDown('u') then
--     row = 1
--     col = 1
--   elseif love.keyboard.isDown('i') then
--     row = 1
--     col = 2
--   elseif love.keyboard.isDown('o') then
--     row = 1
--     col = 3
--   end
--   if love.keyboard.isDown('j') then
--     row = 2
--     col = 1
--   elseif love.keyboard.isDown('k') then
--     row = 2
--     col = 2
--   elseif love.keyboard.isDown('l') then
--     row = 2
--     col = 3
--   end
--   if love.keyboard.isDown('m') then
--     row = 3
--     col = 1
--   elseif love.keyboard.isDown(',') then
--     row = 3
--     col = 2
--   elseif love.keyboard.isDown('.') then
--     row = 3
--     col = 3
--   end
--   if love.keyboard.isDown("[") then
--     l[row][col] = l[row][col] - 0.5 * delta_time
--     if l[row][col] < 0 then l[row][col] = 0 end
--   elseif love.keyboard.isDown("]") then
--     l[row][col] = l[row][col] + 0.5 * delta_time
--     if l[row][col] > 1 then l[row][col] = 1 end
--   end
--   if love.keyboard.isDown('rshift') then
--     l[row][col] = math.floor(l[row][col] * 100 + 0.5) / 100
--   end
--   if not wasSwitchPressed then
--     if love.keyboard.isDown('-') then
--       chosenTable = chosenTable - 1
--     elseif love.keyboard.isDown('=') then
--       chosenTable = chosenTable + 1
--     end
--   end
--   wasSwitchPressed = love.keyboard.isDown('-') or love.keyboard.isDown('=')
--   chosenTable = chosenTable % 8
--   if chosenTable < 1 then
--     l = rain
--   elseif chosenTable < 2 then
--     l = dawn
--   elseif chosenTable < 3 then
--     l = morning
--   elseif chosenTable < 4 then
--     l = day
--   elseif chosenTable < 5 then
--     l = twilight
--   elseif chosenTable < 6 then
--     l = fullMoon
--   elseif chosenTable < 7 then
--     l = night
--   elseif chosenTable < 8 then
--     l = moonlessNight
--   end
--   l = {l.r, l.g, l.b}
-- end

-- local function c(i, j)
--   if i == row and j == col then
--     return "'" .. tostring(l[i][j]) .. "'"
--   else
--     return tostring(l[i][j])
--   end
-- end

local daynight1 = newPiecewise({value = 0})
-- daynight1.newSubfunction(function(_, f)
--   picker()
--   fuck = 'chosenTable: ' .. tostring(chosenTable) .. '\n'
--   fuck = fuck .. 'u|i|o \n'
--   fuck = fuck .. 'j|k|l \n'
--   fuck = fuck .. 'm|,|. \n'
--   fuck = fuck .. '========= \n'
--   fuck = fuck .. c(1,1) .. "|" .. c(1,2) .. "|" .. c(1,3) .. "\n"
--   fuck = fuck .. c(2,1) .. "|" .. c(2,2) .. "|" .. c(2,3) .. "\n"
--   fuck = fuck .. c(3,1) .. "|" .. c(3,2) .. "|" .. c(3,3) .. "\n"
--   return {
--     r = l[1],
--     g = l[2],
--     b = l[3]
--   }
-- end, {value = 24})

daynight1.newSubfunction(function(_, f)
  return getNight()
end, {value = 5})
daynight1.newSubfunction(function(_, f)
  return getWeatherOf(dawn)
end, {value = 6})
-- daynight1.newSubfunction(function(_, f)
--   return u.rgbLerp(getNight(), morning, f)
-- end, {value = 6})
daynight1.newSubfunction(function(_, f)
  return getWeatherOf(morning)
end, {value = 7})
-- daynight1.newSubfunction(function(_, f)
--   return u.rgbLerp(morning, day, f)
-- end, {value = 8.5})
daynight1.newSubfunction(function(_, f)
  return getWeatherOf(day)
end, {value = 18})
-- daynight1.newSubfunction(function(_, f)
--   return u.rgbLerp(day, twilight, f)
-- end, {value = 18.5})
daynight1.newSubfunction(function(_, f)
  return getWeatherOf(twilight)
end, {value = 20})
-- daynight1.newSubfunction(function(_, f)
--   return u.rgbLerp(twilight, getNight(), f)
-- end, {value = 20})
daynight1.newSubfunction(function(_, f)
  return getNight()
end, {value = 24})

return daynight1