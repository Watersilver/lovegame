vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    vec4 c = Texel(texture, texture_coords);
    return vec4(c.r*c.a,c.g*c.a,c.b*c.a,c.a);
}
