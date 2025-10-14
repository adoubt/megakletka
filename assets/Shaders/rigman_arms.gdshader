shader_type spatial;

uniform vec4 baseColor : source_color = vec4(0.29, 0.173, 0.102, 1.0);
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;

uniform float back_cut = 0.0;           // Позиция разреза
uniform float cut_thickness = 0.01;     // Толщина слоя-заливки
uniform vec4 cut_color : source_color = vec4(0.29, 0.173, 0.102, 1.0);

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	// расстояние от текущей точки до плоскости разреза по Z
	float dist = local_pos.z - back_cut;

	// если точка далеко за плоскостью по ту сторону — ничего не рисуем
	if (dist < -cut_thickness) {
		discard;
	}

	// флаг если пиксель лежит в пределах визуальной толщины среза
	bool on_cut = abs(dist) <= cut_thickness;

	// если на срезе — рисуем cut_color
	if (on_cut) {
		ALBEDO = cut_color.rgb;
		METALLIC = 0.0;
		SPECULAR = 0.2;
	} else {
		// иначе обычный материал для рук
		ALBEDO = baseColor.rgb;
		METALLIC = metallic;
		SPECULAR = specular;
	}
}
