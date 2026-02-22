extends BaseSystem
class_name ApplyModifierSystem
var dirty_arch: Archetype
var mod_arch: Archetype

var players := []
var dead_players: =[]
var alive_players: =[]
var combat_state : int = CombatState.INACTIVE
var phase: int = 1
var run_comp : RunComponent
func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus) 
	dirty_arch = cs.register_archetype(
		["DirtyStatsComponent"],
		["DeadComponent"]
	)

	mod_arch = cs.register_archetype(
		["ModifierComponent"],
		["DeadComponent"]
	)
	event_bus.subscribe("phase_changed", _on_phase_changed)
	event_bus.subscribe("day_changed", _on_day_changed)
	
func update(_delta: float) -> void:
	var modifiers = mod_arch.entities
	#var entities = dirty_arch.entities.duplicate()
	for target in dirty_arch.entities:
		for mod_e in modifiers:
			var value:float = 0.0
			var mod = cs.get_component(mod_e, "ModifierComponent")
			if mod.target_id != target:
				continue
			value = mod.value
			
			var cond = cs.get_component(mod_e, "ConditionComponent")
			if cond:
				if not _check_condition(target, cond):
					continue
			
			var scale = cs.get_component(mod_e, "ScalingComponent")
			
			if scale:
				var source_value = _get_stat_value(target, scale.domain, scale.source)
				value = mod.value * (source_value/scale.per)
				
			_apply_modifier(target, mod, value)
		#cs.remove_component(target, "DirtyStatsComponent")
		
func _apply_modifier(target_id: int, mod: ModifierComponent, value:float) -> void:
	var comp_name := Stats.get_comp_name(mod.domain, mod.stat)
	if comp_name == "":
		return

	var stat_comp = cs.get_component(target_id, comp_name)
	if stat_comp == null:
		return
	
	stat_comp.final_value += value

func _check_condition(target_id: int, cond: ConditionComponent) -> bool:
	
	var current := _get_stat_value(
		target_id,
		cond.domain,
		cond.source
	)

	match cond.type:
		ConditionType.BELOW:
			return current < cond.value
		ConditionType.ABOVE:
			return current > cond.value
		ConditionType.EQUAL:
			return current == cond.value
		# и т.д.

	return false

func _get_stat_value(entity_id: int, domain: int, stat: int) -> float:
	
	if domain == Stats.Domain.GAME:
		match stat: 
			Stats.GameStats.CURRENT_PHASE: return phase 
			Stats.GameStats.LOG_BALANCE: return run_comp.logs
			Stats.GameStats.CURRENT_FLOOR: 
				return run_comp.current_floor
			_: push_error("Stat for Ability Not declaired")
			
	var comp_name := Stats.get_comp_name(domain, stat)
	if comp_name == "":
		return 0.0	
	var comp = cs.get_component(entity_id, comp_name)
	if comp == null:
		return 0.0

	return comp.final_value
	
	
func _on_phase_changed(data: Dictionary) -> void:
	phase = data.current_phase
	
func _on_day_changed(_data: Dictionary) -> void:
	run_comp = cs.get_component(RUN, "RunComponent")
