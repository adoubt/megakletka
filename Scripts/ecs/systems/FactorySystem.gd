extends BaseSystem
class_name FactorySystem
##TODO сейчас методы на мульти спавн принимают Array а потом вызывают метод с позиционными аргументами, 
## решение - методы сделать так же под дату
## TODO push_warning = cringe. Must have logging 
var db : DataBase
var object_pool : ObjectPool
var damage_popup_arch : Archetype

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus : EventBus,_db :DataBase, _object_pool: ObjectPool): 
	super._init(_entity_manager,_component_store,_event_bus)
	db = _db
	object_pool = _object_pool
	
	event_bus.subscribe("create_poi", _create_pois)
	event_bus.subscribe("create_item", _create_items)
	event_bus.subscribe("create_char", _create_chars)
	event_bus.subscribe("create_enemy", _create_enemies)
	#event_bus.subscribe("create_slot", _create_slots)
	event_bus.subscribe("create_weapon", _create_weapons)
	event_bus.subscribe("create_xp", _create_xp)
	event_bus.subscribe("create_projectile", _create_projectiles)
	event_bus.subscribe("create_camera", _create_camera)
	event_bus.subscribe("DAMAGE_RECIVED", _create_damage_popup)
	event_bus.subscribe("DAMAGE_RECIVED", _create_hit_vfx)
	damage_popup_arch = cs.register_archetype(["DamagePopupComponent","RenderComponent", "LifeTimeComponent", "TransformComponent"], ["DeadComponent"])	
func _create_projectiles(data_array: Array = []) -> void:
	for data in data_array:
		var entity_id := em.create_entity()
		cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(data.projectile_speed))
		cs.add_component(entity_id, "MoveSpeedMultComponent",MoveSpeedMultComponent.new(1.0))

		cs.add_component(entity_id, "HasStatsComponent", HasStatsComponent.new())
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
		cs.add_component(entity_id,"AimComponent", AimComponent.new(data.direction, true))
		
func _create_pois(data_array: Array = []) -> void:
	for data in data_array:
			
		var poi_name: String = data["poi_name"]
		if not db.poi_configs.has(poi_name):
			push_warning("Unknown enemy name: %s" % poi_name)
			
		
		var position: Vector3 = data.get("position", Vector3.ZERO)
		
		
		var e_data = db.poi_configs[poi_name]	
		var entity_id = em.create_entity()	
		var mushroom_mult_size:float = data.get("mushroom_mult_size",1.0)
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
		
		var is_mushroom = e_data.get("mushroom", false)
		cs.add_component(entity_id, "POIComponent", POIComponent.new(poi_name, is_mushroom,mushroom_mult_size))
		
		cs.add_component(entity_id, "InteractionTargetComponent", InteractionTargetComponent.new(
			e_data.interact_radius + 0.2 * mushroom_mult_size, 
			e_data.target_priority, 
			e_data.interact_type))
			
		var radius :float= e_data.collider_radius * mushroom_mult_size
	
		cs.add_component(entity_id, "CollisionComponent", CollisionComponent.new(
			CollisionLayers.WORLD, 
			CollisionLayers.WORLD,
			radius))
		cs.add_component(entity_id, "GravityComponent", GravityComponent.new())
		var scene = e_data.get("scene", null)
		var render_comp = RenderComponent.new()
		if scene: render_comp.scene_path = scene
		cs.add_component(entity_id, "RenderComponent", render_comp)
		var slots_count:int = 0
		if e_data.has("slots"):
			slots_count = e_data.slots
			if data.has("slots"): slots_count = data.slots
			cs.add_component(entity_id, "SlotsCountComponent",SlotsCountComponent.new(slots_count))
			cs.add_component(entity_id, "UsedSlotsCountComponent", UsedSlotsCountComponent.new())
			cs.add_component(entity_id, "UsedSlotsRecalculateRequestComponent",
		UsedSlotsRecalculateRequestComponent.new())
		match poi_name:
			"campfire":
				cs.get_component(RUN, "RunComponent").campfire_id = entity_id
			"merchant":
				cs.add_component(entity_id,"MerchantActivationRequestComponent", MerchantActivationRequestComponent.new())
	

