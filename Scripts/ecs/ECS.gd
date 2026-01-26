extends Node
class_name ECS

var entity_manager: EntityManager 
var component_store: ComponentStore 
var system_manager: SystemManager 
var object_pool : ObjectPool
var grid : SpatialGrid
var event_bus: EventBus
var db: DataBase
var debug_collision :bool = true

var pool_handler: Node
var groound_handler: Node3D

func initialize():
	name = "ECS"
	pool_handler = Node.new()
	pool_handler.name = "PoolHandler"
	add_child(pool_handler)
	
	groound_handler = Node3D.new()
	groound_handler.name = "GroundHandler"
	add_child(groound_handler)
	db = DatabaseManager.db
	
	
	entity_manager = EntityManager.new()
	component_store = ComponentStore.new()
	system_manager = SystemManager.new()
	
	event_bus = EventBus.new()
	UIManager.event_bus = event_bus
	
	

	
	
	object_pool = ObjectPool.new(pool_handler)
	object_pool.prewarm({
	db.enemy_configs.get("Aboba").scene: 100,
	"res://Scenes/shadow.tscn": 300,
	"res://Scenes/Objects/grave.tscn": 3,
	"res://Scenes/romb.tscn": 40,
	"res://Scenes/Popups/InteractPopup.tscn":2,
	"res://Scenes/Popups/LevelUpPopup.tscn":2,
	"res://Scenes/Popups/DamagePopup.tscn":50,
	"res://Scenes/POI/fortune_teller.tscn":3,
	"res://Scenes/debug_collider.tscn":200 if debug_collision else 0,
	"res://Scenes/Weapons/Projectiles/enemy_proj.tscn" : 150,
	"res://Scenes/Weapons/Projectiles/carrot.tscn": 30,
	"res://Scenes/player_camera.tscn" :1,
	db.vfx_configs.get("base_hit").scene: 50,
	

})
	grid = SpatialGrid.new()
	
	#1 INIT / SPAWN
	system_manager.add_system(RunInitSystem.new(entity_manager, component_store,event_bus, db))
	system_manager.add_system(GroundGenerationSystem.new(entity_manager, component_store,event_bus,groound_handler))
	system_manager.add_system(InputSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(JumpSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(CameraSystem.new(entity_manager,component_store,event_bus))
	system_manager.add_system(PlayerControlSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(ConsoleSystem.new(entity_manager, component_store,event_bus, db))
	
	system_manager.add_system(CombatSystem.new(entity_manager, component_store,event_bus))
	#system_manager.add_system(SpatialGridSystem.new(entity_manager, component_store, grid))
	#system_manager.add_system(ControllerSyncSystem.new(entity_manager, component_store,event_bus))
	#system_manager.add_system(CameraSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(EnemySpawnSystem.new(entity_manager, component_store,event_bus, db))
	system_manager.add_system(FactorySystem.new(entity_manager, component_store,event_bus,db,object_pool))
	system_manager.add_system(StatsRecalculationSystem.new(entity_manager, component_store,event_bus))
	
	#2 AI / DECISION
	system_manager.add_system(EnemyChaseSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(WeaponSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(AimSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(TargetSystem.new(entity_manager, component_store,event_bus))
	
	system_manager.add_system(FireSystem.new(entity_manager, component_store,event_bus))
	
	#system_manager.add_system(MovementIntentSystem.new(entity_manager, component_store,event_bus))
	
	#3. PROJECTILES LOGIC
	system_manager.add_system(ProjectileSystem.new(entity_manager,component_store,event_bus))
	system_manager.add_system(PierceSystem.new(entity_manager,component_store, event_bus))
	
	#4. PHYSICS / MOVEMENT
	system_manager.add_system(PickUpSystem.new(entity_manager,component_store, event_bus))
	system_manager.add_system(ClimbSystem.new(entity_manager,component_store, event_bus))
	system_manager.add_system(MovementSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(GravitySystem.new(entity_manager,component_store, event_bus))
	
	system_manager.add_system(PhysicsIntegrationSystem.new(entity_manager, component_store,event_bus))
	#system_manager.add_system(PhysicsSystem.new(entity_manager, component_store,event_bus))
	
	#5. COLLISION / DAMAGE
	system_manager.add_system(PickUpSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(CollisionSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(HitSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(DamageSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(DeathSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(HealthSystem.new(entity_manager, component_store,event_bus))
	
	#6. UI / META
	system_manager.add_system(DamagePopupSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(HitVFXSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(InteractionProximitySystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(InteractionUISystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(XPPickUpSystem.new(entity_manager,component_store,event_bus))
	system_manager.add_system(LevelSystem.new(entity_manager,component_store,event_bus))
	system_manager.add_system(LevelUpSelectionSystem.new(entity_manager,component_store,event_bus,))
	#7. RENDER
	system_manager.add_system(CameraEffectSystem.new(entity_manager,component_store,event_bus,))
	
	system_manager.add_system(LevelUpOfferSystem.new(entity_manager,component_store,event_bus,db))
	system_manager.add_system(Interactionsystem.new(entity_manager,component_store,event_bus))

	system_manager.add_system(DEVPanelSystem.new(entity_manager, component_store,event_bus, object_pool))
	
	system_manager.add_system(HUDSystem.new(entity_manager, component_store,event_bus,))
	system_manager.add_system(DayActivationSystem.new(entity_manager, component_store,event_bus, db, object_pool))
	system_manager.add_system(RenderSystem.new(entity_manager, component_store,event_bus, object_pool))
	system_manager.add_system(AudioSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(HitFlashSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(LifeTimeSystem.new(entity_manager, component_store,event_bus))
	system_manager.add_system(CleanerSystem.new(entity_manager, component_store,event_bus, object_pool))
	if debug_collision: system_manager.add_system(DEBUGCollisionSystem.new(entity_manager, component_store,event_bus, object_pool)) 
	
func update(delta):
	if  UIManager.game_paused:
		return
	
	system_manager.update_all(delta)

			
