vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    vec4 c = Texel(texture, texture_coords);
    if (c.r >= 0.1 || c.g >= 0.1 || c.b >= 0.1){
      return vec4(0.5,0.8,1,c.a);
    }
    else {
      return vec4(0,0,0,c.a);
    }
}
