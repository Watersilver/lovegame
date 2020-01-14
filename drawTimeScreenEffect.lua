local sh = require "scaling_handler"
local piwi = require "piecewise"
local ls = require "lightSources"
local u = require "utilities"
local game = require "game"

local cc = COLORCONST

local tr, tg, tb, ta = cc, cc, cc, cc -- target
local cr, cg, cb, ca = tr, tg, tb, ta -- current

-- canvas
local dw = 5
local dh = dw
local canvW, canvH = 800 + dw*2, 450 + dh*2
local dtsCanvas = love.graphics.newCanvas ( canvW, canvH )


local function currentToTarget(dt)
  cr = u.gradualAdjust(dt, cr, tr)
  cg = u.gradualAdjust(dt, cg, tg)
  cb = u.gradualAdjust(dt, cb, tb)
  ca = u.gradualAdjust(dt, ca, ta)
end

local function connectDomains(position, prevDomain)
  return {value = prevDomain[position].value, closed = not prevDomain[position].closed}
end

local function linearRGBChange(t, domain)
  local r, g, b
  local x = (t - domain.x1.value) / (domain.x2.value - domain.x1.value)
  r = domain.subfunction.startVars[1] + x * (domain.subfunction.endVars[1] - domain.subfunction.startVars[1])
  g = domain.subfunction.startVars[2] + x * (domain.subfunction.endVars[2] - domain.subfunction.startVars[2])
  b = domain.subfunction.startVars[3] + x * (domain.subfunction.endVars[3] - domain.subfunction.startVars[3])
  return r, g, b, cc -- a
end

local prevDomain
local defaultScreenEffects = piwi.new()
-- Day
local dayVars = {cc, cc, cc, cc}
defaultScreenEffects.newSubfunction(
  {x1 = {value = 9, closed = false}, x2 = {value = 15, closed = false}},
  function(curTime)
    return dayVars[1], dayVars[2], dayVars[3], dayVars[4]
  end,
  {startVars = dayVars, endVars = dayVars}
)
local firstDomain = defaultScreenEffects.domains[1]
-- Late day
local lateDayVars = {cc, cc * 0.9, cc * 0.9, cc}
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains("x2", prevDomain), x2 = {value = 18, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = lateDayVars}
)
-- Sunset
local sunsetEndVars = {cc * 0.7, cc * 0.6, cc * 0.65, cc}
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains("x2", prevDomain), x2 = {value = 19, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = sunsetEndVars}
)
-- Twilight start
local twilightStartEndVars = {cc * 0.7, cc * 0.3, cc * 0.5, cc}
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains("x2", prevDomain), x2 = {value = 20, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = twilightStartEndVars}
)
-- Twilight end
local twilightEndEndVars = {cc * 0.3, cc * 0.3, cc * 0.5, cc}
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains("x2", prevDomain), x2 = {value = 21, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = twilightEndEndVars}
)
-- Night 1
local night1Vars = {cc * 0.2, cc * 0.3, cc * 0.5, cc}
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains("x2", prevDomain), x2 = {value = 24, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = night1Vars}
)
-- Night 2
local night2Vars = {cc * 0.3, cc * 0.3, cc * 0.5, cc}
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = {value = 0, closed = true}, x2 = {value = 6, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = night2Vars}
)
-- Dawn start
local dawnStartEndVars = {cc * 0.7, cc * 0.4, cc * 0.5, cc}
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains("x2", prevDomain), x2 = {value = 7, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = dawnStartEndVars}
)
-- Dawn end
local dawnEndEndVars = {cc * 0.7, cc * 0.7, cc * 0.7, cc}
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains("x2", prevDomain), x2 = {value = 8, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = dawnEndEndVars}
)
-- Sunrise
prevDomain = defaultScreenEffects.domains[#defaultScreenEffects.domains]
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains("x2", prevDomain), x2 = {value = 9, closed = true}},
  function(curTime, domain)
    return linearRGBChange(curTime, domain)
  end,
  {startVars = prevDomain.subfunction.endVars, endVars = firstDomain.subfunction.startVars}
)

-- Screen effect funcs
local seFuncs = {
  fullLight = function(curTime, dt)
    tr, tg, tb, ta = cc, cc, cc, cc
    currentToTarget(dt)
  end,

  midnight = function(curTime, dt)
    tr, tg, tb, ta = cc * 0.2, cc * 0.3, cc * 0.5, cc
    currentToTarget(dt)
  end,

  forestMagic = function(curTime, dt)
    tr, tg, tb, ta = cc * 0.5, cc * 0.9, cc * 0.7, cc
    currentToTarget(dt)
  end,

  default = function(curTime, dt)
    tr, tg, tb, ta = defaultScreenEffects.run(curTime)
    currentToTarget(dt)
  end,
}

local dtse = {}

function dtse.logic(funcName, dt)
  seFuncs[funcName](session.save.time, dt)
end

-- The function that draws tse
local function draw()

  -- no canvas draw
  -- local pr, pg, pb, pa = love.graphics.getColor()
  -- local mode, alphamode = love.graphics.getBlendMode()

  -- love.graphics.setColor(cr, cg, cb, ca)
  -- love.graphics.setBlendMode( "multiply" )

  -- love.graphics.rectangle("fill", sh.get_current_window())

  -- love.graphics.setColor(pr, pg, pb, pa)
  -- love.graphics.setBlendMode( mode, alphamode )

  -- canvas draw
  dtsCanvas:renderTo(
    function()
      -- light sources
      love.graphics.clear(cr, cg, cb, ca)
      ls.drawSources(dw, dh)
    end
  )

  local canvX, canvY = sh.get_current_window()

  local pr, pg, pb, pa = love.graphics.getColor()
  local mode, alphamode = love.graphics.getBlendMode()
  love.graphics.setBlendMode( "multiply" )
  love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
  love.graphics.draw(dtsCanvas, canvX - dw, canvY - dw, 0, sh.get_window_scale())
  love.graphics.setColor(pr, pg, pb, pa)
  love.graphics.setBlendMode( mode, alphamode )

end

-- The function that only draws dtse if appropriate
function dtse.draw()
  -- Draw screen effect due to game time
  if game.timeScreenEffect then
    draw()
  else
    -- clear sources for rooms without timeScreenEffects
    ls.clearSources()
  end
end

return dtse
