extends Resource
class_name GroundHeightComponent

var size_x: int
var size_z: int
var cell_size: float
var heights: PackedFloat32Array

func _init(x: int, z: int, cell: float):
	size_x = x
	size_z = z
	cell_size = cell
	heights = PackedFloat32Array()
	heights.resize(size_x * size_z)

func generate(_seed: int, amp: float, freq: float, puddles: float) -> void:

	var macro := FastNoiseLite.new()
	macro.seed = _seed
	macro.frequency = 0.01
	macro.fractal_octaves = 3

	var detail := FastNoiseLite.new()
	detail.seed = _seed + 999
	detail.frequency = 0.08
	detail.fractal_octaves = 2

	var mountain_noise := FastNoiseLite.new()
	mountain_noise.seed = _seed + 222
	mountain_noise.frequency = 0.03

	var flatten_noise := FastNoiseLite.new()
	flatten_noise.seed = _seed + 444
	flatten_noise.frequency = 0.02

	# случайная сторона наклона мира
	var slope_dir := Vector2(randf_range(-1,1), randf_range(-3,5)).normalized()

	# шанс большой горы
	var has_mountain := randf() < 0.7

	var mountain_center := Vector2(
		randf_range(0, size_x),
		randf_range(0, size_z)
	)

	for z in range(size_z):
		for x in range(size_x):

			var pos := Vector2(x, z)

			var h := 0.0

			# ==================================================
			# GLOBAL WORLD SLOPE
			# ==================================================

			var slope = (pos.dot(slope_dir) / max(size_x, size_z)) * 8.0

			h += slope

			# ==================================================
			# LARGE TERRAIN SHAPES
			# ==================================================

			h += macro.get_noise_2d(x, z) * 6.0

			# ==================================================
			# OPTIONAL BIG MOUNTAIN
			# ==================================================

			if has_mountain:

				var dist = pos.distance_to(mountain_center)

				var mountain_radius = size_x * 0.35

				if dist < mountain_radius:

					var falloff = 1.0 - (dist / mountain_radius)

					falloff = pow(falloff, 2.0)

					h += falloff * 18.0

					h += mountain_noise.get_noise_2d(x, z) * falloff * 4.0

			# ==================================================
			# FLAT AREAS / PLAINS
			# ==================================================

			var flatten = flatten_noise.get_noise_2d(x, z)

			if flatten > 0.35:

				h = lerp(h, floor(h * 0.3), 0.7)

			# ==================================================
			# RIVER / ROAD TUNNEL
			# ==================================================

			var river = abs(detail.get_noise_2d(x * 0.5, z * 0.5))

			if river < 0.91:

				h -= 1.0

			# ==================================================
			# SMALL DETAIL
			# ==================================================

			h += detail.get_noise_2d(x, z) * 1.2

			# ==================================================
			# SWAMP LOWLANDS
			# ==================================================

			if h < puddles:

				h -= 1.5

			heights[x + z * size_x] = h

func get_height(world_x: float, world_z: float) -> float:
	var half_x := (size_x - 1) * cell_size * 0.5
	var half_z := (size_z - 1) * cell_size * 0.5

	# world → local grid space
	var lx := (world_x + half_x) / cell_size
	var lz := (world_z + half_z) / cell_size

	var ix := int(floor(lx))
	var iz := int(floor(lz))

	# защита от выхода за края
	if ix < 0 or iz < 0 or ix >= size_x - 1 or iz >= size_z - 1:
		return 0.0

	# дробная часть
	var fx := lx - ix
	var fz := lz - iz

	# индексы
	var i00 := ix + iz * size_x
	var i10 := (ix + 1) + iz * size_x
	var i01 := ix + (iz + 1) * size_x
	var i11 := (ix + 1) + (iz + 1) * size_x

	var h00 := heights[i00]
	var h10 := heights[i10]
	var h01 := heights[i01]
	var h11 := heights[i11]

	# билинейная интерполяция
	var hx0 :float= lerp(h00, h10, fx)
	var hx1 :float= lerp(h01, h11, fx)

	return lerp(hx0, hx1, fz)
