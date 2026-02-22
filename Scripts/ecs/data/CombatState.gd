# CombatState.gd
extends Object
class_name CombatState

enum {
	INACTIVE,
	ACTIVE,
	COMPLETED,
	SKIPPED
}

enum WinCondition {
	TIME = 1 << 0,
	KILL_ALL = 1 << 1
}
