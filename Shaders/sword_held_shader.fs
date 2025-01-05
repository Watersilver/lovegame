extern Image noise;
extern float frames;

extern float rgb[7];

float mod(float a, float b)
{
  return a - (b * floor(a/b));
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
  vec4 c = Texel(texture, texture_coords);
  if (c.a < 0.1) {
    return c * color;
  }
  vec4 n = Texel(noise, vec2(mod(texture_coords.x * frames, 1), texture_coords.y));
  c.g = c.g * (1 - n.g * n.a);
  if (n.b < n.a * 0.3) {
    c.a = 0;
  }
  if (c.g >= 0.8){
    c = vec4(1,1,1,c.a);
  }
  else if (c.g >= 0.5){
    c = vec4(rgb[3],rgb[4],rgb[5],c.a);
  }
  else {
    c = vec4(rgb[0],rgb[1],rgb[2],c.a);
  }
  return color * c;
}
