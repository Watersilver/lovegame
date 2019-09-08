local shdrs = {}

shdrs.playerHitShader = love.graphics.newShader("Shaders/player_damage.fs")
shdrs.enemyHitShader = love.graphics.newShader("Shaders/enemy_damage.fs")
shdrs.bossDeathShader = love.graphics.newShader("Shaders/boss_death.fs")
shdrs.enemyExplodeShader1 = love.graphics.newShader("Shaders/enemy_explode_shader_1.fs")
shdrs.enemyExplodeShader2 = love.graphics.newShader("Shaders/enemy_explode_shader_2.fs")
shdrs.itemRedShader = love.graphics.newShader("Shaders/item_red_shader.fs")
shdrs.itemBlueShader = love.graphics.newShader("Shaders/item_blue_shader.fs")
shdrs.itemGreenShader = love.graphics.newShader("Shaders/item_green_shader.fs")
shdrs.itemGreenShader = love.graphics.newShader("Shaders/item_green_shader.fs")
shdrs.swordChargeShader = love.graphics.newShader("Shaders/charge_sword_shader.fs")

return shdrs
