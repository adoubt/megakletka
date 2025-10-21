extends Weapon
class_name ProjectileWeapon

var data: ProjectileWeaponData
var projectile_speed: float = 5.0
var projectile_amount: int = 1
var projectile_range : float = 5.0
var projectile_bounces : int = 0

func init_from_data(d: ProjectileWeaponData):
	data = d
	stats = d.base_stats.duplicate(true)
	
