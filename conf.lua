function love.conf(t)
  t.identity = "Mage"
  t.window.vsync = false
  t.window.highdpi = false
  t.window.fullscreentype = "desktop"
  t.window.fullscreen = false

  -- Set to zero if you want to detect screen size
  -- t.window.width = 0
  -- t.window.height = 0
  t.window.width = 1600--1600
  local aspect_ratio = 16/9
  t.window.height = t.window.width / aspect_ratio -- 900 if t.window.width = 1600

  t.window.resizable = true
  t.console = true
end
