extern vec4 redPalette = vec4(1, 0, 0, 1); // helps map redness of a pixel to another colour
extern vec4 greenPalette = vec4(0, 1, 0, 1); // helps map greenness of a pixel to another colour
extern vec4 bluePalette = vec4(0, 0, 1, 1); // helps map blueness of a pixel to another colour
extern vec4 redAmbient = vec4(1, 0, 0, 1); // helps map redness of a pixel to another colour
extern vec4 greenAmbient = vec4(0, 1, 0, 1); // helps map greenness of a pixel to another colour
extern vec4 blueAmbient = vec4(0, 0, 1, 1); // helps map blueness of a pixel to another colour
extern bool nightVision = false;
extern Image lightMap; // holds info about light sources
extern Image shadowMap; // holds info about shadows
extern Image ditherPattern; // Dithering pattern for the lighting

// TODO: Sun light effect like golden sun madra

// WARNING: Do not use max for vectors, it behaves weirdly

// Idea: backlight could be gradient

float max3(vec4 v) {
  return max(max(v.r, v.g), v.b);
}

float cLvl = 5;
float cLvlDiv = 1 / cLvl;
vec4 colLimiter(vec4 col) {
  col.r = floor(col.r * cLvl + 0.500) * cLvlDiv;
  col.g = floor(col.g * cLvl + 0.500) * cLvlDiv;
  col.b = floor(col.b * cLvl + 0.500) * cLvlDiv;
  return col;
}

// color is from love.graphics.setColor
// texture is our image being drawn
// texture_coords is the normalized coordinates of the current pixel
// screen_coords is the coordinates of the current pixel
// Note: coordinates start from screen start even when there's deadspace
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
  // pixel we are drawing
  vec4 pixel = Texel(texture, texture_coords);

  // -----------------
  // Determine palette
  // -----------------

  // red transformation to some colour r determined by its map and intensity of pixel's red colour
  vec4 r = redPalette * pixel.r;
  // green transformation to some colour g determined by its map and intensity of pixel's green colour
  vec4 g = greenPalette * pixel.g;
  // blue transformation to some colour b determined by its map and intensity of pixel's blue colour
  vec4 b = bluePalette * pixel.b;

  // brightest colours are chosen
  pixel.r = max(r.r, max(g.r, b.r));
  pixel.g = max(r.g, max(g.g, b.g));
  pixel.b = max(r.b, max(g.b, b.b));

  vec4 unlit = pixel;

  if (unlit.r == 1 || unlit.g == 1 || unlit.b == 1) {
    return color * unlit;
  }

  // corresponding pixel of the lightMap texture
  vec4 light = Texel(lightMap, texture_coords);

  // Doing this so items will be shown with true color during fanfare.
  // Before This was here gold rupee was changing colour during night
  // because night was mapping reds to blues, making the final .b brighter than the unlit
  if (light.r == 1 && light.g == 1 && light.b == 1 && light.a == 1) {
    return color * unlit;
  }

  // -----------------
  // Determine ambient
  // -----------------

  // red transformation to some colour r determined by its map and intensity of pixel's red colour
  r = redAmbient * unlit.r;
  // green transformation to some colour g determined by its map and intensity of pixel's green colour
  g = greenAmbient * unlit.g;
  // blue transformation to some colour b determined by its map and intensity of pixel's blue colour
  b = blueAmbient * unlit.b;

  // brightest colours are chosen
  vec4 ambient;
  ambient.r = max(r.r, max(g.r, b.r));
  ambient.g = max(r.g, max(g.g, b.g));
  ambient.b = max(r.b, max(g.b, b.b));
  ambient.a = pixel.a;

  // -----------
  // Get shadows
  // -----------

  // corresponding pixel of the shadowMap texture
  vec4 shadow = Texel(shadowMap, texture_coords);
  // Reverse shadow pixel so itworks like a light pixel
  shadow.r = 1.0 - shadow.r;
  shadow.g = 1.0 - shadow.g;
  shadow.b = 1.0 - shadow.b;


  // -----------------
  // Apply light sources
  // -----------------

  // looks like day for night
  // Each pixel is the brightest of its max ambient
  // brightness and the intensity of the light hitting it
  pixel.r = max(shadow.r * ambient.r, light.r * unlit.r);
  pixel.g = max(shadow.g * ambient.g, light.g * unlit.g);
  pixel.b = max(shadow.b * ambient.b, light.b * unlit.b);

  // // Doesn't work for ambient sometimes
  // // Each pixel can be as bright as the min value of its inherent
  // // brightness and the intensity of the light hitting it
  // pixel.r = max(min(ambient.r, shadow.r * unlit.r), light.r * unlit.r);
  // pixel.g = max(min(ambient.g, shadow.g * unlit.g), light.g * unlit.g);
  // pixel.b = max(min(ambient.b, shadow.b * unlit.b), light.b * unlit.b);


  // https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
  // float backlightLuminocity = 0.299*backRed + 0.587*backGreen + 0.114*backBlue;
  float brightestLight = max(max(max3(redAmbient), max(max3(greenAmbient), max3(blueAmbient))), max3(light));
  brightestLight = floor(brightestLight * cLvl + 0.500) * cLvlDiv;

  const float nightVisionThreshold = .2;

  bool inherentlyDark = unlit.r < .5 && unlit.g < .5 && unlit.b < .5;

  if (
    nightVision
    && inherentlyDark
    && brightestLight <= nightVisionThreshold
  ) {
    float l = (nightVisionThreshold - brightestLight);
    return colLimiter(max(color * pixel, vec4(l,l,l,pixel.a)));
  }

  return colLimiter(color * pixel);
}
