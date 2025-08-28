local verh = require "version_handling"
local id = require "input_defaults"
local u = require "utilities"

local input = {}
input.controllers = {}

input.disabledControllers = {}

input.keys = {
  pressed = {},
  prev = {},
  held = {}
}

local mergedJoystick = {
  --- Bottom face button (A).
  a = false,
  --- Right face button (B).
  b = false,
  --- Left face button (X).
  x = false,
  --- Top face button (Y).
  y = false,
  --- Back button.
  back = false,
  --- Guide button.
  guide = false,
  --- Start button.
  start = false,
  --- Left stick click button.
  leftstick = false,
  --- Right stick click button.
  rightstick = false,
  --- Left bumper.
  leftshoulder = false,
  --- Right bumper.
  rightshoulder = false,
  --- D-pad up.
  dpup = false,
  --- D-pad down.
  dpdown = false,
  --- D-pad left.
  dpleft = false,
  --- D-pad right.
  dpright = false,
}
local function falsifyMergedJoystick()
  for key in pairs(mergedJoystick) do
    mergedJoystick[key] = false
  end
end
local function isActionDownGamepad(key)
  if key == "start" then
    return mergedJoystick.start and 1 or 0
  elseif key == "c" then -- sword
    return not mergedJoystick.leftshoulder and mergedJoystick.x and 1 or 0
  elseif key == "x" then -- jump
    return not mergedJoystick.leftshoulder and mergedJoystick.a and 1 or 0
  elseif key == "z" then -- missile
    return not mergedJoystick.leftshoulder and mergedJoystick.b and 1 or 0
  elseif key == "d" then -- mark
    return mergedJoystick.leftshoulder and mergedJoystick.b and 1 or 0
  elseif key == "s" then -- recall
    return mergedJoystick.leftshoulder and mergedJoystick.y and 1 or 0
  elseif key == "a" then -- grab
    return mergedJoystick.leftshoulder and mergedJoystick.a and 1 or 0
  elseif key == "q" then -- mdust
    return not mergedJoystick.leftshoulder and mergedJoystick.y and 1 or 0
  elseif key == "w" then -- dash
    return mergedJoystick.rightshoulder and 1 or 0
  elseif key == "e" then -- bomb
    return mergedJoystick.leftshoulder and mergedJoystick.x and 1 or 0
  elseif type(key) == "number" then -- hotkeys
    -- TODO: (1 - 8 possible using one axis)
  else
    return mergedJoystick["dp" .. key] and 1 or 0
  end
end

function input.set_input(arg)
  input.controllers.player1 = u.initializeTable(arg or id.player1, id.player1)

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

  falsifyMergedJoystick()

  ---@type love.Joystick[]
  local joysticks = love.joystick.getJoysticks()

  for _, js in ipairs(joysticks) do
    if js:isGamepad() then
      for key, isDown in pairs(mergedJoystick) do
        mergedJoystick[key] = isDown or js:isGamepadDown(key)
      end
    end
  end

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

        -- Enable joypad for player one
        if playername == "player1" then
          player[name] = player[name] == 1 and 1 or isActionDownGamepad(key)
        end
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
      for name in pairs(controller) do
        player[name] = 0
      end
    end
    controller.blocked = nil
  end

  -- Check stuff independent of specific player input
  input.enterPrevious = input.enter
  input.enter = love.keyboard.isDown("return") or mergedJoystick.start
  input.enterPressed = input.enter and not input.enterPrevious

  input.escapePrevious = input.escape
  input.escape = love.keyboard.isDown("escape") or mergedJoystick.leftshoulder and mergedJoystick.back
  input.escapePressed = input.escape and not input.escapePrevious
  input.escapeBlocked = nil

  input.backspacePrevious = input.backspace
  input.backspace = love.keyboard.isDown("backspace") or not mergedJoystick.leftshoulder and mergedJoystick.back
  input.backspacePressed = input.backspace and not input.backspacePrevious
  input.backspaceBlocked = nil

  input.cancel = input.escape or input.backspace
  input.cancelPressed = input.escapePressed or input.backspacePressed

  input.upPrevious = input.up
  input.up = love.keyboard.isDown("up") or mergedJoystick.dpup
  input.upPressed = input.up and not input.upPrevious

  input.downPrevious = input.down
  input.down = love.keyboard.isDown("down") or mergedJoystick.dpdown
  input.downPressed = input.down and not input.downPrevious

  input.leftPrevious = input.left
  input.left = love.keyboard.isDown("left") or mergedJoystick.dpleft
  input.leftPressed = input.left and not input.leftPrevious

  input.rightPrevious = input.right
  input.right = love.keyboard.isDown("right") or mergedJoystick.dpright
  input.rightPressed = input.right and not input.rightPrevious

  input.shiftPrevious = input.shift
  input.shift = love.keyboard.isDown("lshift", "rshift") or mergedJoystick.leftstick
  input.shiftPressed = input.shift and not input.shiftPrevious

  -- TODO: Gamepad
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
---@diagnostic disable-next-line: undefined-field
  if not success then love.errorhandler("Failed to write key_config") end
else
  -- Fill empty defaults
  local kc = require "key_config"
  local indef = require "input_defaults"
  for player, inp in pairs(indef) do
    if kc[player] == nil then
      kc[player] = inp
    else
      for action, key in pairs(inp) do
        if kc[player][action] == nil then
          kc[player][action] = key
        end
      end
    end
  end
end

local kc = require "key_config"

input.set_input(kc.player1)

return input
