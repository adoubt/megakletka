extends RefCounted
class_name ConditionType

enum {
	EQUAL,              # ==
	NOT_EQUAL,          # !=

	BELOW,              # <
	BELOW_OR_EQUAL,     # <=

	ABOVE,              # >
	ABOVE_OR_EQUAL,     # >=

	IN_RANGE,           # min <= x <= max
	OUT_OF_RANGE,       # x < min || x > max

	EXISTS,             # значение существует / > 0 / true
	NOT_EXISTS,
	ITEM_NEAR          # отсутствует / 0 / false
}

enum Inventory{
	NEAR_SAME_ID
}
