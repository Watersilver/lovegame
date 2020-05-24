local ps = require "physics_settings"
local u = require "utilities"

local clamp = u.clamp

-- To be used in check_walk_while_walking function
local walktable = {
  down =
  {
    first_check = {check1 = "walk_right", check2 = "walk_down", result = "rightwalk", },
    second_check = {check1 = "walk_left", check2 = "walk_down", result = "leftwalk", },
    third_check = {check1 = "walk_up", result = "upwalk", },
    fourth_check = {check1 = "walk_down" }
  },
  right =
  {
    first_check = {check1 = "walk_down", check2 = "walk_right", result = "downwalk", },
    second_check = {check1 = "walk_up", check2 = "walk_right", result = "upwalk", },
    third_check = {check1 = "walk_left", result = "leftwalk", },
    fourth_check = {check1 = "walk_right" }
  },
  left =
  {
    first_check = {check1 = "walk_down", check2 = "walk_left", result = "downwalk", },
    second_check = {check1 = "walk_up", check2 = "walk_left", result = "upwalk", },
    third_check = {check1 = "walk_right", result = "rightwalk", },
    fourth_check = {check1 = "walk_left" }
  },
  up =
  {
    first_check = {check1 = "walk_right", check2 = "walk_up", result = "rightwalk", },
    second_check = {check1 = "walk_left", check2 = "walk_up", result = "leftwalk", },
    third_check = {check1 = "walk_down", result = "downwalk", },
    fourth_check = {check1 = "walk_up" }
  }
}

-- To be used to determine modifiers because of viscosity
local viscosityTable = {
  water = function(object, brakes, inversemaxspeed)
    inversemaxspeed = inversemaxspeed * 2
    brakes = brakes * 2
    return brakes, inversemaxspeed
  end,

  grass = function(object, brakes, inversemaxspeed)
    inversemaxspeed = inversemaxspeed * 2
    brakes = brakes * 2
    return brakes, inversemaxspeed
  end,

  ladder = function(object, brakes, inversemaxspeed)
    inversemaxspeed = inversemaxspeed * 4
    brakes = brakes * 100
    return brakes, inversemaxspeed
  end,

  stairs = function(object, brakes, inversemaxspeed)
    if object.vy < -0.1 then
      inversemaxspeed = inversemaxspeed * 3
      brakes = brakes * 2
    elseif object.vy > 0.1 then
      inversemaxspeed = inversemaxspeed * 2
      brakes = brakes * 2
    end
    return brakes, inversemaxspeed
  end,
}

-- To be used in check_carry_while_carrying function
local carrytable = {
  down =
  {
    first_check = {check1 = "walk_right", check2 = "walk_down", result = "rightlifted", },
    second_check = {check1 = "walk_left", check2 = "walk_down", result = "leftlifted", },
    third_check = {check1 = "walk_up", result = "uplifted", },
    fourth_check = {check1 = "walk_down" }
  },
  right =
  {
    first_check = {check1 = "walk_down", check2 = "walk_right", result = "downlifted", },
    second_check = {check1 = "walk_up", check2 = "walk_right", result = "uplifted", },
    third_check = {check1 = "walk_left", result = "leftlifted", },
    fourth_check = {check1 = "walk_right" }
  },
  left =
  {
    first_check = {check1 = "walk_down", check2 = "walk_left", result = "downlifted", },
    second_check = {check1 = "walk_up", check2 = "walk_left", result = "uplifted", },
    third_check = {check1 = "walk_right", result = "rightlifted", },
    fourth_check = {check1 = "walk_left" }
  },
  up =
  {
    first_check = {check1 = "walk_right", check2 = "walk_up", result = "rightlifted", },
    second_check = {check1 = "walk_left", check2 = "walk_up", result = "leftlifted", },
    third_check = {check1 = "walk_down", result = "downlifted", },
    fourth_check = {check1 = "walk_up" }
  }
}

-- inputForceFuncs
local iff = {
  keyboardInput = function(myinput, direction, mass, mobility)
    local normx, normy =
      u.normalize2d(myinput.right - myinput.left, myinput.down - myinput.up)
    return normx * mass * mobility, normy * mass * mobility
  end,

  analogueInput = function(myinput, direction, mass, mobility)
    if direction then
      return math.cos(direction) * mass * mobility, math.sin(direction) * mass * mobility
    else
      return 0, 0
    end
  end
}

