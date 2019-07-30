local shdrs = {}

shdrs.playerHitShader = love.graphics.newShader("Shaders/player_damage.fs")
shdrs.enemyHitShader = love.graphics.newShader("Shaders/enemy_damage.fs")
shdrs.bossDeathShader = love.graphics.newShader("Shaders/boss_death.fs")
shdrs.enemyExplodeShader1 = love.graphics.newShader("Shaders/enemy_explode_shader_1.fs")
shdrs.enemyExplodeShader2 = love.graphics.newShader("Shaders/enemy_explode_shader_2.fs")

return shdrs
