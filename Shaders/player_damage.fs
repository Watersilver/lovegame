vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 c = Texel(texture, texture_coords); // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    if (c.g >= 0.6 && c.g <= 0.7) {
      return vec4(0.847,0,0,c.a);
    }
    else if (c.g < 0.6 && c.g <= 0.7){
      return vec4(0.973,0.69,0.188,c.a);
    }
    else {
      return vec4(0,0,0,c.a);
    }
}
