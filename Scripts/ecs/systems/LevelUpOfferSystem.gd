extends BaseSystem
class_name LevelUpOfferSystem


var db :DataBase

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus,_database :DataBase):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus = _event_bus
	db =_database
	event_bus.subscribe("upgrade_chosen", _on_upgrade_chosen)

	arch = cs.register_archetype(["LevelPointsCountComponent","RenderComponent"],
		["DeadComponent", "ActiveOfferComponent"])	


func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()
	for player in entities:
		
		if cs.get_component(player, "LevelPointsCountComponent").final_value <= 0:
			continue

		var choices = _generate_random_upgrades(player)

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
					
		

func _generate_random_upgrades(_e_id: int, count: int = 3) -> Array:
	var pool := []

	
	for item_id in db.item_configs.keys():
		var item_data = db.item_configs[item_id]
		var weight = item_data.get("drop_weight", 1)
		for i in range(weight):
			pool.append(item_id)

	
	pool.shuffle()

	
	var chosen := []
	for item_id in pool:
		if item_id in chosen:
			continue
		chosen.append(item_id)
		if chosen.size() >= count:
			break

	return chosen
	
func _on_upgrade_chosen(data: Dictionary):
	var offer_entity = data["entity_id"]
	var index = data["choice_index"]

	if not cs.has_component(offer_entity, "LevelUpOfferComponent"):
		return

	var offer = cs.get_component(offer_entity, "LevelUpOfferComponent")
	offer.chosen_index = index
