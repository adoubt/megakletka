# res://ecs/systems/FactorySystem.gd
extends BaseSystem
class_name FactorySystem
##TODO сейчас методы на мульти спавн принимают Array а потом вызывают метод с позиционными аргументами, 
## решение - методы сделать так же под дату
## TODO push_warning = cringe. Must have logging 
var db = DataBase
var event_bus : EventBus

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_db :DataBase,_event_bus : EventBus): 
	super._init(_entity_manager,_component_store)
	db = _db
	event_bus = _event_bus
	event_bus.subscribe("create_poi", _create_poi)
	event_bus.subscribe("create_item", _create_item)
	event_bus.subscribe("create_char", _create_char)
	event_bus.subscribe("create_enemy", _create_enemy)
	event_bus.subscribe("create_slot", _create_slot)
	event_bus.subscribe("create_weapon", _create_weapon)
	
func _create_poi(data_array: Array) -> void:
	for data in data_array:
			
		var poi_name: String = data["poi_name"]
		if not db.poi_configs.has(poi_name):
			push_warning("Unknown enemy name: %s" % poi_name)
			
		var floor_id:int= data["floor_id"]
		var position: Vector3 = data["position"]
		
		
		var e_data = db.poi_configs[poi_name]	
		var entity_id = em.create_entity()	
		
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
		cs.add_component(entity_id, "FloorIdComponent", FloorIdComponent.new(floor_id))
		cs.add_component(entity_id, "POIComponent", POIComponent.new(poi_name))
		cs.add_component(entity_id, "InteractionTargetComponent", InteractionTargetComponent.new(e_data["interact_radius"], e_data["target_priority"]))
		cs.add_component(entity_id, "CollisionComponent", CollisionComponent.new(
			CollisionLayers.Layer.WORLD, 
			CollisionLayers.Layer.PLAYER |
			CollisionLayers.Layer.ENEMY | 
			CollisionLayers.Layer.ENEMY_PROJECTILE |
			CollisionLayers.Layer.PLAYER_PROJECTILE,
			e_data["collider_radius"]))
		cs.add_component(entity_id, "RenderComponent", RenderComponent.new(e_data["scene"]))
		
		var slots := int(e_data.get("slots", 0))
		for slot in slots:
			event_bus.emit("сreate_slot", [{"owner_id": entity_id}])
	event_bus.emit("POI_CREATED")

func _create_enemy(data_array: Array) -> void:
	for data in data_array:
		var enemy_name: String = data["enemy_name"]
		if not db.enemy_configs.has(enemy_name):
			push_warning("Unknown enemy name: %s" % enemy_name)
		var position: Vector3 = data["position"]
		
		var e_data = db.enemy_configs[enemy_name]
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "EnemyComponent", EnemyComponent.new())
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
		cs.add_component(entity_id, "MaxHpComponent", MaxHpComponent.new(e_data["hp"]))
		cs.add_component(entity_id, "CurrentHpComponent",CurrentHpComponent.new(e_data["hp"]))
		cs.add_component(entity_id, "CurrentHpRatioComponent", CurrentHpRatioComponent.new(1))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data["scene"],true))
		cs.add_component(entity_id, "TargetComponent",TargetComponent.new())
		cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(e_data["movespeed"]))
		cs.add_component(entity_id, "TeamComponent", TeamComponent.new(2))
		cs.add_component(entity_id, "XPRewardComponent", XPRewardComponent.new(e_data['xp_reward']))
		cs.add_component(entity_id, "AttackSpeedComponent", AttackSpeedComponent.new())
		cs.add_component(entity_id, "CollisionComponent",
		CollisionComponent.new(
			CollisionLayers.Layer.ENEMY,
			CollisionLayers.Layer.PLAYER | 
			CollisionLayers.Layer.WORLD | 
			CollisionLayers.Layer.PLAYER_PROJECTILE |
			CollisionLayers.Layer.ENEMY,
			e_data["collider_radius"]
		))
		cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new())
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new())
		cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new())
		cs.add_component(entity_id,"ProjectileSpeedComponent",ProjectileSpeedComponent.new())
		cs.add_component(entity_id,"GroundedComponent", GroundedComponent.new())
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new())
		
	

