extern float deadSpaceX = 0.0;
extern float deadSpaceY = 0.0;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
  // Active window size (without deadspace)
  vec2 size = love_ScreenSize.xy - vec2(deadSpaceX, deadSpaceY) * 2;
  // Normalized coordinates of active window size
  vec2 coords = (screen_coords - vec2(deadSpaceX, deadSpaceY)) / size;
  // Is vec4 zero when we're out of bounds and one when in to prevent out of bounds drawing
  vec4 dead = (coords.x <= 0 || coords.y <= 0 || coords.x >= 1 || coords.y >= 1) ? vec4(0,0,0,0) : vec4(1,1,1,1);

  if (coords.y > .95) return vec4(1,0,0,1) * dead;
  vec4 c = Texel(texture, texture_coords);
  return c * color * dead;
}