func _create_enemies(data_array: Array = []) -> void:
	for data in data_array:
		var enemy_name: String = data["enemy_name"]
		if not db.enemy_configs.has(enemy_name):
			push_warning("Unknown enemy name: %s" % enemy_name)
		var position: Vector3 = data["position"]
		
		var e_data = db.enemy_configs[enemy_name]
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "ArmorComponent", ArmorComponent.new(e_data.armor))
		cs.add_component(entity_id, "EnemyComponent", EnemyComponent.new())
		#cs.add_component(entity_id, "HasStatsComponent", HasStatsComponent.new())
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
		cs.add_component(entity_id, "MaxHPComponent", MaxHPComponent.new(e_data["hp"]))
		cs.add_component(entity_id, "CurrentHPComponent",CurrentHPComponent.new(e_data["hp"]))
		cs.add_component(entity_id, "CurrentHPRatioComponent", CurrentHPRatioComponent.new())
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data["scene"], true))
		cs.add_component(entity_id, "EnemyBudgetComponent", EnemyBudgetComponent.new(e_data["budget"]))
		cs.add_component(entity_id, "MoveSpeedComponent",MoveSpeedComponent.new(e_data.movespeed))
		cs.add_component(entity_id, "MoveSpeedMultComponent",MoveSpeedMultComponent.new(e_data.movespeed_mult))

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
		cs.add_component(entity_id, "DamageMultComponent", DamageMultComponent.new(e_data.damage_mult))
		cs.add_component(entity_id, "TargetRequestComponent",TargetRequestComponent.new(e_data.agr_radius,
		CollisionLayers.PLAYER,false
		))
		cs.add_component(entity_id, "PierceComponent",PierceComponent.new(e_data.pierce))
		cs.add_component(entity_id, "BounceComponent",BounceComponent.new(e_data.bounce))
		
		var weapons_to_create:=[]
		for weapon in e_data.weapons:
			weapons_to_create.append({"weapon_name": weapon,"owner_id": entity_id,"position": position})
		event_bus.emit("create_weapon", weapons_to_create)
		cs.add_component(entity_id,"AimComponent", AimComponent.new())
		if not e_data.has("flying"):
			cs.add_component(entity_id, "GravityComponent", GravityComponent.new())
		if e_data.has("abilities") and e_data.abilities != null:
			var abilities_to_create := []
			for ability in e_data.abilities:
				abilities_to_create.append({"owner_id": entity_id, "ability_id": ability})
			_create_modifiers(entity_id, abilities_to_create)	
		
	

