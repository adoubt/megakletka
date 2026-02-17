extends BaseSystem
class_name ItemVisualPlacementSystem


func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)

	arch = cs.register_archetype(["ItemPlacementRequestComponent","ItemComponent"])
	
func update(_delta:float)-> void:
	var entities = arch.entities.duplicate()
	for e in entities:
		var item_comp = cs.get_component(e,"ItemComponent")
		
		var slot_mask = item_comp.slot_mask
		var owner_id = item_comp.owner_id
		var owner_pos = cs.get_component(owner_id, "TransformComponent").position
		var slots_count : int = cs.get_component(owner_id, "SlotsCountComponent").base_value
		var slot_index :int = item_comp.slot_index
		
		var offset: Vector3 
		var weight: float 
		match slot_mask:
			SlotMask.PLAYER:
				offset = _get_hat_offset(slot_index, slots_count)
				weight = 0.7
			SlotMask.CAMPFIRE:
				offset = _get_hat_offset(slot_index, slots_count, 0.2, 1.4)
				weight = 0.3
			SlotMask.MERCHANT:
				offset = _get_merchant_offset(slot_index, slots_count,owner_pos,Vector3.ZERO)
				weight = 0.02
		var follow: FollowOwnerComponent= cs.get_component(e, "FollowOwnerComponent")
		if not follow :
			cs.add_component(e, "FollowOwnerComponent", FollowOwnerComponent.new(owner_id,offset,weight))
		else:
			follow.offset = offset
			follow.weight = weight
			follow.owner_id = owner_id
		cs.remove_component(e, "ItemPlacementRequestComponent")

func _get_merchant_offset(
	slot_index: int,
	slots_count: int,
	poi_pos: Vector3,
	target_pos: Vector3,
	height: float = 1.0,
	radius: float = 0.30,
	arc_angle_deg: float = 180.0
) -> Vector3:

	if slots_count <= 1:
		return Vector3(0, height, 0)

	# направление «вперёд» (к игроку / камере)
	var forward := -(target_pos - poi_pos).normalized()
	forward.y = 0
	forward = forward.normalized()

	# ось вправо
	var right := forward.cross(Vector3.UP).normalized()

	# дуга от -half_angle до +half_angle
	var half_angle :float= deg_to_rad(arc_angle_deg * 0.9)
	var t := float(slot_index) / float(slots_count - 1)
	var angle :float= lerp(-half_angle, half_angle, t)

	# смещение по дуге
	var offset := forward * cos(angle) * radius + right   * sin(angle) * radius

	offset.y = height
	return offset


func _get_hat_offset(
	slot_index: int,
	slots_count: int,
	height: float = 0.7,
	radius: float = 0.3
) -> Vector3:

	if slots_count <= 1:
		return Vector3(0.0, height, 0.0)

	var angle := TAU * float(slot_index) / float(slots_count)

	var x := cos(angle) * radius
	var z := sin(angle) * radius

	return Vector3(x, height, z)
