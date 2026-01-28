# res://ecs/systems/FactorySystem.gd
extends BaseSystem
class_name FactorySystem
##TODO сейчас методы на мульти спавн принимают Array а потом вызывают метод с позиционными аргументами, 
## решение - методы сделать так же под дату
## TODO push_warning = cringe. Must have logging 
var db : DataBase
var object_pool : ObjectPool

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus : EventBus,_db :DataBase, _object_pool: ObjectPool): 
	super._init(_entity_manager,_component_store,_event_bus)
	db = _db
	object_pool = _object_pool
	
	event_bus.subscribe("create_poi", _create_poi)
	event_bus.subscribe("create_item", _create_item)
	event_bus.subscribe("create_char", _create_char)
	event_bus.subscribe("create_enemy", _create_enemy)
	event_bus.subscribe("create_slot", _create_slot)
	event_bus.subscribe("create_weapon", _create_weapon)
	event_bus.subscribe("create_xp", _create_xp)
	event_bus.subscribe("create_projectile", _create_projectile)
	event_bus.subscribe("create_camera", _create_camera)
	event_bus.subscribe("damage_done", _create_damage_popup)
	event_bus.subscribe("damage_done", _create_hit_vfx)
	
func _create_projectile(data_array: Array) -> void:
	for data in data_array:
		var entity_id := em.create_entity()
		cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(data.projectile_speed))
		
		cs.add_component(entity_id, "TransformComponent",TransformComponent.new(data.position))
		cs.add_component(entity_id, "GravityComponent", GravityComponent.new())
		var proj = ProjectileComponent.new()
		proj.owner_id = data.owner_id
		proj.move_type = data.move_type
		

		if data.has("pierce"):
			cs.add_component(entity_id, "PierceComponent", PierceComponent.new(data.pierce))
		if data.has("bounce"):
			cs.add_component(entity_id, "BounceComponent", BounceComponent.new(data.bounce))
		if data.has("damage"):
			cs.add_component(entity_id, "DamageComponent", DamageComponent.new(data.damage))

		if data.has("projectile_radius"):
			cs.add_component(entity_id,"CollisionComponent",
				CollisionComponent.new(data.collision_layer, data.collision_mask, data.projectile_radius))

		if data.has("duration"):
			cs.add_component(entity_id, "LifeTimeComponent", LifeTimeComponent.new(data.duration))
			
		
		if data.move_type == ProjectileMoveType.ORBIT:
			var orbit := OrbitComponent.new()
			orbit.radius = data.orbit_radius
			orbit.angle = data.orbit_angle
			orbit.height = data.orbit_height
			cs.add_component(entity_id, "OrbitComponent", orbit)
			
		elif data.move_type == ProjectileMoveType.LINEAR and data.has("direction"):
			cs.add_component(entity_id, "MovementIntentComponent", MovementIntentComponent.new(data.direction))	
			
		if data.has("render_path") and data.render_path != "":
			cs.add_component(entity_id, "RenderComponent",
				RenderComponent.new(data.render_path, data.render_shadow))
		cs.add_component(entity_id, "ProjectileComponent", proj)

