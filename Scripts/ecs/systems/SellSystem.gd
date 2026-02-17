extends BaseSystem
class_name SellSystem

var item_arch : Archetype
func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	#arch = cs.register_archetype(["CameraComponent","TransformComponent"],["DeadComponent"])
	event_bus.subscribe("sell_request", _on_sell_request)
	item_arch = cs.register_archetype(["ItemComponent","RenderComponent"],["DeadComponent"])
func _on_sell_request(data: Dictionary)-> void:
	#var buyer_entity :int
	#var merchant_entity :int
	#var offer_id :int
	process_sell(data)
	
func process_sell(data):
	var requested_instance: Node3D = data.item_instance
	var requested_entity: int =-1
	
	var owner_id: int = data.owner_id
	
	
	for e in item_arch.entities:
		var item = cs.get_component(e,"ItemComponent")
		var allowed = SlotMask.PLAYER | SlotMask.CAMPFIRE
		if (item.slot_mask & allowed) != 0:
			var render = cs.get_component(e,"RenderComponent")
			if not render or not render.instance: continue
			if render.instance == requested_instance:
				requested_entity = e
				
				break
	if requested_entity ==-1:
		return
		
	var cost_comp = cs.get_component(requested_entity, "CostComponent")
	var price = cost_comp.base_value
	var final_price = price 
	

	var transaction : ItemTransactionComponent = ItemTransactionComponent.new()
	transaction.source_id = owner_id
	transaction.target_id = RUN
	cs.add_component(requested_entity, "ItemTransactionComponent", transaction)
	cs.add_component(RUN,"BalanceChangeRequestComponent", BalanceChangeRequestComponent.new(
		+final_price,"sell_item", requested_entity))
	cs.add_component(requested_entity, "DeadComponent", DeadComponent.new())
	
