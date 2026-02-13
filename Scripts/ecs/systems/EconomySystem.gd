extends BaseSystem
class_name EconomySystem


func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["RunComponent","BalanceChangeRequestComponent"])

func update(_delta:float) -> void:
	var entities = arch.entities.duplicate()
	for e in arch.entities:
		var run = cs.get_component(e, "RunComponent")
		var req = cs.get_component(e,"BalanceChangeRequestComponent")
		if !req.allow_negative and run.logs + req.amount < 0:
			continue # отклоняем

		run.logs += req.amount
		event_bus.emit("balance_changed", {"balance":run.logs, "value": req.amount})
		cs.remove_component(e,"BalanceChangeRequestComponent")
