// Simple vignette shader for LÖVE
// License: CC0
// Version: 1.0
// Author:  Landon Manning
// Email:   LManning17@gmail.com

uniform bool  u_correct_ratio = false;
uniform float u_radius        = 0.75;
uniform float u_softness      = 0.45;
uniform float u_opacity       = 0.5;

extern float deadSpaceX = 0.0;
extern float deadSpaceY = 0.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  // Active window size (without deadspace)
  vec2 size = love_ScreenSize.xy - vec2(deadSpaceX, deadSpaceY) * 2;
  // Normalized coordinates of active window size
  vec2 coords = (screen_coords - vec2(deadSpaceX, deadSpaceY)) / size;
  // Is vec4 zero when we're out of bounds and one when in to prevent out of bounds drawing
  vec4 dead = (coords.x <= 0 || coords.y <= 0 || coords.x >= 1 || coords.y >= 1) ? vec4(0,0,0,0) : vec4(1,1,1,1);

	vec4 texColor = texture2D(texture, texture_coords);
	vec2 position = coords - vec2(0.5);

	if (u_correct_ratio) {
		position.x *= size.x / size.y;
	}

	float vignette = smoothstep(
		u_radius,
		u_radius - u_softness,
		length(position)
	);

	// TODO: make different vingette that can turn red when low on health
	texColor.rgb = mix(
		texColor.rgb,
		texColor.rgb * vignette,
		u_opacity
	);

	return texColor * color * dead;
}
