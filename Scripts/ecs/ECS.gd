#Autoload
extends Node3D
class_name ECS

var entity_manager: EntityManager 
var component_store: ComponentStore 
var system_manager: SystemManager 
var object_pool : ObjectPool
var grid : SpatialGrid
var event_bus: EventBus
var database: DataBase

func initialize():
	name = "ECS"
	database = DataBase.new()
	UIManager.hud.db = database
	entity_manager = EntityManager.new()
	component_store = ComponentStore.new()
	system_manager = SystemManager.new()
	event_bus = EventBus.new()
	UIManager.hud.event_bus = event_bus
	object_pool = ObjectPool.new(self)
	object_pool.prewarm({
	"res://Scenes/Enemy/Aboba.tscn": 1000,
	"res://scenes/enemies/fuflan.tscn": 500,
	
	
	
})
	grid = SpatialGrid.new()
	
	
	##Вход
	system_manager.add_system(SpatialGridSystem.new(entity_manager, component_store, grid))
	
	system_manager.add_system(ControllerSyncSystem.new(entity_manager, component_store))
	var spawn_system: SpawnSystem = SpawnSystem.new(entity_manager, component_store,database)
	system_manager.add_system(spawn_system)
	system_manager.add_system(TargetSystem.new(entity_manager, component_store))
	system_manager.add_system(WeaponSystem.new(entity_manager, component_store))
	
	system_manager.add_system(MovementSystem.new(entity_manager, component_store))
	system_manager.add_system(DamageSystem.new(entity_manager, component_store))
	system_manager.add_system(CollisionSystem.new(entity_manager, component_store))
	system_manager.add_system(HitSystem.new(entity_manager, component_store))
	
	system_manager.add_system(DamagePopupSystem.new(entity_manager, component_store))
	system_manager.add_system(LevelUpPopUpSystem.new(entity_manager, component_store))
	system_manager.add_system(ProjectileSystem.new(entity_manager,component_store))
	
	system_manager.add_system(HealthSystem.new(entity_manager, component_store))
	system_manager.add_system(DeathSystem.new(entity_manager, component_store))
	system_manager.add_system(XPPickUpSystem.new(entity_manager,component_store))
	system_manager.add_system(LevelSystem.new(entity_manager,component_store))
	system_manager.add_system(LevelUpOfferSystem.new(entity_manager,component_store,event_bus,database))
	system_manager.add_system(LevelUpSelectionSystem.new(entity_manager,component_store,spawn_system))
	system_manager.add_system(CleanerSystem.new(entity_manager, component_store, object_pool))
	
	
	system_manager.add_system(HUDSystem.new(entity_manager, component_store))
	system_manager.add_system(RenderSystem.new(entity_manager, component_store, object_pool))
	
	
func update(delta):
	if  UIManager.game_paused:
		return
	system_manager.update_all(delta)
