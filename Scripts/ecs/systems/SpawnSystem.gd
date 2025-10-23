# res://ecs/systems/SpawnSystem.gd
extends BaseSystem
class_name SpawnSystem

# Настройки спавна
var spawn_interval: float = 5.0 # секунды
var time_accumulator: float = 0.0

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
	
	


func _init(_entity_manager: EntityManager, _component_store: ComponentStore):
	super._init(_entity_manager,_component_store)
	
	
	spawn_char("Rigman",Vector3.ZERO)
	
func update(delta: float) -> void:
	time_accumulator += delta

	if time_accumulator >= spawn_interval:
		time_accumulator -= spawn_interval
		spawn_enemy("Aboba",Vector3(0.0,1.0,0.0))
		spawn_enemy("Aboba",Vector3(0.0,1.0,0.0))
		spawn_enemy("Aboba",Vector3(0.0,1.0,0.0))
		spawn_enemy("Aboba",Vector3(0.0,1.0,0.0))
		
## Creates entity data only — without spawning visuals.
func spawn_enemy(enemy_name: String, position: Vector3) -> int:
	

	if not enemy_configs.has(enemy_name):
		push_warning("Unknown enemy name: %s" % enemy_name)
		return -1

	var data = enemy_configs[enemy_name]
	var entity_id = em.create_entity()

	cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	cs.add_component(entity_id, "HealthComponent", HealthComponent.new(data["hp"]))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
	cs.add_component(entity_id, "TargetComponent",TargetComponent.new())
	cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(3.0))
	return entity_id

func spawn_char(char_name: String, position: Vector3) -> int:
	if not char_configs.has(char_name):
		push_warning("Unknown char name : %s" % char_name)
		return -1

	var data = char_configs[char_name]
	var entity_id = em.create_entity()

	cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	cs.add_component(entity_id, "HealthComponent", HealthComponent.new(data["hp"]))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
	cs.add_component(entity_id, "ControllerStateComponent", ControllerStateComponent.new())

	return entity_id
