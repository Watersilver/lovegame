local gs = require "game_settings"
local im = require "image"
local inp = require "input"
local game = require "game"
local o = require "GameObjects.objects"
local sm = require "state_machine"
local sh = require "scaling_handler"
local quests = require "quests"
local u = require "utilities"

local pam = {}

local moub, moup
function pam.init()
  moub = mouseB
  moup = mouseP
end

-- Button Bounding Boxes (Top menu: For music, sounds and quit game)
local bbb = { width = 16, height = 16, separation = 10, xstart = 11, ystart = 11 }
for i = 1,3 do
  -- make horizontally ordered buttons
  bbb[i] = {}
  bbb[i].x = {}
  bbb[i].x.l = bbb.xstart + (i-1)*(bbb.separation + bbb.width)
  bbb[i].x.r = bbb[i].x.l + bbb.width
  bbb[i].y = {}
  bbb[i].y.u = bbb.ystart
  bbb[i].y.d = bbb[i].y.u + bbb.height
  -- bbb[button_index][coordinate][side]
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
function pam.top_menu_logic()
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

function pam.top_menu_draw(l,t,w,h)
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

-- Middle menu (Sword skill, magic skill, armor, godessUpgrades)
-- armor in middle, surrounded by triforce with three counters for
-- sword shield and mobility on top.
pam.middle = {
  triforceSprite = im.sprites["Menu/menuTriforce"],
  tunicSprite = im.sprites["tunics"],
  swordSkillSprite = im.sprites["swordSkill"],
  missileSkillSprite = im.sprites["missileSkill"],
  mobilitySkillSprite = im.sprites["mobilitySkill"],
}
pam.middle.draw = function(l, t, w, h)

  local trifx, trify = w * 0.5, h * 0.5 - 8
  local triforceSprite = pam.middle.triforceSprite
  -- power
  love.graphics.draw(
    triforceSprite.img, triforceSprite[session.save.dinsPower and 1 or 0],
    trifx, trify - triforceSprite.cy, 0,
    triforceSprite.res_x_scale, triforceSprite.res_y_scale,
    triforceSprite.cx, triforceSprite.cy)
  -- wisdom
  love.graphics.draw(
    triforceSprite.img, triforceSprite[session.save.nayrusWisdom and 2 or 0],
    trifx - triforceSprite.cx, trify + triforceSprite.cy, 0,
    triforceSprite.res_x_scale, triforceSprite.res_y_scale,
    triforceSprite.cx, triforceSprite.cy)
  -- courage
  love.graphics.draw(
    triforceSprite.img, triforceSprite[session.save.faroresCourage and 3 or 0],
    trifx + triforceSprite.cx, trify + triforceSprite.cy, 0,
    triforceSprite.res_x_scale, triforceSprite.res_y_scale,
    triforceSprite.cx, triforceSprite.cy)

  local upgrx, upgry = w * 0.5, h * 0.28
  -- draw upgrade box
  local pr, pg, pb, pa = love.graphics.getColor()
  love.graphics.setColor(0, 0, 0, COLORCONST*0.3)
  love.graphics.rectangle("fill", upgrx - 40, upgry - 11, 80, 22)
  love.graphics.setColor(0, 0, 0, COLORCONST*0.5)
  love.graphics.rectangle("line", upgrx - 40, upgry - 11, 80, 22)
  love.graphics.setColor(pr, pg, pb, pa)

  -- sword
  local swordSkillSprite = pam.middle.swordSkillSprite
  love.graphics.draw(
    swordSkillSprite.img, swordSkillSprite[session.save.swordLvl or 0],
    upgrx - 2 * swordSkillSprite.width+4, upgry, 0,
    swordSkillSprite.res_x_scale, swordSkillSprite.res_y_scale,
    swordSkillSprite.cx, swordSkillSprite.cy)
  -- magic
  local missileSkillSprite = pam.middle.missileSkillSprite
  love.graphics.draw(
    missileSkillSprite.img, missileSkillSprite[session.save.magicLvl or 0],
    upgrx - swordSkillSprite.width+4, upgry, 0,
    missileSkillSprite.res_x_scale, missileSkillSprite.res_y_scale,
    missileSkillSprite.cx, missileSkillSprite.cy)
  -- mobility
  local mobilitySkillSprite = pam.middle.mobilitySkillSprite
  love.graphics.draw(
    mobilitySkillSprite.img, mobilitySkillSprite[session.save.athleticsLvl or 0],
    upgrx + swordSkillSprite.width-4, upgry, 0,
    mobilitySkillSprite.res_x_scale, mobilitySkillSprite.res_y_scale,
    mobilitySkillSprite.cx, mobilitySkillSprite.cy)
  -- tunic
  local tunicSprite = pam.middle.tunicSprite
  love.graphics.draw(
    tunicSprite.img, tunicSprite[session.save.armorLvl or 0],
    upgrx + 2 * swordSkillSprite.width-4, upgry, 0,
    tunicSprite.res_x_scale, tunicSprite.res_y_scale,
    tunicSprite.cx, tunicSprite.cy)

  -- Title
  love.graphics.print("UPGRADES", w * 0.405, h * 0.18, 0, 0.4, 0.4)
