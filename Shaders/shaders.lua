local shdrs = {}

local function shaderPcall(fieldName, fileName)
  if not fileName then fileName = fieldName end
  if pcall(
    function ()
      shdrs[fieldName] = love.graphics.newShader("Shaders/" .. fileName .. ".fs")
    end
    ) then
    -- Shader works right
      else
    shdrs[fieldName] = nil
  end
end

-- shdrs.playerHitShader = love.graphics.newShader("Shaders/player_damage.fs")
shaderPcall("playerHitShader", "player_damage")
-- shdrs.enemyHitShader = love.graphics.newShader("Shaders/enemy_damage.fs")
shaderPcall("enemyHitShader", "enemy_damage")
-- shdrs.bossDeathShader = love.graphics.newShader("Shaders/boss_death.fs")
shaderPcall("bossDeathShader", "boss_death")
-- shdrs.enemyExplodeShader1 = love.graphics.newShader("Shaders/enemy_explode_shader_1.fs")
shaderPcall("enemyExplodeShader1", "enemy_explode_shader_1")
-- shdrs.enemyExplodeShader2 = love.graphics.newShader("Shaders/enemy_explode_shader_2.fs")
shaderPcall("enemyExplodeShader2", "enemy_explode_shader_2")
-- shdrs.bombRedShader = love.graphics.newShader("Shaders/bomb_red_shader.fs")
shaderPcall("bombRedShader", "bomb_red_shader")
-- shdrs.itemRedShader = love.graphics.newShader("Shaders/item_red_shader.fs")
shaderPcall("itemRedShader", "item_red_shader")
-- shdrs.itemBlueShader = love.graphics.newShader("Shaders/item_blue_shader.fs")
shaderPcall("itemBlueShader", "item_blue_shader")
-- shdrs.itemGreenShader = love.graphics.newShader("Shaders/item_green_shader.fs")
shaderPcall("itemGreenShader", "item_green_shader")
-- shdrs.swordCustomShader = love.graphics.newShader("Shaders/sword_custom_shader.fs")
shaderPcall("swordCustomShader", "sword_custom_shader")
-- shdrs.missileCustomShader = love.graphics.newShader("Shaders/missile_custom_shader.fs")
shaderPcall("missileCustomShader", "missile_custom_shader")
-- shdrs.markCustomShader = love.graphics.newShader("Shaders/mark_custom_shader.fs")
shaderPcall("markCustomShader", "mark_custom_shader")
-- shdrs.swordChargeShader = love.graphics.newShader("Shaders/charge_sword_shader.fs")
shaderPcall("swordChargeShader", "charge_sword_shader")
-- shdrs.blueTunic = love.graphics.newShader("Shaders/blue_tunic.fs")
shaderPcall("blueTunic", "blue_tunic")
-- shdrs.redTunic = love.graphics.newShader("Shaders/red_tunic.fs")
shaderPcall("redTunic", "red_tunic")
-- shdrs.mauveTunic = love.graphics.newShader("Shaders/mauve_tunic.fs")
shaderPcall("mauveTunic", "mauve_tunic")
-- shdrs.customTunic = love.graphics.newShader("Shaders/custom_tunic.fs")
shaderPcall("customTunic", "custom_tunic")

-- Freeze, stone and plant shaders
shaderPcall("frozenShader", "frozen_shader")
shaderPcall("stoneShader", "stone_shader")
shaderPcall("plantShader", "plant_shader")

--
-- shdrs.grayscale = love.graphics.newShader("Shaders/grayscale.fs")
shaderPcall("grayscale")
-- shdrs.sepia = love.graphics.newShader("Shaders/sepia/sepia.fs")
shaderPcall("sepia", "sepia/sepia")
-- shdrs.vignette = love.graphics.newShader("Shaders/vignette/vignette.fs")
shaderPcall("vignette", "vignette/vignette")
-- shdrs.oldScreen = love.graphics.newShader("Shaders/oldScreen.fs")
shaderPcall("oldScreen")
-- shdrs.drugShader = love.graphics.newShader("Shaders/drugShader.fs")
shaderPcall("drugShader")
--
-- shdrs.multiply = love.graphics.newShader("Shaders/multiply.fs")
shaderPcall("multiply")

return shdrs
