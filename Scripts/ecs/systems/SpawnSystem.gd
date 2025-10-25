# res://ecs/systems/SpawnSystem.gd
extends BaseSystem
class_name SpawnSystem

# Настройки спавна
var spawn_interval: float = 0.5 # секунды
var time_accumulator: float = 0.0

var enemy_configs = {
		"Aboba": {
			"scene": "res://Scenes/Enemy/Aboba.tscn",
			"hp": 10,
			"attack_speed":1.7,
			"collider_radius":0.25,
			"movespeed": 2
		}
	}


var char_configs = {
		"Rigman": {
			"scene": "res://Scenes/Player/Player.tscn",
			"hp": 100,
			"attack_speed_mult":1.0,
			"collider_radius": 0.15,
			"movespeed": 10
		}
	}
	
var weapon_configs = {
		
		"cheese": {
			"scene": "res://Scenes/Weapons/Projectiles/cheese.tscn",
			"cd": 5,
			"damage" : 1,
			"projectile_count" : 5.0,
			"projectile_radius" : 0.2,
			"weapon_radius": 1.5,
			"projectile_speed": 3.0,
		},
		
}

var pool :ObjectPool
func _init(_entity_manager: EntityManager, _component_store: ComponentStore):
	super._init(_entity_manager,_component_store)

	
	var char_id = spawn_char("Rigman",Vector3.ZERO) 

	#spawn_weapon("dexecutioner",char_id)

func update(delta: float) -> void:
 
	time_accumulator += delta

	if time_accumulator >= spawn_interval:
		time_accumulator -= spawn_interval
		for i in range(10):
			var enemy_id = spawn_enemy("Aboba",Vector3(0.0,1.0,0.0))
			spawn_weapon("cheese",enemy_id)
		
## Creates entity data only — without spawning visuals.
func spawn_enemy(enemy_name: String, position: Vector3) -> int:
	

	if not enemy_configs.has(enemy_name):
		push_warning("Unknown enemy name: %s" % enemy_name)
		return -1
	
	var data = enemy_configs[enemy_name]
	var entity_id = em.create_entity()

	cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	cs.add_component(entity_id, "MaxHpComponent", MaxHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "CurrentHpComponent",CurrentHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
	cs.add_component(entity_id, "TargetComponent",TargetComponent.new())
	cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(data["movespeed"]))
	cs.add_component(entity_id, "TeamComponent", TeamComponent.new(2))
	
	cs.add_component(entity_id, "AttackSpeedComponent", AttackSpeedComponent.new())
	cs.add_component(entity_id, "CollisionComponent",
	CollisionComponent.new(
		CollisionLayers.Layer.ENEMY,
		CollisionLayers.Layer.PLAYER | 
		CollisionLayers.Layer.WORLD | 
		CollisionLayers.Layer.PLAYER_PROJECTILE |
		CollisionLayers.Layer.ENEMY,
		data["collider_radius"]
	))
	cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new())
	cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new())
	cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new())
	cs.add_component(entity_id,"ProjectileSpeedComponent",ProjectileSpeedComponent.new())
	cs.add_component(entity_id,"GroundedComponent", GroundedComponent.new())
	cs.add_component(entity_id, "DamageComponent", DamageComponent.new())
	return entity_id

func spawn_char(char_name: String, position: Vector3) -> int:
	if not char_configs.has(char_name):
		push_warning("Unknown char name : %s" % char_name)
		return -1
	
	var data = char_configs[char_name]
	var entity_id = em.create_entity()
	cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(data["movespeed"]))
	cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	cs.add_component(entity_id, "MaxHpComponent", MaxHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "CurrentHpComponent",CurrentHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
	cs.add_component(entity_id, "DamageComponent", DamageComponent.new())
	cs.add_component(entity_id, "ControllerStateComponent", ControllerStateComponent.new())
	cs.add_component(entity_id, "TeamComponent", TeamComponent.new(3))
	
	cs.add_component(entity_id, "AttackSpeedComponent", AttackSpeedComponent.new())
	cs.add_component(entity_id, "HUDComponent", HUDComponent.new(entity_id))
	cs.add_component(entity_id, "CollisionComponent",
	CollisionComponent.new(
		CollisionLayers.Layer.PLAYER,
		CollisionLayers.Layer.ENEMY | CollisionLayers.Layer.ENEMY_PROJECTILE,
		data["collider_radius"]
	))
	cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new())
	cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new())
	cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new())
	cs.add_component(entity_id, "ProjectileSpeedComponent",ProjectileSpeedComponent.new())
	return entity_id

func spawn_weapon(_name:String, owner_id:int):
	if not weapon_configs.has(_name):
		push_warning("Unknown char name : %s" % _name)
		return -1
		
	var data = weapon_configs[_name]
	var entity_id = em.create_entity()
	cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, data["cd"], owner_id))
	cs.add_component(entity_id, "DamageComponent", DamageComponent.new(data["damage"]))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
	cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(data["projectile_count"]))
	cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new(data["projectile_radius"]))
	cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(data["weapon_radius"]))
	cs.add_component(entity_id,"ProjectileSpeedComponent",ProjectileSpeedComponent.new(data["projectile_speed"]))
	
	return entity_id
