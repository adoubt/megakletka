#Autoload
extends Node3D
class_name ECS

var entity_manager: EntityManager 
var component_store: ComponentStore 
var system_manager: SystemManager 
var object_pool : ObjectPool

func initialize():
	name = "ECS"
	entity_manager = EntityManager.new()
	component_store = ComponentStore.new()
	system_manager = SystemManager.new()
	object_pool = ObjectPool.new(self)
	system_manager.add_system(ControllerSyncSystem.new(entity_manager, component_store))
	system_manager.add_system(TargetSystem.new(entity_manager, component_store))
	system_manager.add_system(MovementSystem.new(entity_manager, component_store, self))
	system_manager.add_system(WeaponSystem.new(entity_manager, component_store))
	system_manager.add_system(ProjectileSystem.new(entity_manager,component_store))
	system_manager.add_system(CollisionSystem.new(entity_manager, component_store))
	
	system_manager.add_system(DeathSystem.new(entity_manager, component_store))
	system_manager.add_system(DamageSystem.new(entity_manager, component_store))
	system_manager.add_system(HealthSystem.new(entity_manager, component_store))
	
	system_manager.add_system(SpawnSystem.new(entity_manager, component_store))
	system_manager.add_system(RenderSystem.new(entity_manager, component_store, object_pool))
	system_manager.add_system(CleanerSystem.new(entity_manager, component_store, object_pool))
	
	
	
func update(delta):
	system_manager.update_all(delta)
