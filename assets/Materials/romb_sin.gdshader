shader_type spatial;
render_mode blend_mix, cull_back, unshaded, shadows_disabled;

uniform float amplitude = 0.35;
uniform float bounce_speed = 3.0;
uniform float rotate_speed = 0.5;

// Основной цвет (голубой алмаз)
uniform vec4 tint_color : source_color = vec4(0.15, 0.45, 1.0, 0.35);

// Насколько сильно добавлять френель
uniform float fresnel_intensity = 0.3;
// Насколько синий становится по краям
uniform float fresnel_blue_boost = 0.4;

void vertex() {
    float offset = sin(TIME * bounce_speed) * amplitude;
    VERTEX.y += offset;

    float angle = TIME * rotate_speed;
    float cos_a = cos(angle);
    float sin_a = sin(angle);

    vec3 pos = VERTEX;
    VERTEX.x = pos.x * cos_a - pos.z * sin_a;
    VERTEX.z = pos.x * sin_a + pos.z * cos_a;
}

void fragment() {
    // Мягкий френель — без выбеливания
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), 1.5);

    // База — голубой
    vec3 base = tint_color.rgb;

    // Добавляем синего по краю
    vec3 fresnel_color = vec3(0.1, 0.3, 1.0) * fresnel * fresnel_blue_boost;

    // Смешивание без пересвета
    vec3 final_color = mix(base, base + fresnel_color, fresnel_intensity);

    ALBEDO = final_color;

    // Прозрачность = базовая + мягкий френель
    ALPHA = tint_color.a + fresnel * 0.2;

    // Гарантия отсутствия чёрных артефактов при низкой альфе
    if (ALPHA < 0.05) {
        discard;
    }
}
