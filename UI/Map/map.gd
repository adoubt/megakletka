extends Control

var rows :int
var cols :int
@export var row_spacing := 90
@export var col_spacing := 80
@export var padding := 100

@onready var canvas: Control = %MapCanvas
@onready var map_scroll: ScrollContainer = %MapScroll
@onready var container: Control = %Container
@onready var background: ColorRect = %Background
@export var random_offset_x :=25
@export var random_offset_y := 20

@export var icons := {
	DayType.ENEMY: preload("res://assets/icons/map/enemy.png"),
	DayType.ELITE: preload("res://assets/icons/map/elite.png"),
	DayType.BOSS: preload("res://assets/icons/map/boss.png"),
	DayType.MERCHANT: preload("res://assets/icons/map/merchant.png"),
	DayType.CHEST: preload("res://assets/icons/map/chest.png"),
	DayType.LOBBY: preload("res://assets/icons/map/lobby.png"),
	DayType.MERCHANT_DEAD: preload("res://assets/icons/map/merchant_dead.png"),
	DayType.HIDDEN: preload("res://assets/icons/map/hidden.png"),
	DayType.MUSHROOMS: preload("res://assets/icons/map/mushrooms.png")
	
	
}
@export var icons_hover := {
	DayType.ENEMY: preload("res://assets/icons/map/enemy_hover.png"),
	DayType.ELITE: preload("res://assets/icons/map/elite_hover.png"),
	DayType.BOSS: preload("res://assets/icons/map/boss_hover.png"),
	DayType.MERCHANT: preload("res://assets/icons/map/merchant_hover.png"),
	DayType.CHEST: preload("res://assets/icons/map/chest_hover.png"),
	DayType.LOBBY: preload("res://assets/icons/map/lobby_hover.png"),
	DayType.MERCHANT_DEAD: preload("res://assets/icons/map/merchant_dead_hover.png"),
	DayType.HIDDEN: preload("res://assets/icons/map/hidden_hover.png"),
	DayType.MUSHROOMS: preload("res://assets/icons/map/mushrooms_hover.png")
	
	
}
var nodes: Array = []


func _ready() -> void:
	pass


func redraw_from_snapshot(snapshot: Dictionary) -> void:
	_clear()
	seed(_map_layout_seed(snapshot.floors))
	var floors: Dictionary = snapshot.floors
	var floor_keys := floors.keys()
	floor_keys.sort()

	rows = floor_keys.size()
	cols = 0
	for floor in floors.values():
		for cell in floor:
			cols = max(cols, cell.column + 1)

	_prepare_canvas()

	# grid[y][x] = MapNode | null
	nodes.clear()
	nodes.resize(rows)

	# day_id -> MapNode (для связей)
	var node_by_id := {}

	var center_x := canvas.custom_minimum_size.x * 0.5
	var base_y := canvas.custom_minimum_size.y - padding

	# ---------- СПАВН НОД ----------
	for y in range(rows):
		var floor = floor_keys[y]
		var row := []
		row.resize(cols)
		for i in range(cols):
			row[i] = null

		for cell in floors[floor]:
			var x = cell.column

			var node := preload("res://UI/Map/MapNode.tscn").instantiate()
			canvas.add_child(node)

			var offset_x = (x - (cols - 1) * 0.5) * col_spacing
			var rand_x := randf_range(-random_offset_x, random_offset_x)
			var rand_y := randf_range(-random_offset_y, random_offset_y)

			node.position = Vector2(
				center_x + offset_x + rand_x,
				base_y - y * row_spacing + rand_y
			)
			var node_icon = icons.get(cell.type)
			var node_icon_hover = icons_hover.get(cell.type)
			node.texture.texture_normal = node_icon
			node.texture.texture_hover = node_icon_hover
			row[x] = node
			node_by_id[cell.id] = node

		nodes[y] = row

	# ---------- СВЯЗИ ----------
	if "connections" in canvas:
		canvas.connections.clear()

	for y in range(rows):
		var floor = floor_keys[y]
		for cell in floors[floor]:
			var from_node = node_by_id.get(cell.id, null)
			if from_node == null:
				continue

			for to_id in cell.exits:
				var to_node = node_by_id.get(to_id, null)
				if to_node == null:
					continue

				canvas.connections.append({
					"from": from_node,
					"to": to_node
				})

	canvas.queue_redraw()
	await get_tree().process_frame
	_scroll_to_bottom()

func _connect_from_snapshot(connections: Array) -> void:
	if not "connections" in canvas:
		return

	canvas.connections.clear()

	for c in connections:
		var from = nodes[c.from.y][c.from.x]
		var to = nodes[c.to.y][c.to.x]

		if from != null and to != null:
			canvas.connections.append({
				"from": from,
				"to": to
			})



func _prepare_canvas() -> void:
	var _size = Vector2(
		cols * col_spacing + padding *2,
		rows * row_spacing + padding *2
	)
	container.custom_minimum_size = _size
	container.size = _size   # ← БЕЗ ЭТОГО СКРОЛЛА НЕ БУДЕТ

	canvas.custom_minimum_size = _size
	canvas.size = _size 



func _clear() -> void:
	for c in canvas.get_children():
		if c.name != "Background":
			c.queue_free()

	nodes.clear()
	if "connections" in canvas:
		canvas.connections.clear()



func _scroll_to_bottom() -> void:
	var bar := map_scroll.get_v_scroll_bar()
	print("scroll max:", bar.max_value)
	await get_tree().process_frame
	var max_scroll := int(
		canvas.size.y - map_scroll.size.y
	)
	map_scroll.scroll_vertical = max(max_scroll, 0)

func _map_layout_seed(floors: Dictionary) -> int:
	var s := ""

	var keys := floors.keys()
	keys.sort()

	for floor in keys:
		for cell in floors[floor]:
			s += "%s:%d:%s|" % [
				cell.id,
				cell.column,
				cell.type
			]

	return s.hash()
