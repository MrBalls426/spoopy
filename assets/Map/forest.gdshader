shader_type spatial;

uniform sampler2D base_noise;
uniform sampler2D color_noise;
uniform sampler2D color_sweep;

void fragment() {
	vec4 noise_grain = texture(base_noise, UV * 5.0);
	vec4 noise_color = texture(color_noise,UV);
	vec4 sweep_color = texture(color_sweep,UV + TIME / 5.);
	
	ALBEDO = noise_grain.rgb * mix(noise_color.rgb,sweep_color.rgb, 0.1);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
