class_name BalanceChangeRequestComponent
extends Resource

var amount :int          # + / -
var reason :String       # "buy_item", "reward", "refund"
var source_id :int          # кто инициировал (UI / торговец / моб)

var allow_negative := false
func _init(_amount :int,_reason :String, _source_id :int) -> void:
	amount = _amount
	reason =_reason
	source_id = _source_id
