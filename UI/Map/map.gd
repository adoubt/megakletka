extends Control

var rows :int
var cols :int

@export var fade_time := 0.18
@onready var legend: Control = $Legend
var fade_tween: Tween
var map_tween : Tween
var legend_tween : Tween
var first_open: bool = true
@export var row_spacing := 90
@export var col_spacing := 80
@export var padding := 100

@onready var canvas: Control = %MapCanvas
@onready var map_scroll: ScrollContainer = %MapScroll
@onready var container: Control = %Container

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

func _ready():
	
	container.pivot_offset = canvas.size /2


func redraw_from_snapshot(snapshot: Dictionary) -> void:
	
	_clear()
	seed(_map_layout_seed(snapshot.floors))
	var floors: Dictionary = snapshot.floors
	var floor_keys := floors.keys()
	var current_day: int = snapshot.current_day
	var reachable :=[]
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
			if cell.id == current_day:
				reachable = cell.exits
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
			if cell.type == DayType.BOSS:
				node.texture.size*= 2.5
				node.texture.position = - node.texture.size/2
				rand_y-= 40
				node.position.x = center_x
			var node_icon = icons.get(cell.type)
			var node_icon_hover = icons_hover.get(cell.type)
			node.texture._texture_normal = node_icon
			node.texture._texture_hover = node_icon_hover
			
			node.texture.day_type = cell.type
			node.completed = cell.completed
			node.reachable = cell.id in reachable
			node.day_id = cell.id
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
	first_open = true
	map_scroll.scroll_vertical = 0.0
	#container.size.y - map_scroll.size.y
	
	
	

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
	await get_tree().process_frame

	var max_scroll := int(
		container.size.y - map_scroll.size.y
	)
	
	if map_tween:
		map_tween.kill()
	legend.position = Vector2(2000,130)

	canvas.scale = Vector2(5.3, 5.8)
	canvas.pivot_offset.x = canvas.size.x / 2
	canvas.animate_connections()
	map_tween = create_tween()

	
	map_tween.tween_interval(0.2)


	map_tween.parallel().tween_property(
		canvas,
		"scale",
		Vector2.ONE,
		1.0
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	map_tween.parallel().tween_property(
		map_scroll,
		"scroll_vertical",
		max_scroll,
		3.0
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	_animate_legend()
	#map_tween.finished.connect()
	
func _animate_legend() ->void :
	
	var target_pos: Vector2 = Vector2(810.0,130.0)
	if legend_tween:
		legend_tween.kill()
	legend_tween = create_tween()	
	legend_tween.tween_property(
		legend,
		"position",
		target_pos,
		2.0
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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



func hover_all_of_type(type:int) -> void:
	for node_row in nodes:
		for node in node_row:
			if not node:
				continue
			if node.completed:
				continue	
			if node.texture.day_type == type:
				node.texture.set_hover(true)
			else:
				node.texture.set_unhover()


func normal_all_of_type(type:int) -> void:
	for node_row in nodes:
		for node in node_row:
			if not node:
				continue
			if node.completed:
				continue		
			if node.texture.day_type == type:
				node.texture.set_normal(true)
			else:
				node.texture.set_normal(true)


func play_open_anim() -> void:
	if first_open: 
		_scroll_to_bottom()
		first_open = false
	modulate.a = 0.0

	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD)
	fade_tween.set_ease(Tween.EASE_OUT)

	fade_tween.tween_property(
		self,
		"modulate:a",
		1.0,
		fade_time
	)


func play_close_anim() -> void:
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD)
	fade_tween.set_ease(Tween.EASE_IN)

	fade_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		fade_time
	)

	fade_tween.finished.connect(func():
		visible = false
	)
