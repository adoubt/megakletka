extends BaseSystem
class_name LevelUpOfferSystem


var db :DataBase

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus,_database :DataBase):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus = _event_bus
	db =_database
	event_bus.subscribe("upgrade_chosen", _on_upgrade_chosen)



	
func _on_upgrade_chosen(data: Dictionary):
	var offer_entity = data["entity_id"]
	var index = data["choice_index"]

	if not cs.has_component(offer_entity, "LevelUpOfferComponent"):
		return

	var offer = cs.get_component(offer_entity, "LevelUpOfferComponent")
	offer.chosen_index = index
	


func update(_delta: float) -> void:
	var players = get_entities_with(
		["LevelComponent"],
		["DeadComponent", "ActiveOfferComponent"]
	)

	for player in players:
		var level = cs.get_component(player, "LevelComponent")
		if level.skill_points <= 0:
			continue

		var choices = generate_random_upgrades(player)

		var offer_id = em.create_entity()
		 
		cs.add_component(
			offer_id,
			"LevelUpOfferComponent",
			LevelUpOfferComponent.new(player, choices)
		)

		cs.add_component(player,"ActiveOfferComponent",ActiveOfferComponent.new(offer_id)
		)

		event_bus.emit("level_up_offer_created", {
			"offer_id": offer_id,
			"offer": choices
		})
		var instance = cs.get_component(player, "RenderComponent").instance
		if instance: 
			instance.show_level_up()
					
		

func generate_random_upgrades(_e_id: int, count: int = 3) -> Array:
	var pool := []

	
	for item_name in db.item_configs.keys():
		var item_data = db.item_configs[item_name]
		var weight = item_data.get("drop_weight", 1)
		for i in range(weight):
			pool.append(item_name)

	
	pool.shuffle()

	
	var chosen := []
	for item_name in pool:
		if item_name in chosen:
			continue
		chosen.append(item_name)
		if chosen.size() >= count:
			break

	return chosen
