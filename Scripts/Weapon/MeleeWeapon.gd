extends Weapon
class_name MeleeWeapon

var data: MeleeWeaponData

func init_from_data(d: MeleeWeaponData):
	data = d
	stats = d.base_stats.duplicate(true)
	
