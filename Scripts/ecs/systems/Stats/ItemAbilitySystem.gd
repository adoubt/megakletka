extends BaseSystem
class_name ItemAbilitySystem

var players := []
var dead_players: =[]
var alive_players: =[]
var combat_state : int = CombatState.INACTIVE
var phase: int = 1

var player_arch : Archetype

var run_comp
func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus) 
	
	event_bus.subscribe("phase_changed", _on_phase_changed)
	event_bus.subscribe("day_changed", _on_day_changed)
	
	arch = cs.register_archetype(["ItemAbilityComponent"])	
	player_arch = cs.register_archetype(
		["PlayerComponent", "TransformComponent"],
		["DeadComponent"]
	)
	
func update(_delta) -> void:
	
	for e in arch.entities:
		var ability = cs.get_component(e, "ItemAbilityComponent")
		var owner_id = ability.owner_id
		
		var cond = cs.get_component(e, "ConditionComponent")
		if cond: 
			if not _check_condition(owner_id, cond):
				continue # абилка не активна
		
		# 2. Базовое значение
		var modifier = cs.get_component(e, "StatModifierComponent")
		
		## 3. Скейлинг (если есть)
		if cs.has_component(e, "ScalingComponent"):
			var scale = cs.get_component(e, "ScalingComponent")
			var source_value = _get_stat_value(e, scale.domain, scale.source)
			modifier.final_value = modifier.base_value * source_value * scale.per
			
			
		for target_entity in _resolve_targets(owner_id):
			_apply_modifier(target_entity, modifier)
		
func _apply_modifier(target_entity: int,modifier: StatModifierComponent) -> void:
	var stat = Stats.get_comp_name(modifier.domain, modifier.stat)
	var value = modifier.final_value
	var target_stat := cs.get_component(target_entity, stat)
	target_stat.final_value += value
	
		

func _check_condition(owner_id: int, cond: ConditionComponent) -> bool:
	
	for target_id in _resolve_targets(owner_id):
		var current := _get_stat_value(target_id, cond.domain, cond.source)

		match cond.type:
			ConditionType.EQUAL:
				if current == cond.value:
					return true

			ConditionType.NOT_EQUAL:
				if current != cond.value:
					return true

			ConditionType.BELOW:
				if current < cond.value:
					return true

			ConditionType.BELOW_OR_EQUAL:
				if current <= cond.value:
					return true

			ConditionType.ABOVE:
				if current > cond.value:
					return true

			ConditionType.ABOVE_OR_EQUAL:
				if current >= cond.value:
					return true

			ConditionType.IN_RANGE:
				if current >= cond.value and current <= cond.value_max:
					return true

			ConditionType.OUT_OF_RANGE:
				if current < cond.value or current > cond.value_max:
					return true

			ConditionType.EXISTS:
				if current > 0:
					return true

			ConditionType.NOT_EXISTS:
				if current <= 0:
					return true

	return false

func _get_stat_value(entity_id: int, domain: int, stat: int) -> float:
	
	if domain == Stats.Domain.GAME:
		match stat: 
			Stats.GameStats.CURRENT_PHASE: return phase 
			Stats.GameStats.LOG_BALANCE: return run_comp.logs
			_: push_error("Stat for Ability Not declaired")
			
	var comp_name := Stats.get_comp_name(domain, stat)
	if comp_name == "":
		return 0.0	
	var comp = cs.get_component(entity_id, comp_name)
	if comp == null:
		return 0.0

	return comp.final_value

func _resolve_targets(item_id:int) -> Array:
	var item_comp = cs.get_component(item_id, "ItemComponent") 
	match item_comp.slot_mask:
		SlotMask.PLAYER:
			return [item_comp.owner_id]

		SlotMask.CAMPFIRE:
			return players

		_:
			return []


func _on_phase_changed(data: Dictionary) -> void:
	phase = data.current_phase
	
func _on_day_changed(data: Dictionary) -> void:
	run_comp = cs.get_component(RUN, "RunComponent")
