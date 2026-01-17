extends BaseSystem
class_name ConsoleSystem

var db : DataBase

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus, _db: DataBase ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	db = _db
	event_bus.subscribe("console_input", _on_console_input)
		
func _on_console_input(data: Dictionary) -> void:
	var input_text = data["input"] 
	event_bus.emit(input_text, {"console": true})
