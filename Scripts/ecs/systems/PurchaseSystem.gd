extends BaseSystem
class_name PurchaseSystem

var item_arch : Archetype
func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	#arch = cs.register_archetype(["CameraComponent","TransformComponent"],["DeadComponent"])
	event_bus.subscribe("purchase_request", _on_purchase_request)
	item_arch = cs.register_archetype(["ItemComponent","RenderComponent"],["DeadComponent"])
func _on_purchase_request(data: Dictionary)-> void:
	#var buyer_entity :int
	#var merchant_entity :int
	#var offer_id :int
	process_purchase(data)
	
func process_purchase(data):
	var requested_instance: Node3D = data.item_instance
	var requested_entity: int =-1
	var merchant_entity = -1
	var buyer: int = data.owner_id
	if cs.get_component(buyer,"EmptySlotsCountComponent").base_value <= 0:
		event_bus.emit("purchase_failed",{ "reason":"NOT_ENOUGH_SLOTS"})
		return
	
	for e in item_arch.entities:
		var item = cs.get_component(e,"ItemComponent")
		if (item.slot_mask & SlotMask.MERCHANT) == SlotMask.MERCHANT:
			var render = cs.get_component(e,"RenderComponent")
			if not render or not render.instance: continue
			if render.instance == requested_instance:
				requested_entity = e
				merchant_entity = item.owner_id
				break
	if requested_entity ==-1 or merchant_entity == -1:
		return
		
	var cost_comp = cs.get_component(requested_entity, "CostComponent")
	var price = cost_comp.base_value
	var run = cs.get_component(RUN, "RunComponent")
	
	if run.logs < price:
		event_bus.emit("purchase_failed",{ "reason":"NOT_ENOUGH_BALANCE"})
		return
	#var item_name: String = "LogFueledDamage"
	## 1. создаём предмет
	#event_bus.emit("create_item", [
		#{"owner_id": data.owner_id,"item_name": item_name}
		#])

	var transaction : ItemTransactionComponent = ItemTransactionComponent.new()
	transaction.source_id = merchant_entity
	transaction.target_id = buyer
	
	cs.add_component(requested_entity, "ItemTransactionComponent", transaction)
	
	cs.add_component(RUN,"BalanceChangeRequestComponent", BalanceChangeRequestComponent.new(
		-price,"purchase_item", merchant_entity))

	
