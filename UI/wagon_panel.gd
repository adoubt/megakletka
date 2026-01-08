extends Control

@onready var sell_zone: DropZone = $MarginContainer/VBoxContainer/SellZone
@onready var use_zone: DropZone  = $MarginContainer/VBoxContainer/UseZone

var drop_zones: Array[DropZone]

func _ready() -> void:
	drop_zones = [sell_zone, use_zone]

# === ECS → UI ===
# Вызывай это, когда ECS сказал "можно / нельзя"
func update_zone_states(states: Dictionary) -> void:
	sell_zone.set_enabled(states.get("sell", false))
	use_zone.set_enabled(states.get("use", false))

# === DRAG UPDATE ===
# screen_pos = позиция 3D предмета на экране
func update_hover(screen_pos: Vector2) -> void:
	for zone in drop_zones:
		var inside := zone.get_global_rect().has_point(screen_pos)
		zone.set_hover(inside)

# === DROP ===
# Возвращает имя зоны или ""
func get_drop_zone(screen_pos: Vector2) -> String:
	for zone in drop_zones:
		if zone.enabled and zone.get_global_rect().has_point(screen_pos):
			return zone.zone_type
	return ""

# === СБРОС СОСТОЯНИЯ ===
func clear_hover() -> void:
	for zone in drop_zones:
		zone.set_hover(false)
