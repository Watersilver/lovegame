uniform float rgb[4];

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
    vec4 c = Texel(texture, texture_coords);

    return vec4(rgb[0]*c.a,rgb[1]*c.a,rgb[2]*c.a,c.a);
}
