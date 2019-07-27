vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    vec4 c = Texel(texture, texture_coords);
    if (c.r == 0 && c.g == 0 && c.b == 0){
      // then I'm on a black pixel
      return vec4(0.973,0.69,0.188,c.a * 0.5);
    }
    else if (0.2126*c.r + 0.7152*c.g + 0.0722*c.b > 0.7){
      // I'm on a whiteish black
      return vec4(0,0,0,c.a * 0.5);
    }
    else {
      // then I'm on a colored pixel
      return vec4(0.847,0,0,c.a * 0.5);
    }
}
