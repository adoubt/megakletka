shader_type spatial;
render_mode  cull_disabled;

uniform vec3 bullet_color : source_color = vec3(1.0, 0.2, 0.2);
uniform float min_power = 1.2;
uniform float max_power = 2.5;
uniform float blink_speed = 2.0;

void fragment() {
	float pulse = mix(
		min_power,
		max_power,
		0.5 + 0.5 * sin(TIME * blink_speed)
	);

	ALBEDO = vec3(0.0);              // не влияет, но явно
	EMISSION = bullet_color * pulse;
}
