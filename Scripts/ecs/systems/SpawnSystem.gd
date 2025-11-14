# res://ecs/systems/SpawnSystem.gd
extends BaseSystem
class_name SpawnSystem


var db = DataBase

var time_accumulator: float = 0.0
var spawn_radius: float = 20.0        # Радиус появления
var spawn_interval: float = 5.0       # Каждые 5 секунд
var spawn_batch_size: int = 10        # По 10 за раз
var max_height := 5.0
var min_spawn_distance: float = 10.0
var _timer: float = 0.0  
  
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_db :DataBase): 
	super._init(_entity_manager,_component_store)
	db = _db
	
	var char_id = spawn_char("Rigman",Vector3.ZERO) 
	UIManager.hud.owner_id = char_id
	#spawn_weapon("dexecutioner",char_id)
	spawn_weapon("cheese",char_id)
	
func _get_valid_spawn_position(center: Vector3) -> Vector3:
	var pos: Vector3
	var dist: float

	while true:
		var angle = randf() * TAU
		var radius = randf_range(min_spawn_distance, spawn_radius)
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		var y = randf() * max_height
		pos = center + Vector3(x, y, z)

		dist = center.distance_to(pos)
		if dist >= min_spawn_distance:
			break
	
	return pos
	
	
func update(delta: float) -> void:
	#for e_id in get_entities_with(["PendingSpawnComponent"]):
		#var pending = cs.get_component(e_id, "PendingSpawnComponent")
		#match pending.type:
			#"card":
				#pass
			#"enemy":
				#pass
			#"weapon":
				#pass
			#"char":
				#pass
		#spawn_card(pending.item_id, e_id)
		#cs.remove_component(e_id, "PendingSpawnComponent")
	
	_timer += delta

	if _timer >= spawn_interval:
		_timer -= spawn_interval
		for i in range(10):
			var pos = _get_valid_spawn_position(Vector3(0.0,-1.0,0.0))
			spawn_enemy("Aboba",Vector3(pos))
			
		
## Creates entity data only — without spawning visuals.
func spawn_enemy(enemy_name: String, position: Vector3) -> int:
	

	if not db.enemy_configs.has(enemy_name):
		push_warning("Unknown enemy name: %s" % enemy_name)
		return -1
	
	var data = db.enemy_configs[enemy_name]
	var entity_id = em.create_entity()
	cs.add_component(entity_id, "EnemyComponent", EnemyComponent.new())
	cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	cs.add_component(entity_id, "MaxHpComponent", MaxHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "CurrentHpComponent",CurrentHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
	cs.add_component(entity_id, "TargetComponent",TargetComponent.new())
	cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(data["movespeed"]))
	cs.add_component(entity_id, "TeamComponent", TeamComponent.new(2))
	cs.add_component(entity_id, "XPRewardComponent", XPRewardComponent.new(data['xp_reward']))
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
	if not db.char_configs.has(char_name):
		push_warning("Unknown char name : %s" % char_name)
		return -1
	
	var data = db.char_configs[char_name]
	var entity_id = em.create_entity()
	cs.add_component(entity_id, "PlayerComponent", PlayerComponent.new())
	cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(data["movespeed"]))
	cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	cs.add_component(entity_id, "MaxHpComponent", MaxHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "CurrentHpComponent",CurrentHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
	cs.add_component(entity_id, "DamageComponent", DamageComponent.new())
	cs.add_component(entity_id, "ControllerStateComponent", ControllerStateComponent.new())
	cs.add_component(entity_id, "TeamComponent", TeamComponent.new(3))
	cs.add_component(entity_id, "LevelComponent", LevelComponent.new())
	cs.add_component(entity_id, "XPPickUpRangeComponent", XPPickUpRangeComponent.new(data["xp_pickup_range"]))
	cs.add_component(entity_id, "XPMultComponent", XPMultComponent.new())
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
	if not db.weapon_configs.has(_name):
		push_warning("Unknown char name : %s" % _name)
		return -1
		
	var data = db.weapon_configs[_name]
	var entity_id = em.create_entity()
	if _name == "cheese":
		cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, data["cd"], owner_id))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(data["damage"]))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
		cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(data["projectile_count"]))
		cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new(data["projectile_radius"]))
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(data["weapon_radius"]))
		cs.add_component(entity_id,"ProjectileSpeedComponent",ProjectileSpeedComponent.new(data["projectile_speed"]))
	
	elif _name == "aura":
		cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, data["cd"], owner_id))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(data["damage"]))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(data["weapon_radius"]))
		cs.add_component(entity_id, "AuraComponent", AuraComponent.new())
		 
	return entity_id
	
func spawn_card(_name:String, owner_id:int):
	if not db.card_configs.has(_name):
		push_warning("Unknown card name : %s" % _name)
		return -1
		
	#var data = db.card_configs[_name]
	var entity_id = em.create_entity()
	cs.add_component(entity_id, "CardComponent", CardComponent.new(_name,owner_id))

	return entity_id
