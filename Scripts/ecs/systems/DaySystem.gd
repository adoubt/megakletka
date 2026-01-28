extends BaseSystem
class_name DaySystem
var run_entity:int=-1
var days: Array = []
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus, ):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("change_day_request", _change_day)
	event_bus.subscribe("combat_completed", _reward)

func _change_day():

	if days == []:
		days = get_entities_with(["DayComponent"])
	
	if run_entity ==-1:
		run_entity = get_entities_with(["RunComponent"])[0]	
		
	var run_comp = cs.get_component(run_entity,"RunComponent")
	
	if run_comp.current_day >= days.size():
		cs.clear()
		em.clear()
		
		SceneManager.go_to_intro()
		return
	run_comp.current_day+=1
	
	event_bus.emit("day_changed", {"current_day": run_comp.current_day})
	
func _reward(data: Dictionary):
	var day_e = data.current_day
	var phase = data.current_phase
	var day_index = data.day_index
	var reward = cs.get_component(day_e,"CombatRewardComponent")
	if run_entity ==-1:
		run_entity = get_entities_with(["RunComponent"])[0]
	var run_comp = cs.get_component(run_entity, "RunComponent")
	
	var log_reward:int = reward.logs - phase
	run_comp.logs += log_reward
	UIManager.hud.set_current_log_balance(run_comp.logs)
