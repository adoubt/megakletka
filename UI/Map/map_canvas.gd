extends Control

var connections: Array = [] # [{from: Control, to: Control}]

func _draw() -> void:
	for c in connections:
		var from_node: Control = c.from
		var to_node: Control = c.to

		var a: Vector2 = (
			from_node.global_position
			+ from_node.size * 0.5
			- global_position
		)

		var b: Vector2 = (
			to_node.global_position
			+ to_node.size * 0.5
			- global_position
		)

		draw_line(a, b, Color.WHITE, 3.0)
