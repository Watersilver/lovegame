extern vec3 redMap; // helps map redness of a pixel to another colour
extern vec3 greenMap; // helps map greenness of a pixel to another colour
extern vec3 blueMap; // helps map blueness of a pixel to another colour
extern Image lightMap; // Image that holds info about light sources

// color is from love.graphics.setColor
// texture is our image being drawn
// texture_coords is the normalized coordinates of the current pixel, relative to the image
// screen_coords is the coordinates of the current pixel, relative to the screen
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
  // pixel we are working on
  vec4 pixel = Texel(texture, texture_coords);

  // red transformation to some colour r determined by its map and intensity of pixel's red colour
  vec3 r = redMap * pixel.r;
  // green transformation to some colour g determined by its map and intensity of pixel's green colour
  vec3 g = greenMap * pixel.g;
  // blue transformation to some colour b determined by its map and intensity of pixel's blue colour
  vec3 b = blueMap * pixel.b;

  // -------------------
  // Determine backlight
  // -------------------

  // brightest colour is chosen
  float backRed = max(r.r, max(g.r, b.r));
  float backGreen = max(r.g, max(g.g, b.g));
  float backBlue = max(r.b, max(g.b, b.b));

  // -------------------
  // Apply light sources
  // -------------------

  // corresponding pixel of the lightMap texture
  // Causes stretching when there is deadspace
  // which means coords starts from screen start instead of
  // visible start
  // TODO: Fix stretching either here or at the canvas (resize canvas)
  vec4 light = Texel(lightMap, texture_coords);

  // Each pixel can be as bright as the min value of its inherent
  // brightness and the intensity of the light hitting it
  pixel.r = min(pixel.r, max(light.r, backRed));
  pixel.g = min(pixel.g, max(light.g, backGreen));
  pixel.b = min(pixel.b, max(light.b, backBlue));

  return color * pixel;
}
