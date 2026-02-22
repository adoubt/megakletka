extends BaseSystem
class_name SellSystem


func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	#arch = cs.register_archetype(["CameraComponent","TransformComponent"],["DeadComponent"])
	
	arch = cs.register_archetype(["SellRequestComponent","ItemComponent"],["DeadComponent"])

func update(_delta: float) -> void:
	if arch.entities.is_empty():
		return
	var entities:= arch.entities.duplicate()
	for e in entities:
		process_sell(e)
		## req.source_id not used
		cs.remove_component(e, "SellRequestComponent")

		
	
	
func process_sell(item_id:int) ->void:
	var cost_comp = cs.get_component(item_id, "CostComponent")
	var price = cost_comp.final_value
	var final_price = price 
	var item_comp = cs.get_component(item_id, "ItemComponent")

	var transaction : ItemTransactionComponent = ItemTransactionComponent.new()
	transaction.source_id = item_comp.owner_id
	transaction.target_id = RUN
	cs.add_component(item_id, "ItemTransactionComponent", transaction)
	cs.add_component(RUN,"BalanceChangeRequestComponent", BalanceChangeRequestComponent.new(
		+final_price,"sell_item", item_id))
		
