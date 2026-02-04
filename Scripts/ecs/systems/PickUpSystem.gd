extends BaseSystem
class_name PickUpSystem

const ACCEL := 10.0
const PICKUP_DIST := 0.5
const HEIGHT_OFFSET := Vector3(0, 1.0, 0)
var player_arch: Archetype
var xp_orb_arch: Archetype
func _init(
	_entity_manager: EntityManager,
	_component_store: ComponentStore,
	_event_bus: EventBus,):
	super._init(_entity_manager, _component_store,_event_bus)
	event_bus.subscribe("combat_completed", _magnetize_all_xp)
	
	player_arch = cs.register_archetype(
		["PlayerComponent", "PickUpRangeComponent","TransformComponent"],
		["DeadComponent"]
	)
	arch = cs.register_archetype(
		["PickUpComponent","TransformComponent","MovementIntentComponent","MoveSpeedComponent"],
		["DeadComponent"]
	)
	
	xp_orb_arch = cs.register_archetype(["XPRewardComponent","PickUpComponent"],["DeadComponent"])
func update(delta: float) -> void:
	var players = player_arch.entities.duplicate()
	var pick_ups = arch.entities.duplicate()
	if players.is_empty() or pick_ups.is_empty():
		return

	for pid in pick_ups:
		var pickup : PickUpComponent = cs.get_component(pid, "PickUpComponent")
		var ptf : TransformComponent = cs.get_component(pid, "TransformComponent")
		var move : MovementIntentComponent = cs.get_component(pid, "MovementIntentComponent")
		var speed: MoveSpeedComponent = cs.get_component(pid, "MoveSpeedComponent")
		if pickup.target_id == -1:
			for player_id in players:
				var tf := cs.get_component(player_id, "TransformComponent")
				var radius :float= cs.get_component(
					player_id,
					"PickUpRangeComponent"
				).final_value

				if ptf.position.distance_to(tf.position) <= radius:
					pickup.target_id = player_id
					speed.base_value = 0.0
					break

			continue


		var target_tf := cs.get_component(pickup.target_id, "TransformComponent")
		if target_tf == null:
			pickup.target_id = -1
			speed.base_value = 0.0
			continue

		var target_pos :Vector3= target_tf.position + HEIGHT_OFFSET
		var dir :Vector3= target_pos - ptf.position 
		var dist :float= dir.length()

		if dist < 0.001:
			continue

		move.direction = dir.normalized()
		speed.final_value += ACCEL * delta
		ptf.velocity.y += move.direction.y * speed.final_value
		
		if dist <= PICKUP_DIST:
			#speed.final_value = 0.0
			cs.add_component(pid, "PickedUpComponent", PickedUpComponent.new())
			
func _magnetize_all_xp(_data) -> void:
	
	for orb in xp_orb_arch.entities:
		var player = player_arch.entities.pick_random()
		cs.get_component(orb,"PickUpComponent").target_id = player
