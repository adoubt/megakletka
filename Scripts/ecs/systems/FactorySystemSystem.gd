# res://ecs/systems/FactorySystem.gd
extends BaseSystem
class_name FactorySystem
##TODO сейчас методы на мульти спавн принимают Array а потом вызывают метод с позиционными аргументами, 
## решение - методы сделать так же под дату

var db = DataBase
var event_bus : EventBus

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_db :DataBase,_event_bus : EventBus): 
	super._init(_entity_manager,_component_store)
	db = _db
	event_bus = _event_bus
	event_bus.subscribe("create_poi", _create_poi)
	event_bus.subscribe("create_pois", _create_pois)
	event_bus.subscribe("create_item", _create_item)
	event_bus.subscribe("create_char", _create_char)
	event_bus.subscribe("create_enemy", _create_enemy)
	event_bus.subscribe("create_enemies", _create_enemies)


			
func _create_poi(item) -> int:
	var poi_name: String = item["poi_name"]
	var floor_id:int= item["floor_id"]
	var position: Vector3 = item["position"]
	if not db.poi_configs.has(poi_name):
		push_warning("Unknown enemy name: %s" % poi_name)
		return -1
	
	var data = db.poi_configs[poi_name]	
	var entity_id = em.create_entity()	
	
	cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	cs.add_component(entity_id, "FloorIdComponent", FloorIdComponent.new(floor_id))
	cs.add_component(entity_id, "POIComponent", POIComponent.new(poi_name))
	cs.add_component(entity_id, "InteractionTargetComponent", InteractionTargetComponent.new(data["interact_radius"], data["target_priority"]))
	cs.add_component(entity_id, "CollisionComponent", CollisionComponent.new(
		CollisionLayers.Layer.WORLD, 
		CollisionLayers.Layer.PLAYER |
		CollisionLayers.Layer.ENEMY | 
		CollisionLayers.Layer.ENEMY_PROJECTILE |
		CollisionLayers.Layer.PLAYER_PROJECTILE,
		data["collider_radius"]))
	cs.add_component(entity_id, "RenderComponent", RenderComponent.new(data["scene"]))
	
	
	return entity_id

func _create_pois(data: Array) -> void:
	for item in data:
		
		_create_poi(item)
	event_bus.emit("POI_CREATED")
## Creates entity data only — without createing visuals.
func _create_enemy(enemy_name: String, position: Vector3):
	

	if not db.enemy_configs.has(enemy_name):
		push_warning("Unknown enemy name: %s" % enemy_name)
		return -1
	
	var data = db.enemy_configs[enemy_name]
	var entity_id = em.create_entity()
	cs.add_component(entity_id, "EnemyComponent", EnemyComponent.new())
	cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
	cs.add_component(entity_id, "MaxHpComponent", MaxHpComponent.new(data["hp"]))
	cs.add_component(entity_id, "CurrentHpComponent",CurrentHpComponent.new(data["hp"]))
	cs.add_component(entity_id,"CurrentHpRatioComponent", CurrentHpRatioComponent.new(1))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"],true))
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
	

func _create_enemies(callback_data: Array) -> void:
	for item in callback_data:
		var enemy_name: String = item["enemy_name"]
		var position: Vector3 = item["position"]
		_create_enemy(enemy_name, position)

	

func _create_char(callback_data:Dictionary) -> int:
	var char_name : String  = callback_data["char_name"]
	var position : Vector3  = callback_data["position"]
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
	cs.add_component(entity_id,"CurrentHpRatioComponent", CurrentHpRatioComponent.new(1))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"],true))
	cs.add_component(entity_id, "DamageComponent", DamageComponent.new())
	cs.add_component(entity_id, "ControllerStateComponent", ControllerStateComponent.new())
	cs.add_component(entity_id, "TeamComponent", TeamComponent.new(3))
	cs.add_component(entity_id, "LevelComponent", LevelComponent.new())
	cs.add_component(entity_id, "LifestealComponent", LifestealComponent.new(0))
	cs.add_component(entity_id, "XPPickUpRangeComponent", XPPickUpRangeComponent.new(data["xp_pickup_range"]))
	cs.add_component(entity_id, "XPMultComponent", XPMultComponent.new())
	cs.add_component(entity_id, "AttackSpeedComponent", AttackSpeedComponent.new())
	cs.add_component(entity_id, "HUDComponent", HUDComponent.new(entity_id))
	
	cs.add_component(entity_id, "CollisionComponent",
	CollisionComponent.new(
		CollisionLayers.Layer.PLAYER,
		CollisionLayers.Layer.ENEMY |
		CollisionLayers.Layer.PLAYER | 
		CollisionLayers.Layer.WORLD | CollisionLayers.Layer.ENEMY_PROJECTILE,
		data["collider_radius"]
	))
	cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new())
	cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new())
	cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(0))
	cs.add_component(entity_id, "ProjectileSpeedComponent",ProjectileSpeedComponent.new())
	
	#UIManager.hud.owner_id = entity_id
	_create_weapon(data["weapon_name"],entity_id)
	return entity_id

func _create_weapon(_name:String, owner_id:int):
	if not db.weapon_configs.has(_name):
		push_warning("Unknown char name : %s" % _name)
		return -1
		
	var data = db.weapon_configs[_name]
	var entity_id = em.create_entity()
	if _name == "cheese":
		cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, data["cd"], owner_id))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(data["damage"]))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"],true))
		cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(data["projectile_count"]))
		cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new(data["projectile_radius"]))
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(data["weapon_radius"]))
		cs.add_component(entity_id,"ProjectileSpeedComponent",ProjectileSpeedComponent.new(data["projectile_speed"]))
	if _name == "carrot":
		cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, data["cd"], owner_id))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(data["damage"]))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"],true))
		cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(data["projectile_count"]))
		cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new(data["projectile_radius"]))
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(data["weapon_radius"]))
		cs.add_component(entity_id,"ProjectileSpeedComponent",ProjectileSpeedComponent.new(data["projectile_speed"]))
	elif _name == "aura":
		cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, data["cd"], owner_id))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(data["damage"]))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(data["scene"]))
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(data["weapon_radius"]))
		#cs.add_component(entity_id, "AuraComponent", AuraComponent.new())
		 
	return entity_id
	
func _create_item(callback_data: Dictionary) -> int:
	var item_name: String = callback_data["item_name"]
	var owner_id: int = callback_data["owner_id"]
	if not db.item_configs.has(item_name):
		push_warning("Unknown card name : %s" % item_name)
		return -1

	var data = db.item_configs[item_name]
	var entity_id = em.create_entity()
	
	# Основной компонент карты
	cs.add_component(entity_id, "ItemComponent", ItemComponent.new(item_name, owner_id))

	# Добавляем все способности из abilities
	if data.has("abilities") and data.abilities != null:
		var abilities_list = []
		if typeof(data.abilities) == TYPE_ARRAY:
			abilities_list = data.abilities
		elif typeof(data.abilities) == TYPE_DICTIONARY:
			abilities_list.append(data.abilities)

		for ability in abilities_list:
			# ability = {"stat": "ProjectileCountComponent", "value": 3.0}

			cs.add_component(entity_id, ability.stat.resource_path.get_file().get_basename(), ability.stat.new(ability.value))

	return entity_id
