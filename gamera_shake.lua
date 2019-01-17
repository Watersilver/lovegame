local u = require "utilities"

local function shakeCheck(cam, dt)
  cam.shake = false
  cam.shakeDur = cam.shakeDur - dt
  cam.shakeCounter = cam.shakeCounter - dt
  cam.shakeTimer = cam.shakeTimer + dt
  if cam.shakeDur < 0 then cam.shaking = false end
  if cam.shakeCounter < 0 then
    cam.shakeCounter = cam.shakeFreq
    cam.shake = true
  end
end

local gsh = {}

-- Random shake
function gsh.random(cam, dt)
  if cam.shake then
    local _, _, nl, nt = cam:getWindow()
    local magn = cam.shakeMagn * 0.05
    nl = nl * love.math.random(-1, 1) * love.math.random() * magn
    nt = nt * love.math.random(-1, 1) * love.math.random() * magn
    cam.noisel, cam.noiset = nl, nt
  end
end

-- Horizontal sin shake
function gsh.horSin(cam, dt)
end

-- Vertical sin shake
function gsh.verSin(cam, dt)
end

function gsh.displacement(cam, dt)
  local magn = (cam.shakeMagn * cam.shakeDur) * 0.05
  local lmagn, tmagn = u.polarToCartesian(magn, love.math.random(2 * math.pi))
  local _, _, nl, nt = cam:getWindow()
  nl = nl * love.math.random(-1, 1) * love.math.random() * lmagn
  nt = nt * love.math.random(-1, 1) * love.math.random() * tmagn
  cam.noisel, cam.noiset = nl, nt
end

function gsh.shake(cam, dt)
  if cam.shaking then
    -- Call appropriate shake
    gsh[cam.shakeType](cam, dt)
    -- Check if camera shake is over
    shakeCheck(cam, dt)
  else
    cam.noisel, cam.noiset = 0, 0
  end
end

function gsh.newShake(cam, type, magnitude, frequency, duration)
  cam.shakeType = type or "random"
  cam.shakeMagn = magnitude or 1
  cam.shakeFreq = frequency or 0.05
  cam.shakeDur = duration or 0.5
  cam.shaking = true
  cam.shakeTimer = 0
  cam.noisel, cam.noiset = 0, 0
  cam.shakeCounter = cam.shakeFreq
  cam.shake = true
end

return gsh
