shader_type spatial;

uniform sampler2D base_noise;
uniform sampler2D color_noise;
uniform sampler2D color_sweep;

void fragment() {
	float grass_multiplier = 20.0;
	float color_sweep_multiplier = .2;
	vec2 grass_sway = vec2(UV.x * grass_multiplier + sin(TIME)/360., UV.y * grass_multiplier + sin(TIME+ 90.)/360.);
	vec4 noise_grain = texture(base_noise, grass_sway);
	vec4 noise_color = texture(color_noise,UV);
	vec4 sweep_color = texture(color_sweep,UV + TIME / 8.);
	
	ALBEDO = noise_grain.rgb * mix(noise_color.rgb,sweep_color.rgb, color_sweep_multiplier);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
