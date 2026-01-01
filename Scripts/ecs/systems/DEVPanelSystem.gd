extends BaseSystem
class_name DEVPanelSystem

var pool_system: ObjectPool
var _timer := 0.0
const UPDATE_INTERVAL := 1.0


func _init(_entity_manager, _component_store, _pool_system:ObjectPool):
	super._init(_entity_manager, _component_store)
	pool_system = _pool_system


func update(_delta: float) -> void:
	_timer += _delta
	if _timer < UPDATE_INTERVAL:
		return
	_timer = 0.0

	var stats: Dictionary = pool_system.get_debug_stats()

	UIManager.dev_panel.update_pool_stats(stats)
	#var enemies = get_entities_with(["TeamComponent"])
	#UIManager.dev_panel.enemies_count.text ="Enemies: "+ str(enemies.size())
	#var projectiles = get_entities_with(["ProjectileComponent"],["DeadComponent"]) 
	#UIManager.dev_panel.projectiles_count.text = "Projectiles: "+str(projectiles.size())
