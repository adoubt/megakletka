extends Node
class_name StatsSystem

var _last_values := {}
func update_entity_stats(entity: Entity):
	var id = entity.get_instance_id()
	var current_size = entity.stats.size
	var last_size = _last_values.get(id, -1.0)

	# Проверяем: изменился ли размер
	if current_size != last_size:
		_update_size_dependent_things(entity)
		_last_values[id] = current_size

func _update_size_dependent_things(entity: Entity):
	for weapon in entity.weapons:
		if weapon is AOEWeapon:
			var instance: Node3D = weapon.get_meta("instance")
			if instance:
				var new_scale = weapon.radius * entity.stats.size * weapon.stats.size
				instance.scale = Vector3.ONE * new_scale
