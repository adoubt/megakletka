extends Node
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
	UIManager.event_bus = event_bus
	object_pool = ObjectPool.new(self)
	object_pool.prewarm({
	"res://Scenes/Enemy/Aboba.tscn": 150,
	"res://Scenes/shadow.tscn": 200,
	"res://Scenes/Objects/grave.tscn": 3,
	"res://Scenes/romb.tscn": 20,
	"res://Scenes/Popups/InteractPopup.tscn":2,
	"res://Scenes/Popups/LevelUpPopup.tscn":1,
	"res://Scenes/Popups/DamagePopup.tscn":30,
	"res://Scenes/POI/fortune_teller.tscn":2,
	

})
	grid = SpatialGrid.new()
	
	
	system_manager.add_system(RunInitSystem.new(entity_manager, component_store,database, event_bus))
	system_manager.add_system(CombatSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(SpatialGridSystem.new(entity_manager, component_store, grid))
	
	system_manager.add_system(ControllerSyncSystem.new(entity_manager, component_store))
	system_manager.add_system(EnemySpawnSystem.new(entity_manager, component_store,database, event_bus))
	system_manager.add_system(FactorySystem.new(entity_manager, component_store,database, event_bus))
	system_manager.add_system(StatsRecalculationSystem.new(entity_manager, component_store))
	
	system_manager.add_system(WeaponSystem.new(entity_manager, component_store,event_bus))
	
	system_manager.add_system(MovementSystem.new(entity_manager, component_store))

	system_manager.add_system(DamageSystem.new(entity_manager, component_store))
	system_manager.add_system(DeathSystem.new(entity_manager, component_store))
	system_manager.add_system(CollisionSystem.new(entity_manager, component_store))
	system_manager.add_system(HitSystem.new(entity_manager, component_store))
	
	system_manager.add_system(DamagePopupSystem.new(entity_manager, component_store))
	
	system_manager.add_system(ProjectileSystem.new(entity_manager,component_store))
	
	system_manager.add_system(HealthSystem.new(entity_manager, component_store))
	system_manager.add_system(InteractionProximitySystem.new(entity_manager, component_store))
	system_manager.add_system(InteractionUISystem.new(entity_manager, component_store))
	system_manager.add_system(TargetSystem.new(entity_manager, component_store))
	system_manager.add_system(XPPickUpSystem.new(entity_manager,component_store))
	system_manager.add_system(LevelSystem.new(entity_manager,component_store))
	system_manager.add_system(LevelUpSelectionSystem.new(entity_manager,component_store, event_bus))
	system_manager.add_system(LevelUpOfferSystem.new(entity_manager,component_store,event_bus,database))
	system_manager.add_system(Interactionsystem.new(entity_manager,component_store))
	system_manager.add_system(CleanerSystem.new(entity_manager, component_store, object_pool))
	system_manager.add_system(DEVPanelSystem.new(entity_manager, component_store, object_pool))

	system_manager.add_system(HUDSystem.new(entity_manager, component_store, event_bus))
	system_manager.add_system(FloorActivationSystem.new(entity_manager, component_store, database, event_bus, object_pool))
	system_manager.add_system(RenderSystem.new(entity_manager, component_store, object_pool))
	
	
func update(delta):
	if  UIManager.game_paused:
		return
	system_manager.update_all(delta)