local universalWalk = function(object, dt, inputForceFunc)
  local myinput = object.input
  local direction = object.direction
  local mass = object.body:getMass()
  local mobility = object.mobility or 600
  local brakes = object.brakes or 6
  local brakesLim = object.brakesLim or 10
  local floorFriction = object.floorFriction or 1 -- How slippery the floor is.
  local normalisedSpeed = object.normalisedSpeed or 1
  local maxspeed = object.maxspeed or 50

  if object.player then
    mobility, brakes = session.getAthlectics()
    maxspeed = session.getMaxSpeed()
    if object.animation_state.state == "sprint" then
      maxspeed = maxspeed * 2
      mobility = mobility * 100
    end
  end

  local inversemaxspeed = 1/(maxspeed * normalisedSpeed) -- could be inf, don't worry

  -- if on ground check how floor affects movement
  if object.zo == 0 or object.actAszo0 then
    if floorFriction < 1 then
      mobility = mobility * floorFriction
      brakes = brakes * floorFriction
    end
    if object.floorViscosity then
      brakes, inversemaxspeed = viscosityTable[object.floorViscosity](object, brakes, inversemaxspeed)
    end
    if not session.save.dinsPower and object.liftedOb and object.liftedOb.lifterSpeedMod then
      inversemaxspeed = inversemaxspeed / object.liftedOb.lifterSpeedMod
    end
  else
    brakes = 0
    if object.player and not session.save.nayrusWisdom then mobility = mobility / 3 end
    if object.floorViscosity then
      -- When on the air certain viscocities still affect movement
      -- (The ones that exist because of height differences)
      -- Handle them here
      if object.floorViscosity == "ladder" then
        if object.vy < 0 then
          inversemaxspeed = inversemaxspeed * 8
          -- Recalculate breaks, because they're zero!!
          brakes = (object.brakes or 6) * 100
        end
      elseif object.floorViscosity == "stairs" then
        if object.vy < -0.1 then
          inversemaxspeed = inversemaxspeed * 3
          -- Recalculate breaks, because they're zero!!
          brakes = (object.brakes or 6) * 3
        end
      end
    end
  end
  -- High brakes values cause funkyness. This is here to avoid that
  brakes = clamp(0, brakes, brakesLim)
  -- As do high inversemaxspeed values
  inversemaxspeed = clamp(0, inversemaxspeed, 0.08) -- lowest max speed = 12.5
  -- As do high mobility values
  -- mobility = clamp(0, mobility, 1000) -- old value
  mobility = clamp(0, mobility, 3000)

  -- Calculate force due to input
  local infx, infy = iff[inputForceFunc](myinput, direction, mass, mobility)

  -- Calculate friction force
  local ffx, ffy = object.vx, object.vy
  if infx == 0 and infy == 0 then
    -- This friction is for when you're actively trying to break
    -- Used when there is no input
    if brakes > brakesLim then brakes = brakesLim end
    ffx = - ffx * mass * brakes
    ffy = - ffy * mass * brakes
  else
    -- This friction will ensure you don't get over maxspeed
    -- Used when there is input
    ffx = - ffx * mass * mobility * inversemaxspeed
    ffy = - ffy * mass * mobility * inversemaxspeed
  end

  object.body:applyForce(infx, infy)
  object.body:applyForce(ffx, ffy)
end

