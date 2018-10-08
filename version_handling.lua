local verh = {}

if love.getVersion() < 11 then
  COLORCONST = 255
  verh.fileExists = love.filesystem.exists
else
  COLORCONST = 1
  verh.fileExists = love.filesystem.getInfo
end

return verh
