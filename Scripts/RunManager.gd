# RunManager.gd
extends Node

@export var total_floors := 10
@export var vertical_offset := Vector3(0, 0.05, 0) # Офсет для спавна объектов в лифте
@onready var dungeon_generator := $"../BaseLevelFloor"

var run_seed: int
var floor_seeds: Array[int] = []
var current_floor := 0
var pending_contents: Array = []


func _ready():
	dungeon_generator.done_generating.connect(_on_floor_generated)
	start_new_run()


# =====================================================
#  ИНИЦИАЛИЗАЦИЯ И ЗАГРУЗКА ЭТАЖЕЙ
# =====================================================

func start_new_run():
	run_seed = randi()
	var rng = RandomNumberGenerator.new()
	rng.seed = run_seed

	floor_seeds.clear()
	for i in range(total_floors):
		floor_seeds.append(rng.randi())

	print("Run seed:", run_seed)
	print("Floor seeds:", floor_seeds)

	load_floor(0)


func load_floor(index: int):
	if index < 0 or index >= total_floors:
		return
	current_floor = index
	print("Loading floor", index, "with seed", floor_seeds[index])
	dungeon_generator.call_deferred("generate", floor_seeds[index])



func load_next_floor():
	if current_floor < total_floors - 1:
		_save_elevator_contents()
		load_floor(current_floor + 1)


func load_prev_floor():
	if current_floor > 0:
		_save_elevator_contents()
		load_floor(current_floor - 1)


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dev_floor_up"):
		load_next_floor()
	elif Input.is_action_just_pressed("dev_floor_down"):
		load_prev_floor()


# =====================================================
#  СКАН И СОХРАНЕНИЕ ОБЪЕКТОВ В ЛИФТЕ
# =====================================================

func get_elevator_scan() -> Area3D:
	var rooms_container = $"../BaseLevelFloor/RoomsContainer"
	if not is_instance_valid(rooms_container):
		return null

	for room in rooms_container.get_children():
		if "ElevatorRoom" in room.name:
			return room.get_node_or_null("Elevator/Scan")

	return null


func get_contents() -> Array:
	var scan_area = get_elevator_scan()
	if not scan_area:
		return []
	return scan_area.get_overlapping_bodies()


func _save_elevator_contents():
	var scan = get_elevator_scan()
	if not scan:
		return

	pending_contents.clear()

	var elevator_basis = scan.global_transform.basis

	for obj in get_contents():
		if not obj:
			continue

		# Сохраняем позицию и ориентацию относительно лифта
		var rel_pos = elevator_basis.inverse() * (obj.global_position - scan.global_position)
		var rel_basis = elevator_basis.inverse() * obj.global_transform.basis

		pending_contents.append({
			"object": obj,
			"offset": rel_pos,
			"rotation": rel_basis
		})

	print("Saved contents:", pending_contents.size())

# =====================================================
#  ВОССТАНОВЛЕНИЕ ОБЪЕКТОВ
# =====================================================

func _on_floor_generated():
	_restore_elevator_contents()


func _restore_elevator_contents():
	
	if pending_contents.is_empty():
		return
	await get_tree().process_frame
	var scan = get_elevator_scan()
	
	if not scan:
		push_error("No elevator scan found on new floor!")
		return

	var elevator_basis = scan.global_transform.basis

	for data in pending_contents:
		var obj = data["object"]
		if not is_instance_valid(obj):
			continue

		var offset = data["offset"]
		var rotation = data["rotation"]

		# переносим позицию и поворот сначала
		obj.global_position = scan.global_position + (elevator_basis * offset) + vertical_offset
		obj.global_transform.basis = elevator_basis * rotation

		# если это активный игрок — синхронизируем угол камеры ПОСЛЕ поворота
		if ControllerManager.is_active(obj) and obj.name.begins_with("Player"):
			var cam = obj.get_node("CameraController")
			var new_y = obj.global_transform.basis.get_euler().y
			print("📸 Sync camera: old_y =", cam.input_rotation.y, "→ new_y =", new_y)
			cam.input_rotation.y = new_y

	pending_contents.clear()
	print("Contents restored to new floor.")
