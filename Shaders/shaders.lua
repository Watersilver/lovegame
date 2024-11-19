local function createShader(fileName)
  ---@type love.Shader|nil
  local shdr = nil
  local _, err = pcall(
    function ()
      shdr = love.graphics.newShader("Shaders/" .. fileName .. ".fs")
    end
  )
  if err ~= nil then print(err) end
  return shdr, err
end

local shdrs = {
  playerHitShader = createShader("player_damage"),
  bossDeathShader = createShader("boss_death"),
  enemyHitShader = createShader("enemy_damage"),
  boss4angry = createShader("boss4angry"),
  enemyExplodeShader1 = createShader("enemy_explode_shader_1"),
  enemyExplodeShader2 = createShader("enemy_explode_shader_2"),
  bombRedShader = createShader("bomb_red_shader"),
  itemRedShader = createShader("item_red_shader"),
  itemBlueShader = createShader("item_blue_shader"),
  itemGreenShader = createShader("item_green_shader"),
  swordCustomShader = createShader("sword_custom_shader"),
  missileCustomShader = createShader("missile_custom_shader"),
  markCustomShader = createShader("mark_custom_shader"),
  swordChargeShader = createShader("charge_sword_shader"),
  customTunic = createShader("custom_tunic"),
  grayscale = createShader("grayscale"),
  sepia = createShader("sepia/sepia"),
  vignette = createShader("vignette/vignette"),
  oldScreen = createShader("oldScreen"),
  drugShader = createShader("drugShader"),
  multiply = createShader("multiply"),

  -- Freeze, stone and plant shaders
  frozenShader = createShader("frozen_shader"),
  stoneShader = createShader("stone_shader"),
  plantShader = createShader("plant_shader"),
}

return shdrs
