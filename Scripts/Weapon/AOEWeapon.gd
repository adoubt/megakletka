extends Weapon
class_name AOEWeapon

var data: AOEWeaponData
var radius : float

func init_from_data(d: AOEWeaponData):
	data = d
	stats = d.base_stats.duplicate(true)
	radius = d.radius
