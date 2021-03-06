vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // Simple plant
    // vec4 c = Texel(texture, texture_coords);
    // if (c.r >= 0.1 || c.g >= 0.1 || c.b >= 0.1){
    //   return vec4(0.063,0.659,0.251,c.a);
    // }
    // else {
    //   return vec4(0,0,0,c.a);
    // }
    // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    vec4 c = Texel(texture, texture_coords);
    float shade =  0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
    // return vec4(shade * 0.101, shade, shade * 0.385, c.a);
    return vec4(0, shade, 0, c.a);
}