func _create_poi(data_array: Array) -> void:
	for data in data_array:
			
		var poi_name: String = data["poi_name"]
		if not db.poi_configs.has(poi_name):
			push_warning("Unknown enemy name: %s" % poi_name)
			
		var day_id:int= data["day_id"]
		var position: Vector3 = data["position"]
		
		
		var e_data = db.poi_configs[poi_name]	
		var entity_id = em.create_entity()	
		
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
		cs.add_component(entity_id, "DayIdComponent", DayIdComponent.new(day_id))
		cs.add_component(entity_id, "POIComponent", POIComponent.new(poi_name))
		cs.add_component(entity_id, "InteractionTargetComponent", InteractionTargetComponent.new(e_data["interact_radius"], e_data["target_priority"]))
		#cs.add_component(entity_id, "CollisionComponent", CollisionComponent.new(
			#CollisionLayers.WORLD, 
			#CollisionLayers.PLAYER |
			#CollisionLayers.ENEMY | 
			#CollisionLayers.ENEMY_PROJECTILE |
			#CollisionLayers.PLAYER_PROJECTILE,
			#e_data["collider_radius"]))
		cs.add_component(entity_id, "GravityComponent", GravityComponent.new())
		cs.add_component(entity_id, "RenderComponent", RenderComponent.new(e_data["scene"]))
		
		var slots := int(e_data.get("slots", 0))
		for slot in slots:
			event_bus.emit("сreate_slot", [{"owner_id": entity_id}])
		if poi_name == "campfire": event_bus.emit("campfire_created",[])	
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
		cs.add_component(entity_id, "CurrentHpRatioComponent", CurrentHpRatioComponent.new())
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data["scene"], true))
		cs.add_component(entity_id, "EnemyBudgetComponent", EnemyBudgetComponent.new(e_data["budget"]))
		cs.add_component(entity_id, "MoveSpeedComponent",MoveSpeedComponent.new(e_data.movespeed))
		cs.add_component(entity_id, "MovementIntentComponent", MovementIntentComponent.new())

		cs.add_component(entity_id, "XPRewardComponent", XPRewardComponent.new(e_data['budget']))
		cs.add_component(entity_id, "AttackSpeedComponent", AttackSpeedComponent.new(e_data["attack_speed"]))
		cs.add_component(entity_id, "CollisionComponent",CollisionComponent.new(
			CollisionLayers.ENEMY,
			CollisionLayers.PLAYER | 
			CollisionLayers.WORLD | CollisionLayers.ENEMY |
			CollisionLayers.PLAYER_PROJECTILE,
			e_data["collider_radius"]
		))
		cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new())
		cs.add_component(entity_id, "DurationComponent", DurationComponent.new(e_data.duration))
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(e_data.weapon_radius))
		cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(0))
		cs.add_component(entity_id, "ProjectileSpeedComponent",ProjectileSpeedComponent.new())
		
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(e_data.damage))
		cs.add_component(entity_id, "TargetRequestComponent",TargetRequestComponent.new(e_data.agr_radius,
		CollisionLayers.PLAYER,false
		))
		cs.add_component(entity_id, "PierceComponent",PierceComponent.new(e_data.pierce))
		cs.add_component(entity_id, "BounceComponent",BounceComponent.new(e_data.bounce))
		if e_data.has("weapon_name"):
			event_bus.emit("create_weapon", [{"weapon_name":e_data["weapon_name"],"owner_id": entity_id}])
		if not e_data.has("flying"):
			cs.add_component(entity_id, "GravityComponent", GravityComponent.new())
			
		
	

func _create_char(data_array: Array):
	for data in data_array:
		
		var char_name : String  = data["char_name"]
		if not db.char_configs.has(char_name):
			push_warning("Unknown char name : %s" % char_name)
		var position : Vector3  = data["position"]
		
		var e_data = db.char_configs[char_name]
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "InputComponent", InputComponent.new())
		cs.add_component(entity_id, "MovementIntentComponent", MovementIntentComponent.new())
		cs.add_component(entity_id, "PlayerComponent", PlayerComponent.new())
		cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(e_data.movespeed))
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
		cs.add_component(entity_id, "MaxHpComponent", MaxHpComponent.new(e_data.hp))
		cs.add_component(entity_id, "CurrentHpComponent",CurrentHpComponent.new(e_data.hp))
		cs.add_component(entity_id, "CurrentHpRatioComponent", CurrentHpRatioComponent.new())
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data.scene,true))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(e_data.damage))
		cs.add_component(entity_id, "ControllerStateComponent", ControllerStateComponent.new())
		cs.add_component(entity_id, "LevelComponent", LevelComponent.new())
		cs.add_component(entity_id, "DurationComponent", DurationComponent.new(e_data.duration))
		cs.add_component(entity_id, "LifestealComponent", LifestealComponent.new(0.0))
		cs.add_component(entity_id, "PickUpRangeComponent", PickUpRangeComponent.new(e_data.pickup_range))
		cs.add_component(entity_id, "XPMultComponent", XPMultComponent.new())
		cs.add_component(entity_id, "AttackSpeedComponent", AttackSpeedComponent.new(e_data.attack_speed))
		cs.add_component(entity_id, "HUDComponent", HUDComponent.new(entity_id))
		cs.add_component(entity_id, "GravityComponent", GravityComponent.new())
		cs.add_component(entity_id, "CollisionComponent",
		CollisionComponent.new(
			CollisionLayers.PLAYER,
			CollisionLayers.ENEMY | 
			CollisionLayers.WORLD | CollisionLayers.ENEMY_PROJECTILE,
			e_data["collider_radius"]
		))
		cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new())
		cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new())
		cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(0))
		cs.add_component(entity_id, "ProjectileSpeedComponent",ProjectileSpeedComponent.new())
		cs.add_component(entity_id, "PierceComponent",PierceComponent.new(e_data.pierce))
		cs.add_component(entity_id, "BounceComponent",BounceComponent.new(e_data.bounce))
		cs.add_component(entity_id, "JumpComponent", JumpComponent.new(e_data.jumps))
		event_bus.emit("create_weapon", [{"weapon_name":e_data["weapon_name"],"owner_id": entity_id}])
		
		for slot in e_data["slots"]:
			event_bus.emit("create_slot", [{"owner_id": entity_id}])
		if data.has("camera") and data.camera: 
			event_bus.emit("create_camera", [{"owner_id": entity_id}])	
		
