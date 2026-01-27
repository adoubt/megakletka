shader_type spatial;
render_mode unshaded, cull_disabled;
uniform float progress : hint_range(0.0, 1.0);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.7;
uniform float outer_radius : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	// === MANUAL BILLBOARD ===
	vec3 cam_right = normalize(INV_VIEW_MATRIX[0].xyz);
	vec3 cam_up    = normalize(INV_VIEW_MATRIX[1].xyz);

	vec2 quad = VERTEX.xy;

	VERTEX =
		cam_right * quad.x +
		cam_up    * quad.y;
}

void fragment() {
	// UV → [-1, 1]
	vec2 uv = UV * 2.0 - 1.0;
	float r = length(uv);

	// --- кольцо ---
	if (r < inner_radius || r > outer_radius) {
		discard;
	}

	// --- угол ---
	float angle = atan(uv.y, uv.x);

	// старт с 12 часов, по часовой стрелке
	float a = mod((angle + PI * 0.5) / (PI * 2.0), 1.0);

	if (a > progress) {
		discard;
	}

	ALBEDO = vec3(0.9);
}
