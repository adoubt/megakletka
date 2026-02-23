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
	JUMPS_USED,
	MOVESPEED,
	MOVESPEED_MULT,
	DURATION_MULT,
	MERCHANT_DISCOUNT,
	PROJ_COUNT,
	WEAPON_RADIUS,
	PROJ_RADIUS,
	ATK_SPEED,
	SLOTS,
	USED_SLOTS,
	UNUSED_LEVEL_POINTS,
	XP_LEFT,
	CURRENT_XP,
	LEVEL,
	XP_GAIN,
	CURRENT_HP_RATIO,
	CURRENT_HP,
	COST
}
enum GameStats{
	LOG_BALANCE,
	CURRENT_FLOOR,
	CURRENT_ANTE,
	ALIVE_PLAYERS,
	DEAD_PLAYES,

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
		PlayerStats.COST:				return "CostComponent"
		PlayerStats.MAX_HP:             return "MaxHPComponent"
		PlayerStats.CURRENT_HP_RATIO:   return "CurrentHPRatioComponent"
		PlayerStats.CURRENT_HP:         return "CurrentHPComponent"
		PlayerStats.JUMPS_COUNT:        return "JumpsCountComponent"
		PlayerStats.JUMPS_LEFT:         return "JumpsLeftComponent"
		PlayerStats.JUMP_HEIGHT:        return "JumpHeightComponent"
		PlayerStats.JUMPS_USED:			return "JumpsUsedComponent"
		PlayerStats.MOVESPEED:          return "MoveSpeedComponent"
		PlayerStats.MOVESPEED_MULT:     return "MoveSpeedMultComponent"

		# --- Time / duration ---
		PlayerStats.DURATION_MULT:      return "DurationComponent"
		PlayerStats.ATK_SPEED:          return "AttackSpeedComponent"

		# --- Economy ---
		PlayerStats.MERCHANT_DISCOUNT:  return "MerchantDiscountComponent"

		# --- Projectiles ---
		PlayerStats.PROJ_COUNT:         return "ProjectileCountComponent"
		PlayerStats.WEAPON_RADIUS:      return "WeaponRadiusComponent"
		PlayerStats.PROJ_RADIUS:        return "ProjectileRadiusComponent"

		# --- Meta / progression ---
		PlayerStats.SLOTS:              return "SlotsCountComponent"
		PlayerStats.USED_SLOTS:         return "UsedSlotsCountComponent"

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
		GameStats.LOG_BALANCE:			return	"LOG_BALANCE"
		GameStats.CURRENT_FLOOR:			return	"CURRENT_FLOOR"
		GameStats.CURRENT_ANTE:			return	"CURRENT_ANTE"
		GameStats.ALIVE_PLAYERS:			return	"ALIVE_PLAYERS"
		GameStats.DEAD_PLAYES:			return "NotDeclaired"
		
		_:
			push_error("Unknown Stat: %s" % stat)
			return ""

static func get_all_player_components() -> Array:
	var result := []
	for stat in PlayerStats.values():
		var comp := get_comp_name(Domain.PLAYER, stat)
		if comp != "":
			result.append(comp)
	return result
enum StatFormatType {
	FLAT,
	PERCENT
}
static func get_format_type(domain:int, stat:int)-> int:
	match domain:
		Domain.PLAYER:
			return _get_player_format_type(stat)
		Domain.GAME:
			return _get_game_format_type(stat)
		_:
			push_error("Unknown stat domain")
			return StatFormatType.FLAT

static func _get_player_format_type(stat:int) -> int:
	match stat:
		PlayerStats.DAMAGE_MULT:        return StatFormatType.PERCENT
		PlayerStats.ARMOR:              return StatFormatType.FLAT
		PlayerStats.CRIT_DAMAGE:        return StatFormatType.FLAT
		PlayerStats.CRIT_CHANCE:        return StatFormatType.FLAT
		PlayerStats.PIERCE:             return StatFormatType.FLAT

		PlayerStats.MAX_HP:             return StatFormatType.FLAT
		PlayerStats.CURRENT_HP_RATIO:   return StatFormatType.FLAT
		PlayerStats.CURRENT_HP:         return StatFormatType.FLAT
		PlayerStats.JUMPS_COUNT:        return StatFormatType.FLAT
		PlayerStats.JUMPS_LEFT:         return StatFormatType.FLAT
		PlayerStats.JUMP_HEIGHT:        return StatFormatType.FLAT
		PlayerStats.JUMPS_USED:			return StatFormatType.FLAT
		PlayerStats.MOVESPEED:          return StatFormatType.FLAT
		PlayerStats.MOVESPEED_MULT:     return StatFormatType.PERCENT
		PlayerStats.COST:				return StatFormatType.FLAT
		# --- Time / duration ---
		PlayerStats.DURATION_MULT:      return StatFormatType.PERCENT
		PlayerStats.ATK_SPEED:          return StatFormatType.FLAT

		# --- Economy ---
		PlayerStats.MERCHANT_DISCOUNT:  return StatFormatType.FLAT

		# --- Projectiles ---
		PlayerStats.PROJ_COUNT:         return StatFormatType.FLAT
		PlayerStats.WEAPON_RADIUS:      return StatFormatType.FLAT
		PlayerStats.PROJ_RADIUS:        return StatFormatType.FLAT

		# --- Meta / progression ---
		PlayerStats.SLOTS:              return StatFormatType.FLAT
		PlayerStats.USED_SLOTS:         return StatFormatType.FLAT

		PlayerStats.XP_LEFT:            return StatFormatType.FLAT
		PlayerStats.CURRENT_XP:         return StatFormatType.FLAT
		PlayerStats.LEVEL:              return StatFormatType.FLAT
		PlayerStats.XP_GAIN:            return StatFormatType.FLAT
		PlayerStats.UNUSED_LEVEL_POINTS:return StatFormatType.FLAT
		
		
		
		_:
			push_error("Unknown Stat: %s" % stat)
			return StatFormatType.FLAT
			
static func _get_game_format_type(stat) -> int:
	match stat:
		GameStats.LOG_BALANCE:			return StatFormatType.FLAT
		GameStats.CURRENT_FLOOR:		return StatFormatType.FLAT
		GameStats.CURRENT_ANTE:			return StatFormatType.FLAT
		GameStats.ALIVE_PLAYERS:		return StatFormatType.FLAT
		GameStats.DEAD_PLAYES:			return StatFormatType.FLAT
		_:
			push_error("Unknown Stat: %s" % stat)
			return StatFormatType.FLAT
				
