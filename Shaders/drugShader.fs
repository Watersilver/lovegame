extern float invScale;

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 screen_coords )
{
  uv = uv - vec2(.5);
  // distort
  uv *= invScale;
  uv += (uv.yx*uv.yx) * uv * (vec2(1.06, 1.06) - 1.0);

  uv = uv + vec2(.5);

  // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)
  return color * Texel(tex, uv);
}
