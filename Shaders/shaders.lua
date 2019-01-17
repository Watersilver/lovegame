local shdrs = {}

shdrs.playerHitShader = love.graphics.newShader("Shaders/player_damage.fs")
shdrs.enemyHitShader = love.graphics.newShader("Shaders/enemy_damage.fs")

return shdrs
