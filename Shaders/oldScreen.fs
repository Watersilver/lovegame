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
vec2 scaleFactor = vec2(1.05, 1.05); // 1
number feather = 0; // Don't change

// defaults chromasep
vec2 direction = vec2(0.0015, 0.001);

vec4 effect(vec4 c, Image tex, vec2 uv, vec2 px) {

  // crt
  // to barrel coordinates
  uv = uv * 2.0 - vec2(1.0);
  // distort
  uv *= scaleFactor;
  uv += (uv.yx*uv.yx) * uv * (distortionFactor - 1.0);
  number mask = (1.0 - smoothstep(1.0-feather,1.0,abs(uv.x)))
              * (1.0 - smoothstep(1.0-feather,1.0,abs(uv.y)));
  // to cartesian coordinates
  uv = (uv + vec2(1.0)) / 2.0;

  // chromasep
  c = c * vec4(
    Texel(tex, uv - direction).r,
    Texel(tex, uv).g,
    Texel(tex, uv + direction).b,
    1.0);


  return c * mask;
}
