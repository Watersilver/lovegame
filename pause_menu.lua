local gs = require "game_settings"
local inp = require "input"
local game = require "game"
local o = require "GameObjects.objects"

local pam = {}

local moub, moup
function pam.init()
  moub = mouseB
  moup = mouseP
end

-- Button Bounding Boxes
local bbb = { width = 16, height = 16, separation = 10, xstart = 11, ystart = 11}
for i = 1,3 do
  -- make horizontally ordered buttons
  bbb[i] = {}
  bbb[i].x = {}
  bbb[i].x.l = bbb.xstart + (i-1)*(bbb.separation + bbb.width)
  bbb[i].x.r = bbb[i].x.l + bbb.width
  bbb[i].y = {}
  bbb[i].y.u = bbb.ystart
  bbb[i].y.d = bbb[i].y.u + bbb.height
  --- bbb[button_index][coordinate][side]
end
local function checkIfInBBB(x, y)
  if y > bbb[1].y.u and y < bbb[1].y.d then
    for bindex, box in ipairs(bbb) do
      if x > box.x.l and x < box.x.r then
        return bindex
      end
    end
  end
  return 0
end
function pam.logic()
  if moub["1press"] then
    local bindex = checkIfInBBB(Hud:toWorld(moup.x, moup.y))
    if bindex == 1 then
      gs.musicOn = not gs.musicOn
    elseif bindex == 2 then
      gs.soundsOn = not gs.soundsOn
    elseif bindex == 3 then
      pam.quitting = true
    end
  end
  if pam.quitting then
    inp.disable_controller("player1")
    if inp.enterPressed then
      pam.quitting = nil
      if o.identified.PlayaTest and o.identified.PlayaTest[1] then
        o.identified.PlayaTest[1].transPersistent = nil
      end
      game.transition{
        type = "whiteScreen",
        progress = 0,
        roomTarget = "Rooms/main_menu.lua"
      }
    elseif inp.escapePressed then
      pam.quitting = nil
    end
  else
    inp.enable_controller("player1")
  end
end

function pam.draw(l,t,w,h)
  local pr, pg, pb, pa = love.graphics.getColor()
  local alpha = COLORCONST
  if not gs.musicOn then alpha = 0.5 * COLORCONST end
  love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, alpha)
  love.graphics.print("Music", bbb[1].x.l, bbb[1].y.u, 0, 0.2)
  alpha = COLORCONST
  if not gs.soundsOn then alpha = 0.5 * COLORCONST end
  love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, alpha)
  love.graphics.print("Sound", bbb[2].x.l, bbb[2].y.u, 0, 0.2)
  alpha = COLORCONST
  love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
  love.graphics.print("Quit", bbb[3].x.l, bbb[3].y.u, 0, 0.2)
  if pam.quitting then
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
    love.graphics.print("Are you sure you want to quit?\n\zYes(Enter)   No(Escape)", 22, 88, 0, 0.5)
  end
  love.graphics.setColor(pr, pg, pb, pa)
end

return pam