end


local logicFuncs = {
  quests = function()
    if inp.escapePressed then
      pam.left.selectedHeader = false
    end
    if inp.upPressed then
      pam.left.questCursor = pam.left.questCursor - 1
      if pam.left.questCursor < 1 then pam.left.questCursor = u.tablelength(session.save.quests) end
    end
    if inp.downPressed then
      pam.left.questCursor = pam.left.questCursor + 1
      if pam.left.questCursor > u.tablelength(session.save.quests) then pam.left.questCursor = 1 end
    end
  end,
  customise = function()
    if inp.escapePressed then
      pam.left.selectedHeader = false
    end
  end,
}

local tooltipFuncs = {
  headers = function()
    pam.left.tooltip = pam.left.headerDesc[pam.left.headerCursor]
  end,

  quests = function()
    local qindex = 1
    for questid, queststage in pairs(session.save.quests) do
      if pam.left.questCursor == qindex then
        if quests[questid] and quests[questid].description and quests[questid].description[queststage] then
          pam.left.tooltip = quests[questid].description[queststage]
        else
          pam.left.tooltip = "No data..."
        end
      end
      qindex = qindex + 1
    end
  end
}

local drawFuncs = {
  headers = function(w, h, pamleft)
    local hwidth = 50
    local hdist = 17
    local pr, pg, pb, pa = love.graphics.getColor()

    local x = (#pamleft.headers - 1) * hdist
    for i = #pamleft.headers, 1, -1 do
      if i ~= pamleft.headerCursor then
        love.graphics.setColor(0, COLORCONST*0.2, COLORCONST*0.5, COLORCONST)
        love.graphics.rectangle("fill", x, 0, hwidth, h)
        love.graphics.setColor(COLORCONST*0.5, COLORCONST*0.5, COLORCONST*0.5, COLORCONST)
        love.graphics.rectangle("line", x, 0, hwidth, h)
        love.graphics.setColor(111, 111, 111, COLORCONST)
        local header = pamleft.headers[i]
        local txtWd2 = love.graphics.getFont():getWidth(header) * 0.1
        love.graphics.print(header, x + hwidth*0.5 - txtWd2, h*0.5-2, 0, 0.2)
      end
      x = x - hdist
    end
    x = (#pamleft.headers - 1) * hdist
    for i = #pamleft.headers, 1, -1 do
      if i == pamleft.headerCursor then
        if pamleft.selectedHeader then
          love.graphics.setColor(COLORCONST*0.6, COLORCONST*0.1, COLORCONST*0.5, COLORCONST)
        else
          love.graphics.setColor(COLORCONST*0.1, COLORCONST*0.4, COLORCONST*0.7, COLORCONST)
        end
        love.graphics.rectangle("fill", x, 0, hwidth, h)
        love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
        love.graphics.rectangle("line", x, 0, hwidth, h)
        local header = pamleft.headers[i]
        local txtWd2 = love.graphics.getFont():getWidth(header) * 0.1
        love.graphics.print(header, x + hwidth*0.5 - txtWd2, h*0.5-2, 0, 0.2)
      end
      x = x - hdist
    end

    love.graphics.setColor(pr, pg, pb, pa)
  end,

  quests = function(w, h, pamleft)
    local textScale = 0.2
    local padding = 2
    if next(session.save.quests) then
      local pr, pg, pb, pa = love.graphics.getColor()
      love.graphics.setColor(0, 0, 0, COLORCONST*0.3)
      love.graphics.rectangle("fill", 0, 0, w, h)
      love.graphics.setColor(0, 0, 0, COLORCONST*0.5)
      love.graphics.rectangle("line", 0, 0, w, h)
      love.graphics.setColor(pr, pg, pb, pa)
      local t, qh = pamleft.questTop, love.graphics.getFont():getHeight() * textScale + 2 * padding
      local qindex = 1
      for questid, queststage in pairs(session.save.quests) do
        local pr, pg, pb, pa = love.graphics.getColor()
        love.graphics.setColor(0, 0, 0, COLORCONST*0.5)
        love.graphics.rectangle("line", 0, t, w-5, qh)
        if pamleft.questCursor == qindex then
          love.graphics.setColor(COLORCONST*0.4, COLORCONST*0.7, COLORCONST, COLORCONST*0.2)
          love.graphics.rectangle("fill", 0, t, w-5, qh)
        end
        love.graphics.setColor(pr, pg, pb, pa)
        local qtitle = quests[questid] and quests[questid].title or "no data..."
        love.graphics.print(qtitle, padding, padding + t, 0, textScale)
        t = t + qh
        qindex = qindex + 1
      end
      -- Determine questTop
      if pamleft.questTop + pam.left.questCursor * qh - qh <= 0 then
        pamleft.questTop = -(pam.left.questCursor * qh - qh)
      elseif pamleft.questTop + pam.left.questCursor * qh > h then
        pamleft.questTop = -(pam.left.questCursor * qh - h)
      end

      local questNumInv = 1 / u.tablelength(session.save.quests)
      local scrollBarPos = (pamleft.questCursor - 1) * questNumInv
      -- local pr, pg, pb, pa = love.graphics.getColor()
      -- love.graphics.setColor(0, 0, 0, COLORCONST*0.3)
      love.graphics.rectangle("fill", w-5, h*scrollBarPos, 5, h*questNumInv)
      -- love.graphics.setColor(pr, pg, pb, pa)
    else
      love.graphics.print("No quests.", padding, padding, 0, textScale)
    end
  end,

  tooltip = function(w, h, pamleft)
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, COLORCONST*0.3)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(0, 0, 0, COLORCONST*0.5)
    love.graphics.rectangle("line", 0, 0, w, h)
    love.graphics.setColor(pr, pg, pb, pa)
    love.graphics.print(pamleft.tooltip, 5, 5, 0, 0.15)
  end
}

local function drawScissoredArea(l, t, w, h, dsX, dsY, scale, drawFunc, pamleft)
  -- Remember graphic settings
  love.graphics.push()

  -- Set new origin
  love.graphics.translate(l, t)

  -- Set scissor. Dead space is screen pixels. New origin must be scaled.
  love.graphics.setScissor(
    l * scale + dsX, t * scale + dsY,
    w * scale, h * scale
  )

  -- Draw the thing I want to draw within 0, 0, sciW, sciH.
  if drawFuncs[drawFunc] then drawFuncs[drawFunc](w, h, pamleft) end
  -- * * * * * * * * * * * * * * * * * * * * * * * * * * *

  -- Reset scissor
  love.graphics.setScissor()

  -- Restore graphic settings
  love.graphics.pop()
end

-- Left menu (quest list, settings, item list)
pam.left = {
  headerCursor = 1,
  headers = {"quests", "customise"},
  headerDesc = {"A list of active quests", "Visual customisation\noptions"},
  selectedHeader = false,
  questCursor = 1,
  questTop = 0,
  selectedQuest = false, -- don't know if I will use
  tooltip = ""
}
pam.left.logic = function()
  if not pam.left.selectedHeader then
    if inp.enterPressed then
      pam.left.selectedHeader = true
    end
    if inp.leftPressed then
      pam.left.headerCursor = pam.left.headerCursor - 1
      if pam.left.headerCursor < 1 then pam.left.headerCursor = #pam.left.headers end
    end
    if inp.rightPressed then
      pam.left.headerCursor = pam.left.headerCursor + 1
      if pam.left.headerCursor > #pam.left.headers then pam.left.headerCursor = 1 end
    end
    tooltipFuncs.headers()
  else
    local header = pam.left.headers[pam.left.headerCursor]
    if logicFuncs[header] then logicFuncs[header]() end
    if tooltipFuncs[header] then tooltipFuncs[header]() end
  end
end
pam.left.draw = function(l, t, w, h)
  local deadSpaceX, deadSpaceY = sh.get_current_window()
  local hudScale = sh.get_window_scale() * 2

  local sl, sw = 33, 100 -- scissor left, scissor width
  local ht, hh = 66, 7 -- header top & height
  local bt, bh = ht + hh, 77  -- body top & height
  local tt, th = bt + bh, 55 -- tooltip top & height
  drawScissoredArea(sl, ht, sw, hh, deadSpaceX, deadSpaceY, hudScale, "headers", pam.left)
  drawScissoredArea(sl, bt, sw, bh, deadSpaceX, deadSpaceY, hudScale, pam.left.headers[pam.left.headerCursor], pam.left)
  drawScissoredArea(sl, tt, sw, th, deadSpaceX, deadSpaceY, hudScale, "tooltip", pam.left)
end

return pam
