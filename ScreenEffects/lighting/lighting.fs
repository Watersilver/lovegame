extern vec3 redMap = vec3(1, 0, 0); // helps map redness of a pixel to another colour
extern vec3 greenMap = vec3(0, 1, 0); // helps map greenness of a pixel to another colour
extern vec3 blueMap = vec3(0, 0, 1); // helps map blueness of a pixel to another colour
extern vec3 redBacklight = vec3(1, 0, 0); // helps map redness of a pixel to another colour
extern vec3 greenBacklight = vec3(0, 1, 0); // helps map greenness of a pixel to another colour
extern vec3 blueBacklight = vec3(0, 0, 1); // helps map blueness of a pixel to another colour
extern bool nightVision = false;
extern Image lightMap; // Image that holds info about light sources
extern Image shadowMap; // Image that holds info about shadows

// TODO: Fix light sometimes making it harder to see...
// Example is backlight 0.1 and light 0.1. Will turn grey.

// color is from love.graphics.setColor
// texture is our image being drawn
// texture_coords is the normalized coordinates of the current pixel
// screen_coords is the coordinates of the current pixel
// Note: coordinates start from screen start even when there's deadspace
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
  // pixel we are drawing
  vec4 pixel = Texel(texture, texture_coords);

  bool inherentlyDark = pixel.r < .5 && pixel.g < .5 && pixel.b < .5;

  // -----------------
  // Determine palette
  // -----------------

  // red transformation to some colour r determined by its map and intensity of pixel's red colour
  vec3 r = redMap * pixel.r;
  // green transformation to some colour g determined by its map and intensity of pixel's green colour
  vec3 g = greenMap * pixel.g;
  // blue transformation to some colour b determined by its map and intensity of pixel's blue colour
  vec3 b = blueMap * pixel.b;

  // brightest colour is chosen
  pixel.r = max(r.r, max(g.r, b.r));
  pixel.g = max(r.g, max(g.g, b.g));
  pixel.b = max(r.b, max(g.b, b.b));

  // -------------------
  // Determine backlight
  // -------------------

  // red transformation to some colour r determined by its map and intensity of pixel's red colour
  r = redBacklight * pixel.r;
  // green transformation to some colour g determined by its map and intensity of pixel's green colour
  g = greenBacklight * pixel.g;
  // blue transformation to some colour b determined by its map and intensity of pixel's blue colour
  b = blueBacklight * pixel.b;

  // brightest colour is chosen
  float backRed = max(r.r, max(g.r, b.r));
  float backGreen = max(r.g, max(g.g, b.g));
  float backBlue = max(r.b, max(g.b, b.b));

  // -------------
  // Apply shadows
  // -------------

  // corresponding pixel of the shadowMap texture
  vec4 shadow = Texel(shadowMap, texture_coords);

  // darkest colour is chosen
  backRed = min(backRed, (1 - shadow.r) * pixel.r);
  backGreen = min(backGreen, (1 - shadow.g) * pixel.g);
  backBlue = min(backBlue, (1 - shadow.b) * pixel.b);

  // -------------------
  // Apply light sources
  // -------------------

  // corresponding pixel of the lightMap texture
  vec4 light = Texel(lightMap, texture_coords);
  float redMax = max(light.r * pixel.r, backRed);
  float greenMax = max(light.g * pixel.g, backGreen);
  float blueMax = max(light.b * pixel.b, backBlue);

  // Each pixel can be as bright as the min value of its inherent
  // brightness and the intensity of the light hitting it
  pixel.r = min(pixel.r, redMax);
  pixel.g = min(pixel.g, greenMax);
  pixel.b = min(pixel.b, blueMax);

  // https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
  // float backlightLuminocity = 0.299*backRed + 0.587*backGreen + 0.114*backBlue;

  float maxLight = max(light.r, max(light.g, light.b));

  const float nightVisionThreshold = .1;

  if (
    nightVision
    && inherentlyDark
    && maxLight <= nightVisionThreshold
  ) {
    float l = nightVisionThreshold - maxLight;
    return max(color * pixel, vec4(l,l,l,pixel.a));
  }

  return color * pixel;
}
