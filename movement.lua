local ps = require "physics_settings"
local u = require "utilities"

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
      local myinput = object.input
      local mass = object.body:getMass()
      local mobility = object.mobility or 600
      local breaks = object.breaks or 6
      local floorFriction = object.floorFriction or 1 -- How slippery the floor is.
      local floorViscosity = object.floorViscosity
      local inversemaxspeed = 1/object.maxspeed

      if floorFriction < 1 then
        mobility = mobility * floorFriction
        breaks = breaks * floorFriction
      end
      if floorViscosity then
        if floorViscosity == "water" then
          inversemaxspeed = inversemaxspeed * 2
          mobility = mobility * 0.1
          breaks = breaks * 2
        end
      end

      -- Calculate force due to input
      local infx, infy =
        u.normalize2d(myinput.right - myinput.left, myinput.down - myinput.up)
      infx = infx * mass * mobility
      infy = infy * mass * mobility

      -- Calculate friction force
      local ffx, ffy = object.vx, object.vy
      if infx == 0 and infy == 0 then
        -- This friction is for when you're actively trying to break
        -- Used when there is no input
        ffx = - ffx * mass * breaks
        ffy = - ffy * mass * breaks
      else
        -- This friction will ensure you don't get over maxspeed
        -- Used when there is input
        ffx = - ffx * mass * mobility * inversemaxspeed
        ffy = - ffy * mass * mobility * inversemaxspeed
      end

      object.body:applyForce(infx, infy)
      object.body:applyForce(ffx, ffy)
    end,

    stand_still = function(object, dt)
      local mass = object.body:getMass()
      local mobility = object.mobility or 600
      local breaks = object.breaks or 6
      local floorFriction = object.floorFriction or 1 -- How slippery the floor is.
      local floorViscosity = object.floorViscosity

      if floorFriction < 1 then
        mobility = mobility * floorFriction
        breaks = breaks * floorFriction
      end
      if floorViscosity then
        if floorViscosity == "water" then
          inversemaxspeed = inversemaxspeed * 2
          mobility = mobility * 0.1
          breaks = breaks * 2
        end
      end

      -- Calculate friction force
      local ffx, ffy = object.vx, object.vy
      ffx = - ffx * mass * breaks
      ffy = - ffy * mass * breaks

      object.body:applyForce(ffx, ffy)
    end,


    image_speed = function(object, dt)
      local floorFriction = object.floorFriction or 1
      local image_speed = 0.13 * object.speed/80--100 looks alright too. was object.maxspeed but looks better now
      if floorFriction < 1 then
        image_speed = image_speed * 1/floorFriction
      end
      if image_speed > 0.3 then image_speed = 0.3 end
      object.image_speed = image_speed
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
        if sens.upTouch then
          if up == 1 then trig.push_up = true end
        end
        if sens.leftTouch then
          if left == 1 then trig.push_left = true end
        end
        if sens.rightTouch then
          if right == 1 then trig.push_right = true end
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
    check_push_a = function(instance, trig)
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

    check_walk_a = function(instance, trig, myside)
      if myside and trig["walk_" .. myside] then
        instance.animation_state:change_state(instance, dt, myside .. "walk")
        return true
      end
      if trig.walk_down then
        instance.animation_state:change_state(instance, dt, "downwalk")
        return true
      elseif trig.walk_right then
        instance.animation_state:change_state(instance, dt, "rightwalk")
        return true
      elseif trig.walk_left then
        instance.animation_state:change_state(instance, dt, "leftwalk")
        return true
      elseif trig.walk_up then
        instance.animation_state:change_state(instance, dt, "upwalk")
        return true
      end
      return false
    end,

    check_halt_a = function(instance, trig)
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
    end
  }

return mo
