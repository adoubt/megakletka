shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform float radius = 0.45;
uniform float softness = 0.2;
uniform float alpha = 0.5;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float dist = length(uv);

	float mask = smoothstep(radius, radius - softness, dist);

	ALBEDO = vec3(0.0);
	ALPHA = mask * alpha;
}
