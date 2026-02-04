extends RefCounted
class_name AbilityTriggers

enum Events {
	MUSHROOM_EATED,
	JUMPED,
	ALLY_JUMPED,
	GROUNDED,
	DAMAGE_RECIVED,
}

enum Actions {
	ADD_JUMP,
	JUMPED,
	GROUNDED,
	GAIN_VALUE, 
	SET_VALUE,
}


static func event_to_string(e: int) -> String:
	match e:
		AbilityTriggers.Events.MUSHROOM_EATED: return "MUSHROOM_EATED"
		AbilityTriggers.Events.JUMPED: return "JUMPED"
		AbilityTriggers.Events.ALLY_JUMPED: return "ALLY_JUMPED"
		AbilityTriggers.Events.GROUNDED: return "GROUNDED"
		AbilityTriggers.Events.DAMAGE_RECIVED: return "DAMAGE_RECIVED"
		_: return ""
		
static func string_to_event(s: String) -> int:
	match s:
		"MUSHROOM_EATED": return AbilityTriggers.Events.MUSHROOM_EATED
		"JUMPED": return AbilityTriggers.Events.JUMPED
		"ALLY_JUMPED": return AbilityTriggers.Events.ALLY_JUMPED
		"GROUNDED": return AbilityTriggers.Events.GROUNDED
		"DAMAGE_RECIVED": return AbilityTriggers.Events.DAMAGE_RECIVED
		_: return -1
