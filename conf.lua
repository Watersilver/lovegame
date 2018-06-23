function love.conf(t)
  t.window.vsync = false
  t.window.highdpi = false
  t.window.fullscreentype = "desktop"
  t.window.fullscreen = false
  t.window.width = 1600
  local aspect_ratio = 16/9
  t.window.height = t.window.width / aspect_ratio -- 900 if t.window.width = 1600
  t.window.resizable = true
  t.console = true
end
