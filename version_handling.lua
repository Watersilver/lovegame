local verh = {}

if love.getVersion() < 11 then
  COLORCONST = 255
else
  COLORCONST = 1
end

return verh