func _create_chars(data_array: Array = []):
	for data in data_array:
		
		var char_name : String  = data["char_name"]
		if not db.char_configs.has(char_name):
			push_warning("Unknown char name : %s" % char_name)
		var position : Vector3  = data["position"]
		
		var e_data = db.char_configs[char_name]
		var entity_id = em.create_entity()
		UIManager.set_owner_id(entity_id)
		cs.add_component(entity_id, "ArmorComponent", ArmorComponent.new(e_data.armor))
		
		cs.add_component(entity_id, "InputComponent", InputComponent.new())
		cs.add_component(entity_id, "InRangeInteractionComponent", InRangeInteractionComponent.new())
		#cs.add_component(entity_id, "HasStatsComponent", HasStatsComponent.new())
		cs.add_component(entity_id, "MovementIntentComponent", MovementIntentComponent.new())
		cs.add_component(entity_id, "PlayerComponent", PlayerComponent.new())
		cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new(e_data.movespeed))
		cs.add_component(entity_id, "MoveSpeedMultComponent",MoveSpeedMultComponent.new(e_data.movespeed_mult))
		
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(position))
		cs.add_component(entity_id, "MaxHPComponent", MaxHPComponent.new(e_data.hp))
		cs.add_component(entity_id, "CurrentHPComponent",CurrentHPComponent.new(e_data.hp))
		cs.add_component(entity_id, "CurrentHPRatioComponent", CurrentHPRatioComponent.new())
		cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data.scene,true))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(0.0))
		cs.add_component(entity_id, "DamageMultComponent", DamageMultComponent.new(e_data.damage_mult))
		cs.add_component(entity_id, "CurrentLevelComponent", CurrentLevelComponent.new(0.0))
		cs.add_component(entity_id, "CurrentXPComponent", CurrentXPComponent.new(0.0))
		cs.add_component(entity_id, "RequiredXPComponent", RequiredXPComponent.new(0.0))
		cs.add_component(entity_id, "LevelPointsCountComponent", LevelPointsCountComponent.new(0.0))
		
		cs.add_component(entity_id, "DurationComponent", DurationComponent.new(e_data.duration))
		cs.add_component(entity_id, "LifestealComponent", LifestealComponent.new(0.0))
		cs.add_component(entity_id, "PickUpRangeComponent", PickUpRangeComponent.new(e_data.pickup_range))
		cs.add_component(entity_id, "XPGainComponent", XPGainComponent.new(e_data.xp_gain))
		cs.add_component(entity_id, "AttackSpeedComponent", AttackSpeedComponent.new(e_data.attack_speed))
		cs.add_component(entity_id, "HUDComponent", HUDComponent.new(entity_id))
		cs.add_component(entity_id, "GravityComponent", GravityComponent.new(-20.8))
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
		
		
		cs.add_component(entity_id, "MerchantDiscountComponent", MerchantDiscountComponent.new(e_data.merchant_discount))
		cs.add_component(entity_id, "JumpsCountComponent", JumpsCountComponent.new(e_data.jumps))
		cs.add_component(entity_id, "JumpHeightComponent", JumpHeightComponent.new(e_data.jump_height))
		cs.add_component(entity_id, "JumpsLeftComponent", JumpsLeftComponent.new())
		cs.add_component(entity_id, "JumpsUsedComponent", JumpsLeftComponent.new())
		cs.add_component(entity_id, "SlotsCountComponent",SlotsCountComponent.new(e_data.slots))
		cs.add_component(entity_id, "UsedSlotsRecalculateRequestComponent", UsedSlotsRecalculateRequestComponent.new())
		
		var weapons_to_create:=[]
		for weapon in e_data.weapons:
			weapons_to_create.append({"weapon_name": weapon,"owner_id": entity_id, "position": position})
		event_bus.emit("create_weapon", weapons_to_create)
		
		var items_to_create:= []
		for item in e_data.items:
			items_to_create.append({"item_id":item, "owner_id":entity_id})
		cs.add_component(entity_id, "UsedSlotsCountComponent", UsedSlotsCountComponent.new(
			e_data.slots - e_data.items.size()))
		
		_create_items(items_to_create)	
		cs.add_component(entity_id, "UsedSlotsRecalculateRequestComponent",
		UsedSlotsRecalculateRequestComponent.new())
		#var slots_to_create:=[]
		#for slot in e_data.get("slots", 0):
			#slots_to_create.append({"owner_id": entity_id})
		#if slots_to_create.size() > 0:
			#event_bus.emit("create_slot", slots_to_create)
			
		if data.has("camera") and data.camera: 
			event_bus.emit("create_camera", [{"owner_id": entity_id}])	
		event_bus.emit("players_list_changed",{"new_player_id":entity_id})
		event_bus.emit("hp_changed", {"e_id":entity_id, "current_hp":e_data.hp, "max_hp":e_data.hp})
	
		
		
#TODO create new rombs for biggef xp_value, get this from db	
func _create_xp(data_array: Array = []):
	for data in data_array:
		
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(data["position"]))
		cs.add_component(entity_id, "XPRewardComponent",XPRewardComponent.new(data["xp_value"]))
		cs.add_component(entity_id, "RenderComponent", RenderComponent.new("uid://dosmechqhf3sw", true))
		cs.add_component(entity_id, "PickUpComponent", PickUpComponent.new())
		cs.add_component(entity_id, "MoveSpeedComponent", MoveSpeedComponent.new())
		cs.add_component(entity_id, "MoveSpeedMultComponent",MoveSpeedMultComponent.new(1.0))
		cs.add_component(entity_id, "MovementIntentComponent", MovementIntentComponent.new())
		cs.add_component(entity_id, "GravityComponent", GravityComponent.new())
		cs.add_component(entity_id, "HasStatsComponent", HasStatsComponent.new())
