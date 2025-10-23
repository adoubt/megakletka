# res://ecs/systems/SpawnSystem.gd
extends BaseSystem
class_name SpawnSystem
func _init(_entity_manager: EntityManager, _component_store: ComponentStore):
	super._init(_entity_manager,_component_store)
	spawn_enemy("Aboba",Vector3(0.0,3.0,0.0))
	spawn_char("Rigman",Vector3.ZERO)
	
var enemy_configs = {
		"Aboba": {
			"scene": "res://Scenes/Enemy/Aboba.tscn",
			"hp": 10,
		}
	}


var char_configs = {
		"Rigman": {
			"scene": "res://Scenes/Player/Player.tscn",
			"hp": 100,
		}
	}
	
	
## Creates entity data only — without spawning visuals.
func spawn_enemy(enemy_name: String, position: Vector3) -> int:
	

	if not enemy_configs.has(enemy_name):
		push_warning("Unknown enemy name: %s" % enemy_name)
		return -1

	var data = enemy_configs[enemy_name]
	var entity_id = entity_manager.create_entity()

	component_store.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	component_sto

	return entity_id

func spawn_char(char_name: String, position: Vector3) -> int:
	if not enemy_configs.has(char_name):
		push_warning("Unknown char name : %s" % char_name)
		return -1

	var data = enemy_configs[char_name]
	var entity_id = entity_manager.create_entity()

	component_store.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	component_store.add_component(entity_id, "HealthComponent", HealthComponent.new(data["hp"]))
	component_store.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
	return entity_id
