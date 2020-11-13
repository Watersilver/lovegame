local bubbleTriangle = {}

local width = 5

function bubbleTriangle.draw(x, y, height, widthPercentage, heightPrecentage, pointSide)
  if widthPercentage > 1 then widthPercentage = 1 end
  if heightPrecentage > 1 then heightPrecentage = 1 end
  if pointSide == "down" then
    local finalHalfWidth = math.ceil(0.5 * width * widthPercentage)
    local intHeight = math.ceil(height)
    y = y - intHeight + height
    local intWidth = math.ceil(width * widthPercentage)
    for h = 0, intHeight-1 do
      if intWidth - 2 * h <= 0 then break end
      love.graphics.rectangle("fill",
        x - finalHalfWidth + h, y + h * heightPrecentage, intWidth - 2 * h, 1
      )
    end
  elseif pointSide == "up" then
    local finalHalfWidth = math.ceil(0.5 * width * widthPercentage)
    local intHeight = math.ceil(height)
    y = y - intHeight + height
    local intWidth = math.ceil(width * widthPercentage)
    for h = 0, intHeight-1 do
      if intWidth - 2 * h <= 0 then break end
      love.graphics.rectangle("fill",
        x - finalHalfWidth + h, y - h * heightPrecentage, intWidth - 2 * h, -1
      )
    end
  end
end

return bubbleTriangle
