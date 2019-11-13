local gs = require "game_settings"
local im = require "image"
local inp = require "input"
local game = require "game"
local o = require "GameObjects.objects"
local sm = require "state_machine"
local shan = require "scaling_handler"
local quests = require "quests"
local items = require "items"
local u = require "utilities"
local snd = require "sound"

local pam = {}

local moub, moup
function pam.init()
  moub = mouseB
  moup = mouseP
end

-- Button Bounding Boxes (Top menu: For music, sounds and quit game)
-- local bbb = { width = 16, height = 16, separation = 10, xstart = 11, ystart = 11 }
-- for i = 1,3 do
--   -- make horizontally ordered buttons
--   bbb[i] = {}
--   bbb[i].x = {}
--   if i ~= 3 then
--     bbb[i].x.l = bbb.xstart + (i-1)*(bbb.separation * 4 + bbb.width)
--   else
--     bbb[i].x.l = bbb.xstart + 14 * (bbb.separation + bbb.width)
--   end
--   bbb[i].x.r = bbb[i].x.l + bbb.width
--   bbb[i].y = {}
--   bbb[i].y.u = bbb.ystart
--   bbb[i].y.d = bbb[i].y.u + bbb.height
--   -- bbb[button_index][coordinate][side]
-- end
local bbb = {w = 24, h = 5, xs = 5, ys = 5}
bbb[1] = {x = {l = bbb.xs}}
bbb[1].x.r = bbb[1].x.l + bbb.w
bbb[2] = {x = {l = bbb[1].x.r + bbb.xs}}
bbb[2].x.r = bbb[2].x.l + bbb.w
bbb[3] = {x = {l = 377}}
bbb[3].x.r = bbb[3].x.l + bbb.w
bbb.y = {u = bbb.ys, d = bbb.ys + bbb.h}
bbb[1].y = bbb.y
bbb[2].y = bbb.y
bbb[3].y = bbb.y
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
      session.drug = nil
      session.ringShader = nil
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
    love.graphics.setColor(0, 0, 0, COLORCONST * 0.6)
    love.graphics.rectangle("fill", l-1, t-1, w+2, h+2)
    love.graphics.setColor(0, 0, 0, COLORCONST)
    love.graphics.rectangle("fill", l-1, 80, w+2, 44)
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

local function basicListLogic(cursor, list)
  local navButtonPressed = false
  if inp.escapePressed then
    snd.play(glsounds.deselect)
    pam.left.selectedHeader = false
    session.usedItemComment = nil
  end
  local cursorBefore = pam.left[cursor]
  if inp.upPressed then
    pam.left[cursor] = pam.left[cursor] - 1
    navButtonPressed = true
  end
  if inp.downPressed then
    pam.left[cursor] = pam.left[cursor] + 1
    navButtonPressed = true
  end
  -- Keep cursor within bounds
  if #list == 0 then
    pam.left[cursor] = 1
  else
    if pam.left[cursor] < 1 then pam.left[cursor] = #list end
    if pam.left[cursor] > #list then pam.left[cursor] = 1 end
  end
  if cursorBefore ~= pam.left[cursor] and navButtonPressed then
    snd.play(glsounds.cursor)
    session.usedItemComment = nil
  end
