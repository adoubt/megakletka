extends BaseSystem
class_name LevelUpPopUpSystem


func _init(_entity_manager: EntityManager, _component_store: ComponentStore):
	super._init(_entity_manager, _component_store)
	UIManager.hud.has_upgrade = false
func update(_delta: float) -> void:
	var popups = get_entities_with(["LevelUpPopUpComponent"], ["DeadComponent"])
	

	for popup_id in popups:
		var tf = cs.get_component(popup_id, "TransformComponent")
		var owner_id = cs.get_component(popup_id, "LevelUpPopUpComponent").owner_id
		var owner_tf = cs.get_component(owner_id, "TransformComponent")
		var offer = cs.get_component(owner_id, "LevelUpOfferComponent")

		if not offer:
			cs.add_component(popup_id, "DeadComponent", DeadComponent.new(0.1))
			UIManager.hud.has_upgrade = false
			continue
		else:
			UIManager.hud.has_upgrade = true

		if owner_tf:
			tf.position = owner_tf.position + Vector3(0, 1.5, 0)
		else:
			cs.add_component(popup_id, "DeadComponent", DeadComponent.new(0.1))
