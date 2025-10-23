#Autoload
extends Node
class_name ECS

var entity_manager: EntityManager 
var component_store: ComponentStore 
var system_manager: SystemManager 

func _init():
	entity_manager = EntityManager.new()
	component_store = ComponentStore.new()
	system_manager = SystemManager.new()

	system_manager.add_system(MovementSystem.new(entity_manager, component_store))
	system_manager.add_system(DamageSystem.new(entity_manager, component_store))
	system_manager.add_system(DeathSystem.new(entity_manager, component_store))
	system_manager.add_system(HealthSystem.new(entity_manager, component_store))
	system_manager.add_system(ProjectileSystem.new(entity_manager, component_store))
	system_manager.add_system(SpawnSystem.new(entity_manager, component_store))
	system_manager.add_system(WeaponSystem.new(entity_manager, component_store))
	#system_manager.add_system(.new(entity_manager, component_store))
	#system_manager.add_system(.new(entity_manager, component_store))
	#system_manager.add_system(.new(entity_manager, component_store))

func update(delta):
	system_manager.update_all(delta)