end
local logicFuncs = {
  items = function()
    basicListLogic("itemCursor", session.save.items)
    local itemid = session.save.items[pam.left.itemCursor]
    if inp.enterPressed then
      if items[itemid] and items[itemid].use then
        items[itemid].use()
        snd.play(glsounds.useItem)
      else
        snd.play(glsounds.error)
      end
    end
  end,
  quests = function()
    basicListLogic("questCursor", session.save.quests)
  end,
  customise = function()
    if not pam.left.selectedSetting then
      basicListLogic("customiseCursor", pam.left.customise)
      -- Select setting
      if inp.enterPressed then
        if pam.left.customiseCursor == 1 and session.save.playerGlowAvailable or
          pam.left.customiseCursor == 2 and session.save.customTunicAvailable or
          pam.left.customiseCursor == 3 and session.save.customSwordAvailable or
          pam.left.customiseCursor == 4 and session.save.customMissileAvailable or
          pam.left.customiseCursor == 5 and session.save.customMarkAvailable
        then
          snd.play(glsounds.select)
          pam.left.selectedSetting = true
          pam.left.subsettingCursor = 1
          pam.left.subsettingsNumber = 4
        else
          snd.play(glsounds.error)
        end
      end
    else
      if inp.escapePressed then
        snd.play(glsounds.deselect)
        pam.left.selectedSetting = false
      end
      if pam.left.customiseCursor == 1 then
        -- lightStyle
        if inp.upPressed then
          snd.play(glsounds.cursor)
          pam.left.subsettingCursor = pam.left.subsettingCursor - 1
        end
        if inp.downPressed then
          snd.play(glsounds.cursor)
          pam.left.subsettingCursor = pam.left.subsettingCursor + 1
        end
        -- Clamp cursor
        if pam.left.subsettingCursor > pam.left.subsettingsNumber then pam.left.subsettingCursor = 1 end
        if pam.left.subsettingCursor < 1 then pam.left.subsettingCursor = pam.left.subsettingsNumber end
        session.save.playerGlow = pam.left.lightStyles[pam.left.subsettingCursor]
      else
        -- custom Colour
        local subsetting
        if pam.left.customiseCursor == 2 then subsetting = "tunic"
        elseif pam.left.customiseCursor == 3 then subsetting = "sword"
        elseif pam.left.customiseCursor == 4 then subsetting = "missile"
        elseif pam.left.customiseCursor == 5 then subsetting = "mark"
        end
        if inp.upPressed then
          snd.play(glsounds.cursor)
          pam.left.subsettingCursor = pam.left.subsettingCursor - 1
        end
        if inp.downPressed then
          snd.play(glsounds.cursor)
          pam.left.subsettingCursor = pam.left.subsettingCursor + 1
        end
        -- Clamp cursor
        if pam.left.subsettingCursor > pam.left.subsettingsNumber then pam.left.subsettingCursor = 1 end
        if pam.left.subsettingCursor < 1 then pam.left.subsettingCursor = pam.left.subsettingsNumber end
        if pam.left.subsettingCursor == 1 then
          if inp.leftPressed or inp.rightPressed then
            snd.play(glsounds.cursor)
            session.save["custom".. u.capitalise(subsetting) .."Enabled"] = not session.save["custom".. u.capitalise(subsetting) .."Enabled"]
          end
        else
          local colour
          if pam.left.subsettingCursor == 2 then colour = "R"
          elseif pam.left.subsettingCursor == 3 then colour = "G"
          elseif pam.left.subsettingCursor == 4 then colour = "B"
          end
          if inp.leftPressed then
            local colorBefore = session.save[subsetting .. colour]
            local addend = - 0.01 * (inp.shift and 10 or 1)
            session.save[subsetting .. colour] = u.clamp(0, session.save[subsetting .. colour] + addend, 1)
            if colorBefore ~= session.save[subsetting .. colour] then snd.play(glsounds.cursor) end
          elseif inp.rightPressed then
            local colorBefore = session.save[subsetting .. colour]
            local addend = 0.01 * (inp.shift and 10 or 1)
            session.save[subsetting .. colour] = u.clamp(0, session.save[subsetting .. colour] + addend, 1)
            if colorBefore ~= session.save[subsetting .. colour] then snd.play(glsounds.cursor) end
          end
        end
      end
    end
  end,
}


local function recolor(w, h, subsetting)
  local pr, pg, pb, pa = love.graphics.getColor()
  love.graphics.setColor(COLORCONST*0.4, COLORCONST*0.7, COLORCONST, COLORCONST*0.2)
  love.graphics.rectangle("fill", 0, (pam.left.subsettingCursor - 1) * 10, w, 10)
  love.graphics.setColor(pr, pg, pb, pa)
  love.graphics.print("Enabled: " .. (session.save["custom" .. u.capitalise(subsetting) .. "Enabled"] and "Yes" or "No"), 5, 5, 0, 0.15)
  love.graphics.print("Red: " .. string.format("%03d", session.save[subsetting .. "R"] * 100), 5, 15, 0, 0.15)
  love.graphics.print("Green: " .. string.format("%03d", session.save[subsetting .. "G"] * 100), 5, 25, 0, 0.15)
  love.graphics.print("Blue: " .. string.format("%03d", session.save[subsetting .. "B"] * 100), 5, 35, 0, 0.15)
  love.graphics.print("(Hold shift to change values faster)", 5, 45, 0, 0.1)
