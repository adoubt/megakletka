extends Entity
class_name Enemy

var data: EnemyData

func init_from_data(d: EnemyData, pos: Vector3):
	data = d
	position = pos
	stats = d.base_stats.duplicate(true)
	weapons = []
	for wd in d.weapons:
		var weapon: Weapon
		if wd is ProjectileWeaponData:
			weapon = ProjectileWeapon.new()
		elif wd is AOEWeaponData:
			weapon = AOEWeapon.new()
		else:
			continue
		weapon.init_from_data(wd)
		weapons.append(weapon)
