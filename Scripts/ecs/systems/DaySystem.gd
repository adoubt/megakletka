extends BaseSystem
class_name DaySystem


var days_arch: Archetype
var player_arch: Archetype
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus, ):
	super._init(_entity_manager, _component_store, _event_bus)

	event_bus.subscribe("combat_completed", _on_combat_completed)
	days_arch = cs.register_archetype(["DayGroundComponent","DayComponent"])
	
	player_arch =cs.register_archetype(["PlayerComponent"], ["DeadComponent", "RespawnableComponent"])
func _change_day(data: Dictionary={})->void:
	var days = days_arch.entities.duplicate()
	var run_comp = cs.get_component(RUN,"RunComponent")
	run_comp.current_day+= 1
	if run_comp.current_day >= days.size() :
		
		SceneManager.go_to_intro()
		return
	var logs_before = run_comp.logs
	run_comp.logs= clamp(run_comp.logs -3, 0 ,logs_before)
	if logs_before < 3:
		_kill_players()
		#SceneManager.go_to_intro()
	_day_reward()
	event_bus.emit("day_changed", {"current_day": run_comp.current_day})
	
func _on_combat_completed(data: Dictionary):
	_combat_reward(data)
	
func _combat_reward(data: Dictionary):
	var day_e = data.current_day
	var phase = data.current_phase
	var day_index = data.day_index
	var reward = cs.get_component(day_e,"CombatRewardComponent")
	
	var log_reward:int = reward.logs - phase
	cs.add_component(RUN, "BalanceChangeRequestComponent", BalanceChangeRequestComponent.new(log_reward, "combat_reward",day_e))

func _kill_players()->void:
	
	for e in player_arch.entities:
		cs.add_component(e,"DeathRequestComponent", DeathRequestComponent.new(RUN))
func _day_reward()->void:
	for e in player_arch.entities:
		cs.get_component(e, "SlotsCountComponent").base_value+=1
		cs.add_component(e, "DirtyStatsComponent",DirtyStatsComponent.new())