end
local settingsTooltipFuncs = {
  lightStyle = function(w, h)
    local currentStyle = (session.save.playerGlow or "None"):gsub("player", "")
    love.graphics.polygon("line", w*0.5, 5, w*0.5-3, 10, w*0.5+3, 10)
    love.graphics.polygon("line", w*0.5, h - 5, w*0.5-3, h - 10, w*0.5+3, h - 10)
    local txtWd2 = love.graphics.getFont():getWidth(currentStyle) * 0.075
    love.graphics.print(currentStyle, w*0.5 - txtWd2, 25, 0, 0.15)
  end,

  recolor = function(w, h, subsetting)
    love.graphics.print("Enabled: " .. session.save["custom" .. u.capitalise(subsetting) .. "Enabled"] and "Yes" or "No", 5, 5, 0, 0.15)
    love.graphics.print("Red: " .. session.save[subsetting .. "R"], 5, 15, 0, 0.15)
    love.graphics.print("Green: " .. session.save[subsetting .. "G"], 5, 25, 0, 0.15)
    love.graphics.print("Blue: " .. session.save[subsetting .. "B"], 5, 35, 0, 0.15)
  end,

  tunic = function(w, h)
    recolor(w, h, "tunic")
  end,

  sword = function(w, h)
    recolor(w, h, "sword")
  end,

  missile = function(w, h)
    recolor(w, h, "missile")
  end,

  mark = function(w, h)
    recolor(w, h, "mark")
  end,
}

local tooltipFuncs = {
  headers = function()
    pam.left.tooltip = pam.left.headerDesc[pam.left.headers[pam.left.headerCursor]]
  end,

  items = function()
    local itemid = session.save.items[pam.left.itemCursor]
    if session.usedItemComment then
      pam.left.tooltip = session.usedItemComment
    elseif itemid then
      if items[itemid] and items[itemid].description then
        pam.left.tooltip = items[itemid].description
      else
        pam.left.tooltip = "No data..."
      end
    end
  end,

  quests = function()
    local questid = session.save.quests[pam.left.questCursor]
    local queststage = session.save[questid]
    if questid then
      if queststage and quests[questid] and quests[questid].description and quests[questid].description[queststage] then
        pam.left.tooltip = quests[questid].description[queststage]
      else
        pam.left.tooltip = "No data..."
      end
    end
  end,

  customise = function()
    local setting = pam.left.customise[pam.left.customiseCursor]
    if pam.left.selectedSetting then
      pam.left.tooltip = settingsTooltipFuncs[setting]
    else
      if setting == "lightStyle" then
        if session.save.playerGlowAvailable then
          pam.left.tooltip = "Customise light style."
        else
          pam.left.tooltip = "???"
        end
      elseif setting == "tunic" then
        if session.save.customTunicAvailable then
          pam.left.tooltip = "Customise " .. setting .. " colour."
        else
          pam.left.tooltip = "???"
        end
      elseif setting == "sword" then
        if session.save.customTunicAvailable then
          pam.left.tooltip = "Customise " .. setting .. " colour."
        else
          pam.left.tooltip = "???"
        end
      elseif setting == "missile" then
        if session.save.customTunicAvailable then
          pam.left.tooltip = "Customise " .. setting .. " colour."
        else
          pam.left.tooltip = "???"
        end
      elseif setting == "mark" then
        if session.save.customTunicAvailable then
          pam.left.tooltip = "Customise " .. setting .. " colour."
        else
          pam.left.tooltip = "???"
        end
      end
    end
  end
}

local function drawTransparentBox(w, h)
  local pr, pg, pb, pa = love.graphics.getColor()
  love.graphics.setColor(0, 0, 0, COLORCONST*0.3)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0, 0, 0, COLORCONST*0.5)
  love.graphics.rectangle("line", 0, 0, w, h)
  love.graphics.setColor(pr, pg, pb, pa)
