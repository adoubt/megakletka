extends BaseSystem
class_name LevelUpSelectionSystem
var spawn_system: SpawnSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _spawn_system: SpawnSystem):
	super._init(_entity_manager, _component_store)
	spawn_system = _spawn_system
	
func update(_delta: float) -> void:
	var offers = get_entities_with(["LevelUpOfferComponent"])
	for e_id in offers:
		var offer = cs.get_component(e_id, "LevelUpOfferComponent")

		match offer.chosen_index:
			-1:
				continue  # ждём выбора
			-2:
				# Реролл — просто пересоздаём оффер, очки не тратим
				cs.remove_component(e_id, "LevelUpOfferComponent")
				continue
			_:
				# Выбран апгрейд
				var level = cs.get_component(e_id, "LevelComponent")
				if level:
					level.skill_points -= 1
				
				spawn_system.spawn_card(offer.choices[offer.chosen_index], offer.owner_id)
				cs.remove_component(e_id, "LevelUpOfferComponent")
				
