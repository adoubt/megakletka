shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float progress_tail : hint_range(0.0, 1.0) = 1.0;
uniform vec3 tail_color : source_color = vec3(1.0);

void fragment() {
	// Основной цвет бара
	vec4 base = COLOR;

	// Если у нас "хвост" (примерно как потеря здоровья)
	if (progress_tail > progress) {
		if (UV.x > progress && UV.x < progress_tail) {
			base.rgb = tail_color;
		}
	}
	// Но если XP растёт (а не падает), то хвоста быть не должно
	else {
		if (UV.x < progress) {
			base.rgb = COLOR.rgb;
		} else {
			base.a = 0.0;
		}
	}

	COLOR = base;
}
