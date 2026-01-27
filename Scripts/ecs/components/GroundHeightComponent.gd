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
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed

	for z in range(size_z):
		for x in range(size_x):
			var nx = x * freq
			var nz = z * freq

			# базовая мягкая волна
			var base = sin(nx + _seed) * cos(nz - _seed)

			# пятна-лужи
			var puddle_noise = rng.randf()
			if puddle_noise < puddles:
				base -= rng.randf_range(0.4, 1.0)

			var h = base * amp
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
