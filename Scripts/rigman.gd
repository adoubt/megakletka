extends Node3D
@onready var l_apper_arm: LookAtModifier3D = $Armature/GeneralSkeleton/l_apper_arm
@onready var l_lower_arm: LookAtModifier3D = $Armature/GeneralSkeleton/l_lower_arm
@onready var l_hand: LookAtModifier3D = $Armature/GeneralSkeleton/l_hand
@onready var r_apper_arm: LookAtModifier3D = $Armature/GeneralSkeleton/r_apper_arm
@onready var r_lower_arm: LookAtModifier3D = $Armature/GeneralSkeleton/r_lower_arm
@onready var r_hand: LookAtModifier3D = $Armature/GeneralSkeleton/r_hand

@onready var l_apper_arm_target: Node3D = $LeftArmTarget/ApperArmTarget
@onready var l_lower_arm_target: Node3D = $LeftArmTarget/LowerArmTarget
@onready var l_hand_target: Node3D = $LeftArmTarget/HandTarget
@onready var r_apper_arm_target: Node3D = $RightArmTarget/ApperArmTarget
@onready var r_lower_arm_target: Node3D = $RightArmTarget/LowerArmTarget
@onready var r_hand_target: Node3D = $RightArmTarget/HandTarget

func _ready() -> void:
	left_hand_to_idle()
	right_hand_to_idle()
	
func left_hand_to_held():
	l_apper_arm.target_node = l_apper_arm_target.get_path()
	l_lower_arm.target_node = l_lower_arm_target.get_path()
	l_hand.target_node = l_hand_target.get_path()

func right_hand_to_held():
	r_apper_arm.target_node = r_apper_arm_target.get_path()
	r_lower_arm.target_node = r_lower_arm_target.get_path()
	r_hand.target_node = r_hand_target.get_path()

func left_hand_to_idle():
	l_apper_arm.target_node = NodePath("")
	l_lower_arm.target_node = NodePath("")
	l_hand.target_node = NodePath("")

func right_hand_to_idle():
	r_apper_arm.target_node = NodePath("")
	r_lower_arm.target_node = NodePath("")
	r_hand.target_node = NodePath("")