func _create_weapons(data_array: Array = []):
	for data in data_array:
		var _name = data["weapon_name"]
		var owner_id = data["owner_id"]
		if not db.weapon_configs.has(_name):
			push_warning("Unknown char name : %s" % _name)
		
		var e_data = db.weapon_configs[_name]
		var entity_id = em.create_entity()
		cs.add_component(entity_id, "HasStatsComponent", HasStatsComponent.new())
		cs.add_component(entity_id,"WeaponComponent",WeaponComponent.new(_name, e_data.cd, owner_id, e_data.target,e_data["proj_scene"]))
		cs.add_component(entity_id, "DamageComponent", DamageComponent.new(e_data["damage"]))
		cs.add_component(entity_id,"AimComponent", AimComponent.new())
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(data.position))
		cs.add_component(entity_id, "FollowOwnerComponent", FollowOwnerComponent.new(owner_id))
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
		
func _create_items(data_array: Array = []):
	for data in data_array:
		var item_id: int = data["item_id"]
		var owner_id: int = data["owner_id"]
		if not db.item_configs.has(item_id):
			push_warning("Unknown item id : %s" % item_id)
			
		var e_data = db.item_configs[item_id]
		var entity_id = em.create_entity()
		#var slot_mask: int
		cs.add_component(entity_id, "TitleComponent", TitleComponent.new(e_data.get("title", "Item Title"),e_data.get("description","Item Description")))	
		cs.add_component(entity_id, "RenderComponent", RenderComponent.new(e_data.scene, false))
		cs.add_component(entity_id, "TransformComponent", TransformComponent.new(data.get("position",Vector3.ZERO)))
		#if cs.has_component(owner_id, "PlayerComponent"):
			#slot_mask = SlotMask.PLAYER
		#elif cs.has_component(owner_id, "POIComponent"):
			#var poi_name = cs.get_component(owner_id, "POIComponent").name
			#match poi_name:
				#"campfire": 
					#slot_mask = SlotMask.CAMPFIRE
				#"merchant": 
					#slot_mask = SlotMask.MERCHANT
				#_: 
					#printerr("Owner type is not founded to create item")
					#return
		
		#var slot_index: int = data.get("slot_index",0)
		cs.add_component(entity_id, "ItemComponent", ItemComponent.new(item_id))
		cs.add_component(entity_id, "CostComponent", CostComponent.new(e_data.cost))
		
		var transaction = ItemTransactionComponent.new()
		transaction.target_id = owner_id
		transaction.source_id = RUN
		cs.add_component(entity_id, "ItemTransactionComponent", transaction)
		
		#cs.add_component(entity_id, "FollowOwnerComponent", FollowOwnerComponent.new())
		if e_data.has("abilities") and e_data.abilities != null:
			var abilities_to_create := []
			for ability in e_data.abilities:
				abilities_to_create.append({"owner_id": entity_id, "ability_id": ability})
			_create_abilities(abilities_to_create)

func _create_modifiers(target_id:int,data_array: Array = []) -> void:
	for data in data_array:
		var owner_id = data.owner_id
		var abilidy_id = data.ability_id
		if not db.item_ability_configs.has(abilidy_id):
			push_warning("Unknown item id : %s" % abilidy_id)
		var ability_data:Dictionary = db.item_ability_configs[abilidy_id]
		var entity_id = em.create_entity()
			
		
		if ability_data.has("scaling"):
			cs.add_component(entity_id, "ScalingComponent", ScalingComponent.new(ability_data.scaling.per, ability_data.scaling.source_stat,ability_data.scaling.domain))
		
		if ability_data.has("condition"):
			cs.add_component(entity_id, "ConditionComponent",ConditionComponent.new(
				ability_data.condition.type, ability_data.condition.source_stat,ability_data.condition.domain, ability_data.condition.value))
		
		if ability_data.has("trigger"):
			cs.add_component(entity_id, "TriggerComponent", TriggerComponent.new(ability_data.trigger.event, ability_data.trigger.action,ability_data.trigger.value))			
		cs.add_component(entity_id, "ItemAbilityComponent", ItemAbilityComponent.new(owner_id, ability_data.title))
		
		if ability_data.has("target_stat"):
			cs.add_component(entity_id, "ModifierComponent", ModifierComponent.new(target_id,target_id,ability_data.target_stat,ability_data.domain, ability_data.value))
					
