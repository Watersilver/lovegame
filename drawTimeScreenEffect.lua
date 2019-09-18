local sh = require "scaling_handler"
local piwi = require "piecewise"

local cc = COLORCONST

local tr, tg, tb, ta = cc, cc, cc, cc -- target
local cr, cg, cb, ca = tr, tg, tb, ta -- current

local function currentToTarget(dt)
  cr = cr + (tr - cr) * 0.5 * dt
  cg = cg + (tg - cg) * 0.5 * dt
  cb = cb + (tb - cb) * 0.5 * dt
  ca = ca + (ta - ca) * 0.5 * dt
end

local function connectDomains(prevDomain)
  return {value = prevDomain.x2.value, closed = not prevDomain.x2.closed}
end

local defaultScreenEffects = piwi.new()
defaultScreenEffects.newSubfunction(
  {x1 = {value = 8, closed = false}, x2 = {value = 18, closed = false}},
  function(tcm)
    fuck = tcm .. "/ DAYum"
    return cc, cc, cc, cc
  end,
  {name = "day"}
)
local defDay = defaultScreenEffects.namedDomains.day
defaultScreenEffects.newSubfunction(
  {x1 = connectDomains(defDay), x2 = {value = 24, closed = true}},
  function(curTime)
    -- time color modifier
    local tcm = (1 - math.cos( math.pi * (curTime / 12))) * 0.5
    local r, g, b, a
    r = cc * (0.2 + 0.8 * tcm)
    g = r
    b = cc * (0.8 + 0.2 * tcm)
    a = cc
    fuck = "connected"
    return r, g, b, a
  end
)
defaultScreenEffects.newSubfunction(
  {x1 = {value = 0, closed = true}, x2 = {value = defDay.x1.value, closed = not defDay.x1.closed}},
  function(curTime)
    -- time color modifier
    local tcm = (1 - math.cos( math.pi * (curTime / 12))) * 0.5
    local r, g, b, a
    r = cc * (0.2 + 0.8 * tcm)
    g = r
    b = cc * (0.8 + 0.2 * tcm)
    a = cc
    fuck = r
    return r, g, b, a
  end
)

-- Screen effect funcs
local seFuncs = {
  fullLight = function(curTime, dt)
    tr, tg, tb, ta = cc, cc, cc, cc
    currentToTarget(dt)
  end,

  default = function(curTime, dt)
    -- test
    -- tr = cc * (0.2 + 0.8 * tcm)
    -- tg = tr
    -- tb = cc * (0.8 + 0.2 * tcm)
    -- ta = cc
    tr, tg, tb, ta = defaultScreenEffects.run(curTime)

    currentToTarget(dt)
  end,
}

local dtse = {}

function dtse.logic(funcName, dt)
  seFuncs[funcName](session.save.time, dt)
end

function dtse.draw()

  local pr, pg, pb, pa = love.graphics.getColor()
  local mode, alphamode = love.graphics.getBlendMode()

  love.graphics.setColor(cr, cg, cb, ca)
  love.graphics.setBlendMode( "multiply" )
  -- love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
  love.graphics.rectangle("fill", sh.get_current_window())

  love.graphics.setColor(pr, pg, pb, pa)
  love.graphics.setBlendMode( mode, alphamode )

end

return dtse
