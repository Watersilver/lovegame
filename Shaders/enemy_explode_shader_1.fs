vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    vec4 c = Texel(texture, texture_coords);
    if (c.g >= 0.5 && c.g <= 0.55){
      return vec4(0.973,0.031,0.157,c.a);
    }
    else if (c.r >= 0.6 && c.r <= 0.65){
      return vec4(0.094,0.502,0.973,c.a);
    }
    else {
      return vec4(c.r,c.g,c.b,c.a);
    }
}
