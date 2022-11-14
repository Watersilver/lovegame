vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    vec4 c = Texel(texture, texture_coords);
    if (c.b >= 0.95){
      return vec4(1,0.3,0.3,c.a);
    }
    else {
      return vec4(c.r,c.g,c.b,c.a);
    }
}
