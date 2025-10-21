extends CharacterBody3D
class_name PlayerController



var speed
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5

@onready var camera_controller_anchor: Marker3D = $CameraControllerAnchor
@onready var player_camera := $CameraController/Camera3D
#@onready var right_hand: BoneAttachment3D = $rigman/Armature/GeneralSkeleton/RightHandHeld
@onready var right_hand: Node3D = $CameraController/Camera3D/RightHand

@onready var rigman: Node3D = $rigman

@onready var look_at_modifier_3d: LookAtModifier3D = $rigman/Armature/GeneralSkeleton/LookAtModifier3D


var right_hand_held: HeldItem = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var input_enabled: bool = false
@export_group("Mental")
## 0 = трезв, 1 = под кайфом
@export var highness: float = 0.0 

@export_group("Controller")
##if true this player will registred as 1st player
@export var main_player : bool = false

@export_group("Multiplayer")
@export var is_local_player := false

		
func set_input_enabled(state: bool) -> void:
	
	input_enabled = state
	if state:
		set_first_person_mode(true)
	else:
		if UIManager._any_ui_open(): return 
		set_first_person_mode(false)
		
func get_current_camera() -> Camera3D:
	return player_camera

func equip_item(item : InventoryItem):
	if not right_hand:
		push_error("RightHandAttachment не найден!")
		return
		
	# Убираем старый HeldItem
	if right_hand.get_child_count() > 0:
		right_hand.get_child(0).queue_free()

	# Загружаем сцену из пути
	var scene_res: PackedScene = load(item.scene_item_held)
	if not scene_res:
		push_error("Не удалось загрузить сцену: %s" % item.scene_item_held)
		return
	print("scene_res loaded:", scene_res)
	# Создаём новый HeldItem
	var held_item = scene_res.instantiate() as HeldItem
	right_hand.add_child(held_item)
	#held_item.transform = right_hand.global_transform

	# Сохраняем ссылку на предмет в руке
	right_hand_held = held_item
	right_hand_held.loot_data = item
	rigman.right_hand_to_held()


func set_first_person_mode(active: bool):
	
	rigman.visible = not active  # скрываем тело в первом лице
	
	
func _ready() -> void:
	ControllerManager.register(self) 
	if main_player:
		ControllerManager.handle_object_hotkey(name) # где name = "Player"
	

func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return

	if Input.is_action_just_pressed("use_item") and right_hand_held:
		
		right_hand_held.use()

	if Input.is_action_just_pressed("use2_item") and right_hand_held:
		right_hand_held.use2()
		
	if Input.is_action_just_pressed("throw") and right_hand_held:
		right_hand_held.throw()	
		
func _physics_process(delta: float) -> void:
	# --- всегда гравитация ---
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = Vector3.ZERO

	if input_enabled:
		# Handle Sprint.
		if Input.is_action_pressed("sprint") and is_on_floor():
			speed = sprint_speed
		else:
			speed = walk_speed

		# WASD
		if Input.is_action_pressed("move_forward"):
			direction -= transform.basis.z
		if Input.is_action_pressed("move_back"):
			direction += transform.basis.z
		if Input.is_action_pressed("move_left"):
			direction -= transform.basis.x
		if Input.is_action_pressed("move_right"):
			direction += transform.basis.x

		# прыжок
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
	else:
		# --- input выключен → сбрасываем горизонтальную скорость ---
		velocity.x = 0
		velocity.z = 0
	direction.y = 0
	direction = direction.normalized()

	# --- горизонтальное движение только если есть input, иначе оставляем текущую скорость ---
	if input_enabled:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	move_and_slide()

	
func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if body == self: 
		print("сам вошел")
		return
	if body.velocity.length()>0:

		look_at_modifier_3d.target_node = body.get_path()

func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	if body == self: 
		print("сам вышел")
		return

	look_at_modifier_3d.target_node = NodePath("")
	
