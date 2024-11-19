local text = require "text"
local image = require "image"
local utilities = require "utilities"

local hbar = image.sprites["HUD/healthbar"]
local hfill = image.sprites["HUD/healthbar_fill"] -- 5 frames

local healthText = love.graphics.newText(text.font.tiny)

local hurtCooldown = 0
local prevHealth = 0

---@class HealthDisplayHUD
local health = {}

---@param l number
---@param t number
---@param w number
---@param h number
local function draw(l,t,w,h)

  hurtCooldown = hurtCooldown - delta_time
  if hurtCooldown < 0 then hurtCooldown = 0 end

  love.graphics.draw(hbar.img, hbar[0], l + 8, t + h - 16)
  if pl1 and pl1.exists then

    if prevHealth > pl1.health then
      hurtCooldown = 0.25
    end

    if not pl1.deathState then
      local healthPercent = pl1.health / pl1.maxHealth
      local hfillPixels = math.floor(45 * healthPercent)
      local lastI = 0
      for i = 0, hfillPixels - 1 do
        lastI = i
        local frame = hfill[1]
        if i == hfillPixels - 1 then
          frame = hfill[3]
        end
        if i == hfillPixels - 2 then
          frame = hfill[2]
        end
        if i == 0 then
          frame = hfill[0]
        end
        if hurtCooldown > 0 then
          frame = hfill[4]
        end
        love.graphics.draw(hfill.img, frame, l + 8 + 3 + i, t + h - 16 + 3)
      end

      if healthPercent ~= 1 then
        love.graphics.draw(hfill.img, hfill[4], l + 8 + 3 + lastI, t + h - 16 + 3)
      end

      healthText:set(tostring(math.floor(pl1.health * 10) / 10))

      local textX = l + 8 + 51 / 2 - healthText:getWidth() / 2
      local textY = t + h - 16 + 2

      local resetCol = utilities.storeColour()
      utilities.changeColour{'black'}
      love.graphics.draw(healthText, textX-1, textY)
      love.graphics.draw(healthText, textX+1, textY)
      love.graphics.draw(healthText, textX, textY-1)
      love.graphics.draw(healthText, textX, textY+1)

      resetCol()
      love.graphics.draw(healthText, textX, textY)
    end

    prevHealth = pl1.health
  end
end

---@param l number
---@param t number
---@param w number
---@param h number
function health.draw(l,t,w,h)
  draw(l,t,w,h)
end

return health