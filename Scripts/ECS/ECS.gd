extends Node
class_name ECS

@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var movement_system: MovementSystem = $MovementSystem
@onready var combat_system: CombatSystem = $CombatSystem
@onready var spawn_system: SpawnSystem = $SpawnSystem
@onready var render_system: RenderSystem = $RenderSystem
@onready var weapon_system: WeaponSystem = $WeaponSystem




@export var player_path: NodePath
@onready var player_node: Node3D = get_node(player_path)

var player_entity: Entity

func _ready():
	player_entity = Entity.new()
	player_entity.position = player_node.global_position
	player_entity.stats = StatsComponent.new()
	player_entity.alive = true
	player_entity.stats.attack_speed = 1.0
	player_entity.weapons = []
	player_entity.stats.size = 5.0
	player_entity.stats.damage = 1.0
	


func _physics_process(delta):
	spawn_system.update(delta, enemy_manager, player_entity)
	movement_system.update(player_entity, enemy_manager.enemies, delta)
	weapon_system.update(player_entity, enemy_manager.enemies, enemy_manager.enemy_nodes, delta)
	combat_system.update(player_entity, enemy_manager.enemies, delta)
	render_system.update(player_entity, player_node, enemy_manager.enemies, enemy_manager.enemy_nodes,delta)
	enemy_manager.update(delta)


	
