-- removes scaled sprite blurriness
love.graphics.setDefaultFilter("nearest")

-- Constants
if love.getVersion() < 11 then
  COLORCONST = 255
else
  COLORCONST = 1
end

local im = {}

im.sprites = {}

function im.load_sprite(args)

  local img_name = args.img_name or args[1]

  -- if it already exists, don't add it again
  if not im.sprites[img_name] then

    -- store optional arguments in local memory
    local rows = args.rows or args[2] or 1
    local columns = args.columns or args[3] or 1
    local padding = args.padding or args[4] or 1

    -- Prepare sprite
    local sprite = {}
    -- Load image
    sprite.img = love.graphics.newImage("sprites/" .. img_name .. ".png")
    local img = sprite.img

    -- Determine the width and height of each quad
    local imgw = img:getWidth()
    local imgh = img:getHeight()
    local width = --[[math.ceil(]](imgw / rows)--[[)]] - 2 * padding
    local height = --[[math.ceil(]](imgh / columns)--[[)]] - 2 * padding

    -- Determine x and y scale because of the image resolution
    if args.width then
      sprite.res_x_scale = args.width / width
      sprite.res_y_scale = args.height / height
    else
      sprite.res_x_scale = 1
      sprite.res_y_scale = 1
    end

    -- Determine offsets
    sprite.ox = width * 0.5
    sprite.oy = height * 0.5

    -- Slice image
    local frames = 0
    for j = 0, columns-1 do
      for i = 0, rows-1 do
        sprite[frames] = love.graphics.newQuad(padding+i*(width + 2 * padding ),
        padding+j*(height + 2 * padding ),
        width, height, img:getDimensions())
        frames = frames + 1
      end
    end
    sprite.frames = frames
    -- Initialize counter that stores how many times this image was loaded
    sprite.times_loaded = 0
    im.sprites[img_name] = sprite
  end

  local sprite = im.sprites[img_name]
  -- The sprite must only be able to be removed from memory if this is zero
  sprite.times_loaded = sprite.times_loaded + 1

  return sprite
end

function im.unload_sprite(img_name)
  im.sprites[img_name].times_loaded = im.sprites[img_name].times_loaded - 1
  if im.sprites[img_name].times_loaded == 0 then im.sprites[img_name] = nil end
end

return im