local mo = {}

  local sqrt = math.sqrt
  local abs = math.abs
  local sign = u.sign

  function  mo.test_movement(object, dt)
    local _, gravity = ps.pw:getGravity()
    local mass = object.body:getMass()
    local myinput = object.input
    object.body:applyForce((myinput.right-myinput.left)*mass*500,
    myinput.down-myinput.up*gravity*0.5)
    if not object.jumplimit then object.jumplimit = 0 end
    if object.jumplimit == 0 then
      object.body:applyLinearImpulse(0, -myinput.up*mass*200)
      if myinput.up == 1 then object.jumplimit = 180 end
    end
    object.jumplimit = object.jumplimit - 60 * dt
    if object.jumplimit < 1 then object.jumplimit = 0 end
  end

  mo.top_down = {

    walk = function(object, dt)
      universalWalk(object, dt, "keyboardInput")
    end,

    sprint = function(object, dt)
      object.direction = object.sprintDir
      universalWalk(object, dt, "analogueInput")
    end,

    analogueWalk = function(object, dt)
      universalWalk(object, dt, "analogueInput")
    end,

    stand_still = function(object, dt)
      if object.zo ~= 0 then return end
      local mass = object.body:getMass()
      local _ -- mobility dummy
      local brakes = object.brakes or 6
      local brakesLim = object.brakesLim or 10
      local floorFriction = object.floorFriction or 1 -- How slippery the floor is.

      if object.player then
        _, brakes = session.getAthlectics()
      end

      if floorFriction < 1 then
        brakes = brakes * floorFriction
      end
      if object.floorViscosity then
        brakes = viscosityTable[object.floorViscosity](object, brakes, 0)
      end
      -- High brakes values cause funkyness. This is here to avoid that
      brakes = clamp(0, brakes, brakesLim)

      -- Calculate friction force
      local ffx, ffy = object.vx, object.vy
      ffx = - ffx * mass * brakes
      ffy = - ffy * mass * brakes

      object.body:applyForce(ffx, ffy)
    end,


    image_speed = function(object, dt, speedMod)
      local floorFriction = object.floorFriction or 1
      local image_speed = 0.13 * object.speed/80--100 looks alright too.
      -- take into account different number of frames (assume there are four frames)
      -- local framemod = speedMod or (object.sprite.frames)*0.25
      -- image_speed = image_speed * framemod
      if floorFriction < 1 then
        image_speed = image_speed * 1/floorFriction
      end
      if image_speed > 0.3 then image_speed = 0.3 end
      object.image_speed = image_speed
    end,


    zAxisPlayer = function(object, dt)
      -- different from zAxis because player also has jo (jump offset) for cam purposes
      object.jo = object.jo - object.zvel * dt
      if object.jo >= 0 then
        object.jo = 0
        object.fo = object.fo - object.zvel * dt
        if object.fo >= 0 then
          object.fo = 0
          object.zvel = 0
        else
          object.zvel = object.zvel - object.gravity * dt
        end
      else
        object.zvel = object.zvel - object.gravity * dt
      end
      object.zo = object.jo + object.fo
    end,


    zAxis = function(object, dt)
      object.zo = object.zo - object.zvel * dt
      if object.zo >= 0 then
        object.zo = 0
        object.zvel = 0
      else
        object.zvel = object.zvel - object.gravity * dt
      end
    end,


    determine_animation_triggers = function(object, dt)
      local anstate = object.animation_state.state
      local myinput = object.input
      local trig = object.triggers
      local sens = object.sensors
      local vx, vy = object.vx, object.vy
      local speed = object.speed
      local right, left, down, up = myinput.right, myinput.left, myinput.down, myinput.up
      if right - left == 0 then right, left = 0, 0 end
      if down - up == 0 then down, up = 0, 0 end

      local directionalPressed = right + left + up + down
      local vxBiggerThanVy =  abs(vx) > abs(vy)

      if directionalPressed > 0 then
        -- This is to avoid twitching due to physics collisions
        local twitchThreshold = 0.1
        if vx > twitchThreshold then

          if left == 1 then
            if vxBiggerThanVy then trig.halt_right = true end
          elseif right == 1 then
            trig.walk_right = true
          end

        elseif vx < -twitchThreshold then

          if right == 1 then
            if vxBiggerThanVy then trig.halt_left = true end
          elseif left == 1 then
            trig.walk_left = true
          end

        end
        if vy > twitchThreshold then

          if up == 1 then
            if not vxBiggerThanVy then trig.halt_down = true end
          elseif down == 1 then
            trig.walk_down = true
          end

        elseif vy < -twitchThreshold then

          if down == 1 then
            if not vxBiggerThanVy then trig.halt_up = true end
          elseif up == 1 then
            trig.walk_up = true
          end

        end

        if sens.downTouch then
          if down == 1 then trig.push_down = true end
        end
        if sens.rightTouch then
          if right == 1 then trig.push_right = true end
        end
        if sens.leftTouch then
          if left == 1 then trig.push_left = true end
        end
        if sens.upTouch then
          if up == 1 then trig.push_up = true end
        end

        if sens.downTouchedObs[1] then
          if down == 1 then trig.walk_down = true end
        end
        if sens.rightTouchedObs[1] then
          if right == 1 then trig.walk_right = true end
        end
        if sens.leftTouchedObs[1] then
          if left == 1 then trig.walk_left = true end
        end
        if sens.upTouchedObs[1] then
          if up == 1 then trig.walk_up = true end
        end


      else
        if speed > 10 then
          if vxBiggerThanVy then
            if sign(vx) == 1 then
              trig.halt_right = true
            else
              trig.halt_left = true
            end
          else
            if sign(vy) == 1 then
              trig.halt_down = true
            else
              trig.halt_up = true
            end
          end
        else
          trig.restish = true
        end
      end

    end, -- of function


    -- Animation state checking functions
    check_push_a = function(instance, trig, myside, dt)
      if myside and trig["push_" .. myside] then
        instance.animation_state:change_state(instance, dt, myside .. "push")
        return true
      end
      if trig.push_down then
        instance.animation_state:change_state(instance, dt, "downpush")
        return true
      elseif trig.push_right then
        instance.animation_state:change_state(instance, dt, "rightpush")
        return true
      elseif trig.push_left then
        instance.animation_state:change_state(instance, dt, "leftpush")
        return true
      elseif trig.push_up then
        instance.animation_state:change_state(instance, dt, "uppush")
        return true
      end
      return false
    end,

    check_walk_a = function(instance, trig, myside, dt)
      if myside and trig["walk_" .. myside] then
        instance.animation_state:change_state(instance, dt, myside .. "walk")
        return true
      end
      if trig.walk_down then
        instance.animation_state:change_state(instance, dt, "downwalk")
        return true
      elseif trig.walk_up then
        instance.animation_state:change_state(instance, dt, "upwalk")
        return true
      elseif trig.walk_right then
        instance.animation_state:change_state(instance, dt, "rightwalk")
        return true
      elseif trig.walk_left then
        instance.animation_state:change_state(instance, dt, "leftwalk")
        return true
      -- Changed this so up takes precedence in this case. Change back if needed
      -- elseif trig.walk_up then
      --   instance.animation_state:change_state(instance, dt, "upwalk")
      --   return true
      end
      return false
    end,

    check_walk_while_walking = function(instance, trig, myside, dt)
      if trig[walktable[myside].first_check.check1]
        and not trig[walktable[myside].first_check.check2] then
          instance.animation_state:change_state(instance, dt, walktable[myside].first_check.result)
          return true
      elseif trig[walktable[myside].second_check.check1]
        and not trig[walktable[myside].second_check.check2] then
          instance.animation_state:change_state(instance, dt, walktable[myside].second_check.result)
          return true
      elseif trig[walktable[myside].third_check.check1] then
        instance.animation_state:change_state(instance, dt, walktable[myside].third_check.result)
        return true
      elseif trig[walktable[myside].fourth_check.check1] then
        return true
      end
      return false
    end,

    check_halt_a = function(instance, trig, myside, dt)
      if myside and trig["halt_" .. myside] then
        instance.animation_state:change_state(instance, dt, myside .. "halt")
        return true
      end
      if trig.halt_down then
        instance.animation_state:change_state(instance, dt, "downhalt")
        return true
      elseif trig.halt_right then
        instance.animation_state:change_state(instance, dt, "righthalt")
        return true
      elseif trig.halt_left then
        instance.animation_state:change_state(instance, dt, "lefthalt")
        return true
      elseif trig.halt_up then
        instance.animation_state:change_state(instance, dt, "uphalt")
        return true
      end
      return false
    end,

    check_halt_notme = function(instance, trig, myside, dt)
      if trig.halt_down and myside ~= "down" then
        instance.animation_state:change_state(instance, dt, "downhalt")
        return true
      elseif trig.halt_right and myside ~= "right" then
        instance.animation_state:change_state(instance, dt, "righthalt")
        return true
      elseif trig.halt_left and myside ~= "left" then
        instance.animation_state:change_state(instance, dt, "lefthalt")
        return true
      elseif trig.halt_up and myside ~= "up" then
        instance.animation_state:change_state(instance, dt, "uphalt")
        return true
      end
      return false
    end,

    check_carry_while_carrying = function(instance, trig, myside, dt)
      -- Variable to ensure lifted object won't be thrown when changing direction
      instance.dontThrow = true
      if trig[carrytable[myside].first_check.check1]
        and not trig[carrytable[myside].first_check.check2] then
          instance.animation_state:change_state(instance, dt, carrytable[myside].first_check.result)
          return true
      elseif trig[carrytable[myside].second_check.check1]
        and not trig[carrytable[myside].second_check.check2] then
          instance.animation_state:change_state(instance, dt, carrytable[myside].second_check.result)
          return true
      elseif trig[carrytable[myside].third_check.check1] then
        instance.animation_state:change_state(instance, dt, carrytable[myside].third_check.result)
        return true
      elseif trig[carrytable[myside].fourth_check.check1] then
        return true
      end
      return false
    end
  }

return mo
