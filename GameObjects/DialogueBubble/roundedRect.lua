local roundedRect = {}

function roundedRect.draw(x, y, width, height, radius)
  left, top = x - width * 0.5, y - height * 0.5
  -- Rects
  if radius > height * 0.5 then radius = height * 0.5 end
  -- middle rect
  local midX = left + radius
  local midY = top
  local midWidth = width - 2 * radius
  local midHeight = height
  love.graphics.rectangle("fill", midX, midY, midWidth, midHeight)
  -- left rect
  local leftX = left
  local edgeY = top + radius
  local edgeWidth = radius
  local edgeHeight = height - 2 * radius
  love.graphics.rectangle("fill", leftX, edgeY, edgeWidth, edgeHeight)
  -- right rect
  local rightX = midX + midWidth
  love.graphics.rectangle("fill", rightX, edgeY, edgeWidth, edgeHeight)

  -- Arcs
  love.graphics.arc("fill", midX, edgeY, radius, math.pi * 1.5, math.pi)
  love.graphics.arc("fill", midX, edgeY + edgeHeight, radius, math.pi, math.pi * 0.5)
  love.graphics.arc("fill", midX + midWidth, edgeY, radius, 0, -math.pi * 0.5)
  love.graphics.arc("fill", midX + midWidth, edgeY + edgeHeight, radius, 0, math.pi * 0.5)
end

return roundedRect
