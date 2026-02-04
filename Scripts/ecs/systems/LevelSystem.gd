extends BaseSystem
class_name LevelSystem

const START_POINT: float = 45
const MULT: float = 1.09

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store,_event_bus)
	
	arch = cs.register_archetype(["CurrentLevelComponent","CurrentXPComponent",
	"RequiredXPComponent","LevelPointsCountComponent"], 
	["DeadComponent"])
		
func update(_delta: float) -> void:
	

	for e_id in arch.entities:
		var current_level = cs.get_component(e_id, "CurrentLevelComponent")
		var current_xp = cs.get_component(e_id, "CurrentXPComponent")
		var xp_to_next = cs.get_component(e_id, "RequiredXPComponent")
		
		# если компонент только создан — инициализируем требуемый XP
		if xp_to_next.base_value <= 0.01:
			xp_to_next.base_value = get_required_xp(current_level.base_value)
			event_bus.emit("xp_changed", {"e_id":e_id, "xp_to_next": xp_to_next.base_value, "current_xp": current_xp.base_value, "current_level" : current_level.base_value})
		
		# Проверяем ап уровня
		while current_xp.base_value >= xp_to_next.base_value:
			current_xp.base_value -= xp_to_next.base_value
			current_level.base_value += 1
			cs.get_component(e_id, "LevelPointsCountComponent").base_value += 1
			
			# пересчитываем требуемый XP
			xp_to_next.base_value = get_required_xp(current_level.base_value)
			

				
			event_bus.emit("level_up", {"e_id":e_id})
			# cs.add_component(e_id, "LevelUpEvent", LevelUpEvent.new())

			event_bus.emit("xp_changed", {"e_id":e_id, "xp_to_next": xp_to_next.base_value, "current_xp": current_xp.base_value, "current_level" : current_level.base_value})
		

func get_required_xp(level: int) -> float:
	return int(START_POINT * pow(MULT, level))
