vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 c = Texel(texture, texture_coords); // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    // return vec4(vec3(1.0, 1.0, 1.0) * (max(c.r, max(c.g, c.b))), c.a); // This just returns a white color that's modulated by the brightest color channel at the given pixel in the texture. Nothing too complex, and not exactly the prettiest way to do B&W :P
    // if (c.g == 1) {
    //   // then I'm on a white pixel
    //   return vec4(0,0,0,c.a);
    // }
    // else
    if (c.r == 1) {
      // then I'm on a red pixel (or white if above is commented out)
      return vec4(0,0,0,c.a);
    }
    else if (c.r == 0){
      // then I'm on a black pixel
      return vec4(0.973,0.69,0.188,c.a);
    }
    else {
      // I'm on a gray pixel
      return vec4(0.847,0,0,c.a);
    }
}