func _create_abilities(data_array: Array = []) -> void:
	for data in data_array:
		var owner_id = data.owner_id
		var abilidy_id = data.ability_id
		if not db.item_ability_configs.has(abilidy_id):
			push_warning("Unknown item id : %s" % abilidy_id)
		var ability_data:Dictionary = db.item_ability_configs[abilidy_id]
		var entity_id = em.create_entity()
			
		cs.add_component(entity_id, "TitleComponent", TitleComponent.new(ability_data.get("title", "Ability Title"),ability_data.get("description","Ability Description")))	
		
		if ability_data.has("scaling"):
			cs.add_component(entity_id, "ScalingComponent", ScalingComponent.new(ability_data.scaling.per, ability_data.scaling.source_stat,ability_data.scaling.domain))
		
		if ability_data.has("condition"):
			cs.add_component(entity_id, "ConditionComponent",ConditionComponent.new(
				ability_data.condition.type, ability_data.condition.source_stat,ability_data.condition.domain, ability_data.condition.value))
		
		if ability_data.has("trigger"):
			cs.add_component(entity_id, "TriggerComponent", TriggerComponent.new(ability_data.trigger.event, ability_data.trigger.action,ability_data.trigger.value))			
		cs.add_component(entity_id, "ItemAbilityComponent", ItemAbilityComponent.new(owner_id, ability_data.title))
		
		if ability_data.has("target_stat"):
			cs.add_component(entity_id, "StatModifierComponent", StatModifierComponent.new(ability_data.target_stat,ability_data.domain, ability_data.value))
		


func _create_camera(data_array: Array = []) -> void:
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
		cs.add_component(entity_id, "GravityComponent", GravityComponent.new(0.0))
		
func _create_hit_vfx(data: Dictionary) -> void:
	
	var vfx_name = data.damage_type
	var e_data = db.vfx_configs[vfx_name]
	var entity_id = em.create_entity()
	var owner_id: int = data.owner_id
	cs.add_component(entity_id, "HitVFXComponent", HitVFXComponent.new(owner_id))
	cs.add_component(entity_id, "TransformComponent",TransformComponent.new(data.position))
	cs.add_component(entity_id, "RenderComponent",RenderComponent.new(e_data.scene))
	cs.add_component(entity_id, "LifeTimeComponent", LifeTimeComponent.new(e_data.duration))
	cs.add_component(entity_id, "FollowOwnerComponent", FollowOwnerComponent.new(owner_id))


var DAMAGE_POPUPS_LIMIT :int = 10

func _create_damage_popup(data: Dictionary) -> void:
	
	var drift_x = randf_range(-3.35, 3.35)
	var offset_x = randf_range(-0.5, 0.5)
	var offset :Vector3 = Vector3(offset_x,offset_x,offset_x)
	if damage_popup_arch.entities.size()> DAMAGE_POPUPS_LIMIT:
		return
	
	var popup_entity = em.create_entity()
	cs.add_component(popup_entity, "DamagePopupComponent",DamagePopupComponent.new(
		data.damage,data.damage_type,data.owner_id,data.position+offset,drift_x))
	cs.add_component(popup_entity, "TransformComponent", TransformComponent.new(data.position+offset))
	cs.add_component(popup_entity, "RenderComponent",RenderComponent.new("res://Scenes/Popups/DamagePopup.tscn"))
	cs.add_component(popup_entity, "LifeTimeComponent",LifeTimeComponent.new(0.7))
	cs.add_component(popup_entity, "FollowOwnerComponent", FollowOwnerComponent.new(data.owner_id))