end

local drawFuncs = {
  headers = function(w, h, pamleft)
    local hwidth = 50
    local hdist = 17
    local pr, pg, pb, pa = love.graphics.getColor()

    local x = 0
    for i = 1, pamleft.headerCursor - 1 do
      love.graphics.setColor(0, COLORCONST*0.2, COLORCONST*0.5, COLORCONST)
      love.graphics.rectangle("fill", x, 0, hwidth, h)
      love.graphics.setColor(COLORCONST*0.5, COLORCONST*0.5, COLORCONST*0.5, COLORCONST)
      love.graphics.rectangle("line", x, 0, hwidth, h)
      local header = pamleft.headers[i]
      local txtWd2 = love.graphics.getFont():getWidth(header) * 0.1
      love.graphics.print(header, x + hwidth*0.5 - txtWd2, h*0.5-2, 0, 0.2)
      x = x + hdist
    end

    local x = (#pamleft.headers - 1) * hdist
    for i = #pamleft.headers, pamleft.headerCursor + 1, -1 do
      love.graphics.setColor(0, COLORCONST*0.2, COLORCONST*0.5, COLORCONST)
      love.graphics.rectangle("fill", x, 0, hwidth, h)
      love.graphics.setColor(COLORCONST*0.5, COLORCONST*0.5, COLORCONST*0.5, COLORCONST)
      love.graphics.rectangle("line", x, 0, hwidth, h)
      local header = pamleft.headers[i]
      local txtWd2 = love.graphics.getFont():getWidth(header) * 0.1
      love.graphics.print(header, x + hwidth*0.5 - txtWd2, h*0.5-2, 0, 0.2)
      x = x - hdist
    end

    local x = (pamleft.headerCursor - 1) * hdist
    if pamleft.selectedHeader then
      love.graphics.setColor(COLORCONST*0.6, COLORCONST*0.1, COLORCONST*0.5, COLORCONST)
    else
      love.graphics.setColor(COLORCONST*0.1, COLORCONST*0.4, COLORCONST*0.7, COLORCONST)
    end
    love.graphics.rectangle("fill", x, 0, hwidth, h)
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
    love.graphics.rectangle("line", x, 0, hwidth, h)
    local header = pamleft.headers[pamleft.headerCursor]
    local txtWd2 = love.graphics.getFont():getWidth(header) * 0.1
    love.graphics.print(header, x + hwidth*0.5 - txtWd2, h*0.5-2, 0, 0.2)

    love.graphics.setColor(pr, pg, pb, pa)
  end,

  items = function(w, h, pamleft)
    local textScale = 0.2
    local padding = 2
    local scrollBarWidth = 5
    local scrollBarX = w - scrollBarWidth
    drawTransparentBox(w, h)
    if session.save.items[1] then
      local t, ih = pamleft.itemTop, love.graphics.getFont():getHeight() * textScale + 2 * padding
      for iindex, itemid in ipairs(session.save.items) do
        local pr, pg, pb, pa = love.graphics.getColor()
        love.graphics.setColor(0, 0, 0, COLORCONST*0.5)
        if session.save.equippedRing == itemid then
          love.graphics.setColor(COLORCONST*0.7, COLORCONST*0.4, COLORCONST, COLORCONST*0.2)
          love.graphics.rectangle("fill", 0, t, scrollBarX, ih)
        elseif pamleft.itemCursor == iindex then
          love.graphics.setColor(COLORCONST*0.4, COLORCONST*0.7, COLORCONST, COLORCONST*0.2)
          love.graphics.rectangle("fill", 0, t, scrollBarX, ih)
        elseif iindex % 2 == 0 then
          love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST*0.05)
          love.graphics.rectangle("fill", 0, t, scrollBarX, ih)
        end
        love.graphics.setColor(pr, pg, pb, pa)
        local iname = items[itemid] and items[itemid].name or "no data..."
        love.graphics.print(iname, padding, padding + t, 0, textScale)
        local inameWidth = love.graphics.getFont():getWidth(iname) * textScale
        local duplicates = session.save[itemid] or "?"
        love.graphics.print(" x" .. duplicates, padding + inameWidth, padding + t, 0, textScale)
        t = t + ih
      end
      -- Determine itemTop
      if pamleft.itemTop + pam.left.itemCursor * ih - ih <= 0 then
        pamleft.itemTop = -(pam.left.itemCursor * ih - ih)
      elseif pamleft.itemTop + pam.left.itemCursor * ih > h then
        pamleft.itemTop = -(pam.left.itemCursor * ih - h)
      end

      local itemNumInv = 1 / #session.save.items
      local scrollBarPos = (pamleft.itemCursor - 1) * itemNumInv
      local pr, pg, pb, pa = love.graphics.getColor()
      love.graphics.setColor(0, 0, 0, COLORCONST*0.3)
      love.graphics.line(scrollBarX, 0, scrollBarX, h)
      love.graphics.setColor(pr, pg, pb, pa)
      love.graphics.rectangle("fill", w-5, h*scrollBarPos, 5, h*itemNumInv)
    else
      love.graphics.print("No items.", padding, padding, 0, textScale)
    end
  end,

  quests = function(w, h, pamleft)
    local textScale = 0.2
    local padding = 2
    local scrollBarWidth = 5
    local scrollBarX = w - scrollBarWidth
    drawTransparentBox(w, h)
    if session.save.quests[1] then
      local t, qh = pamleft.questTop, love.graphics.getFont():getHeight() * textScale + 2 * padding
      for qindex, questid in ipairs(session.save.quests) do
        local pr, pg, pb, pa = love.graphics.getColor()
        love.graphics.setColor(0, 0, 0, COLORCONST*0.5)
        if pamleft.questCursor == qindex then
          love.graphics.setColor(COLORCONST*0.4, COLORCONST*0.7, COLORCONST, COLORCONST*0.2)
          love.graphics.rectangle("fill", 0, t, scrollBarX, qh)
        elseif qindex % 2 == 0 then
          love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST*0.05)
          love.graphics.rectangle("fill", 0, t, scrollBarX, qh)
        end
        love.graphics.setColor(pr, pg, pb, pa)
        local qtitle = quests[questid] and quests[questid].title or "no data..."
        love.graphics.print(qtitle, padding, padding + t, 0, textScale)
        t = t + qh
      end
      -- Determine questTop
      if pamleft.questTop + pam.left.questCursor * qh - qh <= 0 then
        pamleft.questTop = -(pam.left.questCursor * qh - qh)
      elseif pamleft.questTop + pam.left.questCursor * qh > h then
        pamleft.questTop = -(pam.left.questCursor * qh - h)
      end

      local questNumInv = 1 / #session.save.quests
      local scrollBarPos = (pamleft.questCursor - 1) * questNumInv
      local pr, pg, pb, pa = love.graphics.getColor()
      love.graphics.setColor(0, 0, 0, COLORCONST*0.3)
      love.graphics.line(scrollBarX, 0, scrollBarX, h)
      love.graphics.setColor(pr, pg, pb, pa)
      love.graphics.rectangle("fill", w-5, h*scrollBarPos, 5, h*questNumInv)
    else
      love.graphics.print("No quests.", padding, padding, 0, textScale)
    end
  end,

  customise = function(w, h, pamleft)
    local textScale = 0.2
    local paddingHor = 2
    local paddingVert = 5.3
    local t, sh = 0, love.graphics.getFont():getHeight() * textScale + 2 * paddingVert
    drawTransparentBox(w, h)
    for i, setting in ipairs(pamleft.customise) do
      local pr, pg, pb, pa = love.graphics.getColor()
      if pamleft.customiseCursor == i then
        if pamleft.selectedSetting then
          love.graphics.setColor(COLORCONST*0.7, COLORCONST*0.4, COLORCONST, COLORCONST*0.2)
          love.graphics.rectangle("fill", 0, t, w, sh)
        else
          love.graphics.setColor(COLORCONST*0.4, COLORCONST*0.7, COLORCONST, COLORCONST*0.2)
          love.graphics.rectangle("fill", 0, t, w, sh)
        end
      elseif i % 2 == 0 then
        love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST*0.05)
        love.graphics.rectangle("fill", 0, t, w, sh)
      end
      love.graphics.setColor(pr, pg, pb, pa)
      if setting == "lightStyle" then
        if session.save.playerGlowAvailable then
          love.graphics.print("Light Style", paddingHor, paddingVert + t, 0, textScale)
        else
          love.graphics.print("???", paddingHor, paddingVert + t, 0, textScale)
        end
      elseif setting == "tunic" then
        if session.save.playerGlowAvailable then
          love.graphics.print("Tunic Colour", paddingHor, paddingVert + t, 0, textScale)
        else
          love.graphics.print("???", paddingHor, paddingVert + t, 0, textScale)
        end
      elseif setting == "sword" then
        if session.save.playerGlowAvailable then
          love.graphics.print("Sword Colour", paddingHor, paddingVert + t, 0, textScale)
        else
          love.graphics.print("???", paddingHor, paddingVert + t, 0, textScale)
        end
      elseif setting == "missile" then
        if session.save.playerGlowAvailable then
          love.graphics.print("Missile Colour", paddingHor, paddingVert + t, 0, textScale)
        else
          love.graphics.print("???", paddingHor, paddingVert + t, 0, textScale)
        end
      elseif setting == "mark" then
        if session.save.playerGlowAvailable then
          love.graphics.print("Mark Colour", paddingHor, paddingVert + t, 0, textScale)
        else
          love.graphics.print("???", paddingHor, paddingVert + t, 0, textScale)
        end
      end
      t = t + sh
    end
  end,

  tooltip = function(w, h, pamleft)
    local pr, pg, pb, pa = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, COLORCONST*0.3)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(0, 0, 0, COLORCONST*0.5)
    love.graphics.rectangle("line", 0, 0, w, h)
    love.graphics.setColor(pr, pg, pb, pa)
    if type(pamleft.tooltip) == "function" then
      pamleft.tooltip(w, h)
    else
      love.graphics.print(pamleft.tooltip, 5, 5, 0, 0.15)
    end
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
  headers = {"items", "quests", "customise"},
  headerDesc = {items = "List of items\nin your possession", quests = "A list of active quests", customise = "Visual customisation\noptions"},
  selectedHeader = false,
  questCursor = 1,
  questTop = 0,
  tooltip = "",
  customise = {"lightStyle", "tunic", "sword", "missile", "mark"},
  customiseCursor = 1,
  selectedSetting = false,
  lightStyles = {"playerTorch", "playerGlow", "playerSpotlight"},
  itemTop = 0,
  itemCursor = 1,
}
function pam.left.initCursors()
  pam.left.headerCursor = 1
  pam.left.selectedHeader = false
  pam.left.questCursor = 1
  pam.left.questTop = 0
  pam.left.customiseCursor = 1
  pam.left.selectedSetting = false
  pam.left.itemTop = 0
  pam.left.itemCursor = 1
