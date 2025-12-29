shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform float scale : hint_range(1.0, 50.0) = 8.0;
uniform vec4 main_color : source_color = vec4(0.96, 0.92, 0.85, 1.0);
uniform vec4 dark_color : source_color = vec4(0.62, 0.38, 0.32, 1.0);
uniform vec4 yellow_tint : source_color = vec4(1.0, 0.96, 0.82, 1.0);
uniform float wear : hint_range(0.0, 1.0) = 0.65;
uniform float anim_speed : hint_range(0.0, 0.2) = 0.02;

// Varying для передачи world position
varying vec3 world_position;

// Простая procedural noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Шахматка по мировым координатам
    vec2 coord = world_position.xz * scale;
    float id = floor(coord.x) + floor(coord.y);
    float chess = mod(id, 2.0);
    
    // Базовый цвет
    vec4 tile_color = mix(dark_color, main_color, chess);
    
    // Жёлтый налёт старости + выцветание
    tile_color *= yellow_tint * 1.35;
    
    // Procedural шум (потёртость + грязь)
    vec2 noise_coord = coord * 0.4 + TIME * anim_speed;
    float n = noise(noise_coord * 3.0);
    n += noise(noise_coord * 12.0) * 0.5;
    n *= 0.5;
    float noise_val = pow(n, 2.2) * 1.4 - 0.2;
    
    // Потёртость
    float wear_mask = mix(0.3, 1.0, noise_val);
    tile_color = mix(tile_color * 0.65, tile_color * 1.15, wear_mask);
    
    // Грязь/старость
    float dirt = clamp(noise_val * wear * 1.8, 0.0, 1.0);
    tile_color *= mix(1.0, 0.75, dirt);
    
    ALBEDO = tile_color.rgb;
    ALPHA = tile_color.a;
    METALLIC = 0.05;
    ROUGHNESS = 0.75 + dirt * 0.15;     // Матовая поверхность + грязь делает грубее
    SPECULAR = 0.3;
    // AO убираем — вместо него просто затемнение через dirt
}