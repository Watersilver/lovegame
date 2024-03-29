local verh = require "version_handling"
local id = require "input_defaults"

local input = {}
input.controllers = {}

input.disabledControllers = {}

input.keys = {
  pressed = {},
  prev = {},
  held = {}
}

local player1defaults = id.player1

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
    -- use following if statement if I want to disable controller while transing
    -- if (not controller.disabled) and (not input.transing) then -- WARNING !!!MUST BE NIL, NOT FALSE!!!
    if (not controller.disabled and not controller.blocked) then -- WARNING !!!MUST BE NIL, NOT FALSE!!!
      -- Handle controller if not disabled
      local player = input.current[playername]
      -- Store previous input
      for keyname, isPressed in pairs(player) do
        input.previous[playername][keyname] = isPressed
      end
      -- Check what the current input is and store it
      for name, key in pairs(controller) do
        -- WARNING If I crash here, look at line 29 warning
        player[name] = love.keyboard.isDown(key) == true and 1 or 0
      end
      if input.transing then
        -- disable direction if transing
        player["up"] = 0
        player["down"] = 0
        player["left"] = 0
        player["right"] = 0
      end
    else
      -- Handle controller if disabled
      local player = input.current[playername]
      -- Store previous input
      for keyname, isPressed in pairs(player) do
        input.previous[playername][keyname] = isPressed
      end
      -- Set the current input to inactive
      for name, key in pairs(controller) do
        player[name] = 0
      end
    end
    controller.blocked = nil
  end

  -- Check stuff independent of specific player input
  input.enterPrevious = input.enter
  input.enter = love.keyboard.isDown("return")
  input.enterPressed = input.enter and not input.enterPrevious

  input.escapePrevious = input.escape
  input.escape = love.keyboard.isDown("escape")
  input.escapePressed = input.escape and not input.escapePrevious
  input.escapeBlocked = nil

  input.backspacePrevious = input.backspace
  input.backspace = love.keyboard.isDown("backspace")
  input.backspacePressed = input.backspace and not input.backspacePrevious
  input.backspaceBlocked = nil

  input.cancel = input.escape or input.backspace
  input.cancelPressed = input.escapePressed or input.backspacePressed

  input.upPrevious = input.up
  input.up = love.keyboard.isDown("up")
  input.upPressed = input.up and not input.upPrevious

  input.downPrevious = input.down
  input.down = love.keyboard.isDown("down")
  input.downPressed = input.down and not input.downPrevious

  input.leftPrevious = input.left
  input.left = love.keyboard.isDown("left")
  input.leftPressed = input.left and not input.leftPrevious

  input.rightPrevious = input.right
  input.right = love.keyboard.isDown("right")
  input.rightPressed = input.right and not input.rightPrevious

  input.shiftPrevious = input.shift
  input.shift = love.keyboard.isDown("lshift", "rshift")
  input.shiftPressed = input.shift and not input.shiftPrevious

  for key in string.gmatch("zsxdcvgbhnjmq2w3er5t6y7ui9o", ".") do
    input.keys.prev[key] = input.keys.held[key]
    input.keys.held[key] = love.keyboard.isDown(key)
    input.keys.pressed[key] = input.keys.held[key] and not input.keys.prev[key]
  end
end

function input.disable_controller(playername)
  input.controllers[playername].disabled = true
end

function input.enable_controller(playername)
  input.controllers[playername].disabled = nil
end

if not verh.fileExists("key_config.lua") then
  local inpcontents = love.filesystem.read("input_defaults.lua")
  local newfile = love.filesystem.newFile("key_config.lua")
  newfile:close()
  local success = love.filesystem.write("key_config.lua", inpcontents)
  if not success then love.errhand("Failed to write key_config") end
end

local kc = require "key_config"

input.set_input(kc.player1)

return input
