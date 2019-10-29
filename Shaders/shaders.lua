local shdrs = {}

shdrs.playerHitShader = love.graphics.newShader("Shaders/player_damage.fs")
shdrs.enemyHitShader = love.graphics.newShader("Shaders/enemy_damage.fs")
shdrs.bossDeathShader = love.graphics.newShader("Shaders/boss_death.fs")
shdrs.enemyExplodeShader1 = love.graphics.newShader("Shaders/enemy_explode_shader_1.fs")
shdrs.enemyExplodeShader2 = love.graphics.newShader("Shaders/enemy_explode_shader_2.fs")
shdrs.itemRedShader = love.graphics.newShader("Shaders/item_red_shader.fs")
shdrs.itemBlueShader = love.graphics.newShader("Shaders/item_blue_shader.fs")
shdrs.itemGreenShader = love.graphics.newShader("Shaders/item_green_shader.fs")
shdrs.swordCustomShader = love.graphics.newShader("Shaders/sword_custom_shader.fs")
shdrs.missileCustomShader = love.graphics.newShader("Shaders/missile_custom_shader.fs")
shdrs.markCustomShader = love.graphics.newShader("Shaders/mark_custom_shader.fs")
shdrs.swordChargeShader = love.graphics.newShader("Shaders/charge_sword_shader.fs")
shdrs.blueTunic = love.graphics.newShader("Shaders/blue_tunic.fs")
shdrs.redTunic = love.graphics.newShader("Shaders/red_tunic.fs")
shdrs.mauveTunic = love.graphics.newShader("Shaders/mauve_tunic.fs")
shdrs.customTunic = love.graphics.newShader("Shaders/custom_tunic.fs")

shdrs.multiply = love.graphics.newShader("Shaders/multiply.fs")

return shdrs
