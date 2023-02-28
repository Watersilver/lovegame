---@type table<string, love.Shader>
local shdrs = {}

local function shaderPcall(fieldName, fileName)
  if not fileName then fileName = fieldName end
  local s, err = pcall(
    function ()
      shdrs[fieldName] = love.graphics.newShader("Shaders/" .. fileName .. ".fs")
    end
  )
  if err ~= nil then
    print(err)
    shdrs[fieldName] = nil
  end
end

shaderPcall("playerHitShader", "player_damage")
shaderPcall("enemyHitShader", "enemy_damage")
shaderPcall("bossDeathShader", "boss_death")
shaderPcall("boss4angry", "boss4angry")
shaderPcall("enemyExplodeShader1", "enemy_explode_shader_1")
shaderPcall("enemyExplodeShader2", "enemy_explode_shader_2")
shaderPcall("bombRedShader", "bomb_red_shader")
shaderPcall("itemRedShader", "item_red_shader")
shaderPcall("itemBlueShader", "item_blue_shader")
shaderPcall("itemGreenShader", "item_green_shader")
shaderPcall("swordCustomShader", "sword_custom_shader")
shaderPcall("missileCustomShader", "missile_custom_shader")
shaderPcall("markCustomShader", "mark_custom_shader")
shaderPcall("swordChargeShader", "charge_sword_shader")
shaderPcall("blueTunic", "blue_tunic")
shaderPcall("redTunic", "red_tunic")
shaderPcall("mauveTunic", "mauve_tunic")
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