#TODO create new rombs for biggef xp_value, get this from db	
func _create_xp(data_array: Array):
	for data in data_array:
		
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(data["position"]))
		cs.add_component(entity_id, "XPRewardComponent",XPRewardComponent.new(data["xp_value"]))
		cs.add_component(entity_id, "RenderComponent", RenderComponent.new("uid://dosmechqhf3sw", true))
		cs.add_component(entity_id, "PickUpComponent", PickUpComponent.new())
		cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new())
		cs.add_component(entity_id, "MovementIntentComponent", MovementIntentComponent.new())
		cs.add_component(entity_id, "GravityComponent", GravityComponent.new())
func _create_weapon(data_array: Array):
	for data in data_array:
		var _name = data["weapon_name"]
		var owner_id = data["owner_id"]
		if not db.weapon_configs.has(_name):
			push_warning("Unknown char name : %s" % _name)
		
		var e_data = db.weapon_configs[_name]
		var entity_id = em.create_entity()
		
		cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, e_data.cd, owner_id, e_data.target))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(e_data["damage"]))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data["scene"], e_data.shadow))
		
		if e_data.has("projectile_speed"):
			cs.add_component(entity_id,"ProjectileSpeedComponent",ProjectileSpeedComponent.new(e_data["projectile_speed"]))
		if e_data.has("projectile_count"):
			cs.add_component(entity_id, "ProjectileCountComponent", ProjectileCountComponent.new(e_data["projectile_count"]))
		
		if e_data.has("projectile_radius"):
			cs.add_component(entity_id, "ProjectileRadiusComponent", ProjectileRadiusComponent.new(e_data["projectile_radius"]))
		
		if e_data.has("weapon_radius"):
			cs.add_component(entity_id, "WeaponRadiusComponent", WeaponRadiusComponent.new(e_data["weapon_radius"]))
		if e_data.has("duration"):
			cs.add_component(entity_id, "DurationComponent", DurationComponent.new(e_data["duration"]))
		
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

func _create_camera(data_array: Array) -> void:
	for data in data_array:
		var owner_id = data["owner_id"]
		var entity_id = em.create_entity()

		var cam_comp = CameraComponent.new(owner_id)
		cam_comp.camera_instance = object_pool.get_instance("res://Scenes/player_camera.tscn")
		cam_comp.camera_instance.current = true
		cam_comp.camera_instance.visible = true
		#ControllerManager.register(cam_comp.camera_instance)
		#ControllerManager.activate_default(cam_comp.camera_instance)
		cs.add_component(entity_id, "CameraComponent", cam_comp)
		cs.add_component(entity_id, "CameraEffectsComponent",CameraEffectsComponent.new())
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new())
		
func _create_hit_vfx(data_array: Array) -> void:
	for data in data_array:
		var vfx_name = data.damage_type
		var e_data = db.vfx_configs[vfx_name]
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "HitVFXComponent", HitVFXComponent.new(data.owner_id))
		cs.add_component(entity_id, "TransformComponent",TransformComponent.new(data.position))
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data.scene))
		cs.add_component(entity_id, "LifeTimeComponent", LifeTimeComponent.new(e_data.duration))

func _create_damage_popup(data_array: Array) -> void:
	for data in data_array:
		var popup_entity = em.create_entity()
		cs.add_component(popup_entity, "DamagePopupComponent",DamagePopupComponent.new(data.damage,data.damage_type,data.owner_id,data.position))
		cs.add_component(popup_entity, "TransformComponent", TransformComponent.new(data.position))
		cs.add_component(popup_entity, "RenderComponent",RenderComponent.new("res://Scenes/Popups/DamagePopup.tscn"))
		cs.add_component(popup_entity, "LifeTimeComponent",LifeTimeComponent.new(1.0))
			
