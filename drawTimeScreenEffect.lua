local sh = require "scaling_handler"

local cc = COLORCONST

local tr, tg, tb, ta = cc, cc, cc, cc -- target
local cr, cg, cb, ca = tr, tg, tb, ta -- current

local function currentToTarget(dt)
  cr = cr + (tr - cr) * 0.5 * dt
  cg = cg + (tg - cg) * 0.5 * dt
  cb = cb + (tb - cb) * 0.5 * dt
  ca = ca + (ta - ca) * 0.5 * dt
end

local dtse = {}

-- Screen effect funcs
local seFuncs = {
  fullLight = function(tcm, dt)
    tr, tg, tb, ta = cc, cc, cc, cc
    currentToTarget(dt)
  end,

  default = function(tcm, dt)
    -- test
    tr = cc * (0.2 + 0.8 * tcm)
    tg = tr
    tb = cc * (0.8 + 0.2 * tcm)
    ta = cc

    currentToTarget(dt)
  end,
}

function dtse.logic(funcName, dt)

  local curTime = session.save.time
    -- time color modifier
  local tcm = (1 - math.cos( math.pi * (curTime / 12))) * 0.5

  -- debug
  fuck = curTime .. " / " .. tcm

  seFuncs[funcName](tcm, dt, curTime)
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
