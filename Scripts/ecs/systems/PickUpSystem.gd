extends BaseSystem
class_name PickUpSystem

const ACCEL := 10.0
const PICKUP_DIST := 0.45
const HEIGHT_OFFSET := Vector3(0, 1.3, 0)

func _init(
	_entity_manager: EntityManager,
	_component_store: ComponentStore,
	_event_bus: EventBus,):
	super._init(_entity_manager, _component_store,_event_bus)
	event_bus.subscribe("combat_finished", _magnetize_all_xp)
	
func update(delta: float) -> void:
	var players = get_entities_with(
		["PlayerComponent", "PickUpRangeComponent"],
		["DeadComponent"]
	)
	var pickups = get_entities_with(
		["PickUpComponent", "MovementComponent"],
		["DeadComponent"]
	)

	if players.is_empty() or pickups.is_empty():
		return

	for pid in pickups:
		var pickup : PickUpComponent = cs.get_component(pid, "PickUpComponent")
		var ptf : TransformComponent = cs.get_component(pid, "TransformComponent")
		var move : MovementComponent = cs.get_component(pid, "MovementComponent")

		if pickup.target_id == -1:
			for player_id in players:
				var tf := cs.get_component(player_id, "TransformComponent")
				var radius :float= cs.get_component(
					player_id,
					"PickUpRangeComponent"
				).final_value

				if ptf.position.distance_to(tf.position) <= radius:
					pickup.target_id = player_id
					move.speed = 0.0
					break

			continue


		var target_tf := cs.get_component(pickup.target_id, "TransformComponent")
		if target_tf == null:
			pickup.target_id = -1
			move.speed = 0.0
			continue

		var target_pos :Vector3= target_tf.position + HEIGHT_OFFSET
		var dir :Vector3= target_pos - ptf.position
		var dist :float= dir.length()

		if dist < 0.001:
			continue

		move.direction = dir.normalized()
		move.speed += ACCEL * delta

		if dist <= PICKUP_DIST:
			move.speed = 0.0
			cs.add_component(pid, "PickedUpComponent", PickedUpComponent.new())
			
func _magnetize_all_xp(data) -> void:
	var xp_orbs = get_entities_with(["XPRewardComponent","PickUpComponent"],["DeadComponent"])
	for orb in xp_orbs:
		var player = get_entities_with(["PlayerComponent"]).pick_random()
		cs.get_component(orb,"PickUpComponent").target_id = player
