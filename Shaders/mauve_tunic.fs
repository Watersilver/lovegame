vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    vec4 c = Texel(texture, texture_coords);
    if (c.g >= 0.6 && c.g <= 0.7){
      // return vec4(0.7,0.45,0.83,c.a); // French mauve
      // return vec4(0.7,0.5,0.65,c.a); // Opera mauve
      // return vec4(0.57,0.37,0.43,c.a); // Mauve taupe
      return vec4(0.4, 0.2, 0.28,c.a); // Old Mauve
    }
    else {
      return vec4(c.r,c.g,c.b,c.a);
    }
}