func _create_char(data_array: Array):
	for data in data_array:
		
		var char_name : String  = data["char_name"]
		if not db.char_configs.has(char_name):
			push_warning("Unknown char name : %s" % char_name)
		var position : Vector3  = data["position"]
		
		var e_data = db.char_configs[char_name]
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "PlayerComponent", PlayerComponent.new())
		cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(e_data["movespeed"]))
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
		cs.add_component(entity_id, "MaxHpComponent", MaxHpComponent.new(e_data["hp"]))
		cs.add_component(entity_id, "CurrentHpComponent",CurrentHpComponent.new(e_data["hp"]))
		cs.add_component(entity_id,"CurrentHpRatioComponent", CurrentHpRatioComponent.new(1))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data["scene"],true))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new())
		cs.add_component(entity_id, "ControllerStateComponent", ControllerStateComponent.new())
		cs.add_component(entity_id, "TeamComponent", TeamComponent.new(3))
		cs.add_component(entity_id, "LevelComponent", LevelComponent.new())
		cs.add_component(entity_id, "LifestealComponent", LifestealComponent.new(0))
		cs.add_component(entity_id, "XPPickUpRangeComponent", XPPickUpRangeComponent.new(e_data["xp_pickup_range"]))
		cs.add_component(entity_id, "XPMultComponent", XPMultComponent.new())
		cs.add_component(entity_id, "AttackSpeedComponent", AttackSpeedComponent.new())
		cs.add_component(entity_id, "HUDComponent", HUDComponent.new(entity_id))
		
		cs.add_component(entity_id, "CollisionComponent",
		CollisionComponent.new(
			CollisionLayers.Layer.PLAYER,
			CollisionLayers.Layer.ENEMY |
			CollisionLayers.Layer.PLAYER | 
			CollisionLayers.Layer.WORLD | CollisionLayers.Layer.ENEMY_PROJECTILE,
			e_data["collider_radius"]
		))
		cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new())
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new())
		cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(0))
		cs.add_component(entity_id, "ProjectileSpeedComponent",ProjectileSpeedComponent.new())
		
		event_bus.emit("create_weapon", [{"weapon_name":e_data["weapon_name"],"owner_id": entity_id}])
		
		for slot in e_data["slots"]:
			event_bus.emit("create_slot", [{"owner_id": entity_id}])
	
func _create_weapon(data_array: Array):
	for data in data_array:
		var _name = data["weapon_name"]
		var owner_id = data["owner_id"]
		if not db.weapon_configs.has(_name):
			push_warning("Unknown char name : %s" % _name)
		
		var e_data = db.weapon_configs[_name]
		var entity_id = em.create_entity()
		if _name == "carrot":
			cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, e_data["cd"], owner_id))
			cs.add_component(entity_id, "DamageComponent", DamageComponent.new(e_data["damage"]))
			cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data["scene"],true))
			cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(e_data["projectile_count"]))
			cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new(e_data["projectile_radius"]))
			cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(e_data["weapon_radius"]))
			cs.add_component(entity_id,"ProjectileSpeedComponent",ProjectileSpeedComponent.new(e_data["projectile_speed"]))
		
func _create_item(data_array: Array):
	for data in data_array:
		var item_name: String = data["item_name"]
		var owner_id: int = data["owner_id"]
		if not db.item_configs.has(item_name):
			push_warning("Unknown card name : %s" % item_name)
			
		var e_data = db.item_configs[item_name]
		var entity_id = em.create_entity()
		
		cs.add_component(entity_id, "ItemComponent", ItemComponent.new(item_name, owner_id))

		if e_data.has("abilities") and e_data.abilities != null:
			var abilities_list = []
			if typeof(e_data.abilities) == TYPE_ARRAY:
				abilities_list = e_data.abilities
			elif typeof(e_data.abilities) == TYPE_DICTIONARY:
				abilities_list.append(e_data.abilities)

			for ability in abilities_list:

				cs.add_component(entity_id, ability.stat.resource_path.get_file().get_basename(), ability.stat.new(ability.value))

	
func _create_slot(data_array: Array) -> void:
	for data in data_array:
		var owner_id = data["owner_id"]
		var slots = get_entities_with(["SlotComponent"])
		var owner_slots: int = 0
		for slot in slots:
			if (cs.get_component(slot,"SlotComponent").owner_id == owner_id): owner_slots +=1 
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "SlotComponent", SlotComponent.new(owner_id,owner_slots))
	event_bus.emit("slots_created")
