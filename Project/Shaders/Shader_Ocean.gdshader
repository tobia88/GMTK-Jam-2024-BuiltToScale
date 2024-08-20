shader_type spatial;

render_mode specular_toon;

uniform vec4 base_color : source_color = vec4(0.0, 0.53, 0.95, 1.0);
uniform sampler2D noise_tex;
uniform float amplitude = 0.25;
uniform vec4 foam_color: source_color = vec4(1.0);

uniform sampler2D depth_texture : hint_depth_texture;

uniform float plane_size = 100;
uniform float normal_scale = 1.0;

float height(vec2 pos, float time) {
	vec2 offset = 0.01 * cos(pos + time);
	return texture(noise_tex, (pos * 0.05) - offset).r * amplitude;
}

void vertex() {
	//vec2 pos = VERTEX.xz;
	//float k = height(pos, TIME);
	//VERTEX.y = k;
	//float uv_offset = 1.0 / plane_size;
	//float k_r = height(pos + vec2(uv_offset, 0.0), TIME);
	//float k_f = height(pos + vec2(0.0, uv_offset), TIME);
	//NORMAL = normalize(vec3(k - k_r, uv_offset, k - k_f));
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;	// non linear 0 - 1
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);	// vulkan renderer ndc.z [0 - 1]

	// calculate world position
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.z /= view.w;

	//float linear_depth = -view.z;
	float depth_blend = smoothstep(view.z + 0.5, view.z, VERTEX.z);
	float foam_mask = depth_blend;

	vec3 final_color = mix(base_color.rgb, foam_color.rgb, foam_mask);

	float fresnal = sqrt(1.0 - dot(NORMAL, VIEW));
	// Called for every pixel the material is visible on.
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.0;

	ALBEDO = final_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
