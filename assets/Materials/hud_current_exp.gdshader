shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float progress_tail : hint_range(0.0, 1.0) = 0.0;
uniform vec3 tail_color : source_color = vec3(1.0);

void fragment() {
    float x = UV.x;

    // Убираем всё, что правее максимума (ни хвоста, ни заливки)
    float cutoff = max(progress, progress_tail);

    // Прозрачность по умолчанию
    COLOR.a *= step(x, cutoff);

    // Основная заливка — всё, что левее progress
    if (x <= progress) {
        // оставляем базовый цвет
    }
    // Хвост — только если progress_tail > progress
    else if (progress_tail > progress && x > progress && x <= progress_tail) {
        COLOR.rgb = tail_color;
    }
    else {
        // всё правее хвоста — делаем прозрачным
        COLOR.a = 0.0;
    }
}
