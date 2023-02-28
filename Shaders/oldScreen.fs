// Copyright (C) 2017 by Matthias Richter <vrld@vrld.org>
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted.

// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
// REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
// INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
// LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
// OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
// PERFORMANCE OF THIS SOFTWARE.

// defaults crt
vec2 distortionFactor = vec2(1.06, 1.065); // 1.06, 1.065
vec2 scaleFactor = vec2(1.02, 1.02); // 1
number feather = 0; // Don't change

// defaults chromasep
vec2 direction = vec2(0.0015, 0.001);

extern float deadSpaceX = 0.0;
extern float deadSpaceY = 0.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  // Active window size (without deadspace)
  vec2 size = love_ScreenSize.xy - vec2(deadSpaceX, deadSpaceY) * 2;
  // Normalized coordinates of active window size
  vec2 coords = (screen_coords - vec2(deadSpaceX, deadSpaceY)) / size;
  // Is vec4 zero when we're out of bounds and one when in to prevent out of bounds drawing
  vec4 dead = (coords.x <= 0 || coords.y <= 0 || coords.x >= 1 || coords.y >= 1) ? vec4(0,0,0,0) : vec4(1,1,1,1);

  // crt
  // to barrel coordinates
  coords = coords * 2.0 - vec2(1.0);
  // distort
  coords *= scaleFactor;
  coords += (coords.yx*coords.yx) * coords * (distortionFactor - 1.0);
  number mask = (1.0 - smoothstep(1.0-feather,1.0,abs(coords.x)))
              * (1.0 - smoothstep(1.0-feather,1.0,abs(coords.y)));
  // to cartesian coordinates
  coords = (coords + vec2(1.0)) / 2.0;

  texture_coords = (coords * size + vec2(deadSpaceX, deadSpaceY)) / love_ScreenSize.xy;

  // chromasep
  color = color * vec4(
    Texel(texture, texture_coords - direction).r,
    Texel(texture, texture_coords).g,
    Texel(texture, texture_coords + direction).b,
    1.0
  );

  if (texture_coords.x <= 0 || texture_coords.y <= 0 || texture_coords.x >= 1 || texture_coords.y >= 1)
    return vec4(0,0,0,0);

  return color * mask * dead;
}
