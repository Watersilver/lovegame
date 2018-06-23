id = require "input_defaults"

local input = {}
input.controllers = {}

local player1defaults = id.player1defaults

function input.set_input(arg)
  input.controllers.player1 = arg or player1defaults

  input.current = {}
  input.previous = {}
  for playername, playerkeyset in pairs(input.controllers) do
    input.current[playername] = {}
    input.previous[playername] = {}
    for keyname, _ in pairs(playerkeyset) do
      input.current[playername][keyname] = 0
      input.previous[playername][keyname] = 0
    end
  end
end

function input.check_input()
  local controllers = input.controllers
  for playername, controller in pairs(controllers) do
    local player = input.current[playername]
    -- Store previous input
    for keyname, isPressed in pairs(player) do
      input.previous[playername][keyname] = isPressed
    end
    -- Check what the current input is and store it
    for name, key in pairs(controller) do
      player[name] = love.keyboard.isDown(key) == true and 1 or 0
    end
  end
end

input.set_input()

return input
