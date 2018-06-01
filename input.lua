local input = {}
input.controllers = {}

function input.set_input(arg)
  input.controllers.player1 = arg or {
    up = "up",
    down = "down",
    left = "left",
    right = "right"
  }
end

function input.check_input(controller)
  local player = {}
  for name, key in pairs(controller) do
    player[name] = love.keyboard.isDown(key) == true and 1 or 0
  end
  return player
end

input.set_input()

return input
