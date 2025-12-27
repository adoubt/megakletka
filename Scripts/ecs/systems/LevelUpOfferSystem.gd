extends BaseSystem
class_name LevelUpOfferSystem

var event_bus:EventBus
var db :DataBase

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus,_database :DataBase):
	super._init(_entity_manager, _component_store)
	event_bus = _event_bus
	db =_database
	event_bus.subscribe("upgrade_chosen", _on_upgrade_chosen)


func _on_upgrade_chosen(data: Dictionary):
	print("🟢 EventBus got event upgrade_chosen:", data)

	var e_id = data["entity_id"]
	var index = data["choice_index"]

	if not cs.has_component(e_id, "LevelUpOfferComponent"):
		print("⚠️ No LevelUpOfferComponent for entity:", e_id)
		return

	var offer = cs.get_component(e_id, "LevelUpOfferComponent")
	offer.chosen_index = index
	print("✅ Chosen upgrade index:", index, "for entity:", e_id)
	
func update(_delta: float) -> void:
	var entities = get_entities_with(["LevelComponent"], ["DeadComponent", "LevelUpOfferComponent"])
	for e_id in entities:
		var level = cs.get_component(e_id, "LevelComponent")
		if level.skill_points <= 0:
			continue
		
		## Генерируем предложение
		var offer = generate_random_upgrades(e_id)
		cs.add_component(e_id, "LevelUpOfferComponent", LevelUpOfferComponent.new(e_id, offer))
		
		UIManager.hud.setup_upgrade_buttons(e_id, offer)
		##Создаем попап
		var popup_id = em.create_entity()
		cs.add_component(popup_id, "LevelUpPopUpComponent", LevelUpPopUpComponent.new(e_id))
		cs.add_component(popup_id, "TransformComponent", TransformComponent.new(
		cs.get_component(e_id, "TransformComponent").position + Vector3(0, 1.5, 0)
		))
		
		cs.add_component(popup_id, "RenderComponent", RenderComponent.new("uid://cg8diy5mqdnwf"))
		
		

func generate_random_upgrades(e_id: int, count: int = 3) -> Array:
	var pool := []

	# создаем weighted pool
	for card_id in db.card_configs.keys():
		var card_data = db.card_configs[card_id]
		var weight = card_data.get("drop_weight", 1)
		for i in range(weight):
			pool.append(card_id)

	# тасуем
	pool.shuffle()

	# берем уникальные карты и ограничиваем count
	var chosen := []
	for card_id in pool:
		if card_id in chosen:
			continue
		chosen.append(card_id)
		if chosen.size() >= count:
			break

	return chosen
