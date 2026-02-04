extends BaseSystem
class_name DaySystem


var days_arch: Archetype

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus, ):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("change_day_request", _change_day)
	event_bus.subscribe("combat_completed", _on_combat_completed)
	days_arch = cs.register_archetype(["DayComponent","DayIdComponent"])
	
	
func _change_day(data: Dictionary={})->void:
	var days = days_arch.entities.duplicate()
	var run_comp = cs.get_component(RUN,"RunComponent")
	run_comp.current_day+= 1
	if run_comp.current_day >= days.size() :
		SceneManager.go_to_intro()
		return
	run_comp.logs -=3
	if run_comp.logs < 0:
		SceneManager.go_to_intro()
	
	event_bus.emit("day_changed", {"current_day": run_comp.current_day})
	event_bus.emit("balance_changed", {"current_balance": run_comp.logs, "value": 3.0})
func _on_combat_completed(data: Dictionary):
	_reward(data)
	
func _reward(data: Dictionary):
	var day_e = data.current_day
	var phase = data.current_phase
	var day_index = data.day_index
	var reward = cs.get_component(day_e,"CombatRewardComponent")
	
	var log_reward:int = reward.logs - phase
	cs.add_component(RUN, "BalanceChangeRequestComponent", BalanceChangeRequestComponent.new(log_reward, "combat_reward",day_e))


	
