local ps = require "physics_settings"
local u = require "utilities"

local mo = {}

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

  function  mo.top_down(object, dt)
    local mass = object.body:getMass()
    local myinput = object.input
    local mobility = object.mobility or 600

    -- calculate force due to input
    local infx, infy =
      u.normalize2d(myinput.right - myinput.left, myinput.down - myinput.up)
    infx = infx * mass * mobility
    infy = infy * mass * mobility
    -- calculate friction
    local ffx, ffy = object.body:getLinearVelocity()
    ffx = - ffx * mass * (mobility * 0.01)
    ffy = - ffy * mass * (mobility * 0.01)

    object.body:applyForce(infx, infy)
    object.body:applyForce(ffx, ffy)
  end

return mo
