# res://tools/generate_components.gd
@tool
extends EditorScript
#TrailComponent	Создаёт след (огонь, яд, след молнии)
#FireEffectComponent	Добавляет эффект поджигания при контакте
#LightningComponent	Управляет цепными молниями
#OrbitComponent	Объект вращается вокруг владельца
#BounceComponent	Сколько раз может отскочить
#PierceComponent	Сколько целей может пронзить
#SpreadComponent	Разброс пуль при выстреле
#ShieldComponent	Временный щит, блокирующий урон
#ReturnToOwnerComponent	Возвращается к владельцу (банан)
#AuraComponent	Наносит урон в радиусе
#RotationComponent	Визуальное вращение спрайта или коллайдера
#AttachToTargetComponent	Прилипает к врагу
#BeamComponent
func _run():
	var components = [
		"TrailComponent",
		"FireEffectComponent",
		"LightningComponent",
		"OrbitComponent",
		"BounceComponent",
		"PierceComponent",
		"SpreadComponent",
		"ShieldComponent",
		"ReturnToOwnerComponent",
		"AuraComponent",
		"RotationComponent",
		"AttachToTargetComponent",
		"BeamComponent",
		"TransformComponent",
		"VelocityComponent",
		"InputComponent",
		"LifetimeComponent",
		"RenderComponent",
		"AnimationComponent",
		"ColliderComponent",
		"StatsComponent",
		"HealthComponent",
		"DamageComponent",
		"DeadComponent",
		"WeaponComponent",
		"ProjectileComponent",
		"TargetComponent",
		"DamageOverTimeComponent",
		"AIComponent",
		"AggroComponent",
		"SpawnComponent",
		"PatrolComponent",
		"ExplosionComponent",
		"EffectComponent",
		"SoundEventComponent",
		"LootDropComponent",
		"PickupComponent",
		"ExperienceComponent",
		"InventoryComponent",
		"RoomComponent",
		"InteractableComponent",
		"SpawnerMarkerComponent",
		"NetworkComponent",
		"TagComponent",
		"ParentComponent"
	]

	var dir = "res://scripts/ecs/components"
	DirAccess.make_dir_recursive_absolute(dir)

	for name in components:
		var path = "%s/%s.gd" % [dir, name]
		if not FileAccess.file_exists(path):
			var f = FileAccess.open(path, FileAccess.WRITE)
			f.store_string("extends Resource\nclass_name %s\n\n" % name)
			f.store_string("# TODO: Add fields for %s here\n" % name)
			f.close()
			print("✅ Created: ", path)
		else:
			print("⚠️ Already exists:", path)

	print("\n✨ Done! All component files created in ", dir)
