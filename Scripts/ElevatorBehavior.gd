extends Node3D
class_name ElevatorBehavior

# --- параметры ---
@export var floor_height: float = 5.0
@export var move_speed: float = 2.0
@export var stop_time: float = 2.0

var current_floor: int = 1
var target_floor: int = 1
var state: String = "idle"
var floors_queue: Array[int] = []
var doors_open: bool = false
@onready var elevator: StaticBody3D = $Elevator
@onready var animation_player: AnimationPlayer = $Elevator/AnimationPlayer

@onready var tween := create_tween()

func _ready():
	state = "idle"

func request_floor(floor: int):
	# добавляем этаж в очередь, если его нет
	if not floors_queue.has(floor):
		floors_queue.append(floor)
	_process_next_floor()

func _process_next_floor():
	if state != "idle" or floors_queue.is_empty():
		return
	
	target_floor = floors_queue.pop_front()
	if target_floor == current_floor:
		return
	
	state = "moving"
	_move_to_floor(target_floor)

func _move_to_floor(floor: int):
	var target_y = (floor - 1) * floor_height
	print("Едем на этаж ", floor)

	tween = create_tween()
	tween.tween_property(elevator, "position:y", target_y, abs(target_y - elevator.position.y) / move_speed)
	tween.connect("finished", _on_reached_floor.bind(floor))

func _on_reached_floor(floor: int):
	current_floor = floor
	print("Прибыли на этаж ", floor)
	state = "door_opening"
	_open_doors()

func _open_doors():
	print("Открываем двери")
	animation_player.play("open_doors")
	
	await get_tree().create_timer(stop_time).timeout
	state = "door_closing"
	_close_doors()

func _close_doors():
	print("Закрываем двери")
	animation_player.play("close_doors")
	await animation_player.animation_finished
	
	state = "idle"
	_process_next_floor()