end
pam.left.logic = function()
  if pam.quitting then return end
  if not pam.left.selectedHeader then
    if inp.enterPressed then
      snd.play(glsounds.select)
      pam.left.selectedHeader = true
    end
    if inp.leftPressed then
      snd.play(glsounds.cursor)
      pam.left.headerCursor = pam.left.headerCursor - 1
      if pam.left.headerCursor < 1 then pam.left.headerCursor = #pam.left.headers end
    end
    if inp.rightPressed then
      snd.play(glsounds.cursor)
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
  local deadSpaceX, deadSpaceY = shan.get_current_window()
  local hudScale = shan.get_window_scale() * 2

  local sl, sw = 33, 100 -- scissor left, scissor width
  local ht, hh = 66, 7 -- header top & height
  local bt, bh = ht + hh, 77  -- body top & height
  local tt, th = bt + bh, 55 -- tooltip top & height
  drawScissoredArea(sl, ht, sw, hh, deadSpaceX, deadSpaceY, hudScale, "headers", pam.left)
  drawScissoredArea(sl, bt, sw, bh, deadSpaceX, deadSpaceY, hudScale, pam.left.headers[pam.left.headerCursor], pam.left)
  drawScissoredArea(sl, tt, sw, th, deadSpaceX, deadSpaceY, hudScale, "tooltip", pam.left)
end

return pam
