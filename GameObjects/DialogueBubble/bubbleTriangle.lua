local bubbleTriangle = {}

local width = 5

function bubbleTriangle.draw(x, y, height, widthPercentage, heightPrecentage, pointSide)
  if widthPercentage > 1 then widthPercentage = 1 end
  if heightPrecentage > 1 then heightPrecentage = 1 end
  if pointSide == "down" then
    finalHalfWidth = 0.5 * width * widthPercentage
    love.graphics.polygon("fill",
      x - finalHalfWidth, y,
      x + finalHalfWidth, y,
      x, y + height * heightPrecentage
    )
  elseif pointSide == "up" then
    finalHalfWidth = 0.5 * width * widthPercentage
    love.graphics.polygon("fill",
      x - finalHalfWidth, y,
      x + finalHalfWidth, y,
      x, y - height * heightPrecentage
    )
  end
end

return bubbleTriangle
