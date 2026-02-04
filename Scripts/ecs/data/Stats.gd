extends RefCounted
class_name Stats

enum PlayerStats{
	DAMAGE_MULT,
	ARMOR,
	MAX_HP,
	CRIT_DAMAGE,
	PIERCE,
	CRIT_CHANCE,
	JUMPS_COUNT,
	JUMP_HEIGHT,
	JUMPS_LEFT,
	MOVESPEED,
	MOVESPEED_MULT,
	DURATION_MULT,
	MERCHANT_DISCOUNT,
	PROJ_COUND,
	WEAPON_RADIUS,
	PROJ_RADIUS,
	ATK_SPEED,
	SLOTS,
	UNUSED_LEVEL_POINTS,
	XP_LEFT,
	CURRENT_XP,
	LEVEL,
	XP_GAIN,
	CURRENT_HP_RATIO
}
enum GameStats{
	LOG_BALANCE,
	CURRENT_DAY,
	CURRENT_ANTE,
	SKIPPED_DAYS,
	PLAYERS,
	ALIVE_PLAYERS,
	DEAD_PLAYES,
	
	CURRENT_PHASE,
	XP_REWARD,
}

enum Domain {
	PLAYER,
	GAME
}
static func get_comp_name(domain: int, stat: int) -> String:
	match domain:
		Domain.PLAYER:
			return _get_player_comp(stat)
		Domain.GAME:
			return _get_game_comp(stat)
		_:
			push_error("Unknown stat domain")
			return ""

static func _get_player_comp(stat: int) -> String:
	match stat:
		PlayerStats.DAMAGE_MULT:        return "DamageMultComponent"
		PlayerStats.ARMOR:              return "ArmorComponent"
		PlayerStats.CRIT_DAMAGE:        return "CritDamageComponent"
		PlayerStats.CRIT_CHANCE:        return "CritChanceComponent"
		PlayerStats.PIERCE:             return "PierceComponent"

		PlayerStats.MAX_HP:             return "MaxHPComponent"
		PlayerStats.CURRENT_HP_RATIO:   return "CurrentHPRatioComponent"

		PlayerStats.JUMPS_COUNT:        return "JumpsCountComponent"
		PlayerStats.JUMPS_LEFT:         return "JumpsLeftComponent"
		PlayerStats.JUMP_HEIGHT:        return "JumpHeightComponent"
		
		PlayerStats.MOVESPEED:          return "MoveSpeedComponent"
		PlayerStats.MOVESPEED_MULT:     return "MoveSpeedMultComponent"

		# --- Time / duration ---
		PlayerStats.DURATION_MULT:      return "DurationComponent"
		PlayerStats.ATK_SPEED:          return "AttackSpeedComponent"

		# --- Economy ---
		PlayerStats.MERCHANT_DISCOUNT:  return "MerchantDiscountComponent"

		# --- Projectiles ---
		PlayerStats.PROJ_COUND:         return "ProjectileCountComponent"
		PlayerStats.WEAPON_RADIUS:      return "WeaponRadiusComponent"
		PlayerStats.PROJ_RADIUS:        return "ProjectileRadiusComponent"

		# --- Meta / progression ---
		PlayerStats.SLOTS:              return "SlotsCountComponent"
	

		PlayerStats.XP_LEFT:            return "RequiredXPComponent"
		PlayerStats.CURRENT_XP:         return "CurrentXPComponent"
		PlayerStats.LEVEL:              return "CurrentLevelComponent"
		PlayerStats.XP_GAIN:            return "XPGainComponent"
		PlayerStats.UNUSED_LEVEL_POINTS:return "LevelPointsCountComponent"
		
		
		
		_:
			push_error("Unknown Stat: %s" % stat)
			return ""
static func _get_game_comp(stat: int) -> String:
	match stat:
		GameStats.XP_REWARD: 			return "XPRewardComponent"
		GameStats.CURRENT_PHASE:			return "NotDeclaired"
		_:
			push_error("Unknown Stat: %s" % stat)
			return ""
