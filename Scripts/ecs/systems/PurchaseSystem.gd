extends BaseSystem
class_name PurchaseSystem

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["PurchaseRequestComponent","ItemComponent"],["DeadComponent"])

func update(_delta: float) -> void:
	if arch.entities.is_empty():
		return
	var entities:= arch.entities.duplicate()
	for e in entities:
		var req = cs.get_component(e, "PurchaseRequestComponent")
		
		process_purchase(e, req.source_id)
		## req.source_id not used
		cs.remove_component(e, "PurchaseRequestComponent")
	
func process_purchase(item_id, buyer_id):
	
	var empty_slots = cs.get_component(buyer_id, "SlotsCountComponent").base_value - cs.get_component(buyer_id,"UsedSlotsCountComponent").base_value
	if  empty_slots <= 0:
		event_bus.emit("purchase_failed",{ "reason":"NOT_ENOUGH_SLOTS"})
		return

		
	var cost_comp = cs.get_component(item_id, "CostComponent")
	var price = cost_comp.final_value
	var run = cs.get_component(RUN, "RunComponent")
	var final_price = price - cs.get_component(buyer_id, "MerchantDiscountComponent").final_value
	final_price = max(0,final_price)
	if run.logs < final_price:
		event_bus.emit("purchase_failed",{ "reason":"NOT_ENOUGH_BALANCE"})
		return
	
	cost_comp.base_value/=2
	cs.add_component(item_id, "DirtyStatsComponent", DirtyStatsComponent.new())
	var transaction : ItemTransactionComponent = ItemTransactionComponent.new()
	transaction.source_id = cs.get_component(item_id, "ItemComponent").owner_id
	transaction.target_id = buyer_id
	
	cs.add_component(item_id, "ItemTransactionComponent", transaction)
	
	cs.add_component(RUN,"BalanceChangeRequestComponent", BalanceChangeRequestComponent.new(
		-final_price,"purchase_item", transaction.source_id ))
	event_bus.emit("purchased", {"price":price, "item_id":item_id} )
	
