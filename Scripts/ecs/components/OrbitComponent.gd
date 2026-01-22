# OrbitComponent.gd
extends Resource
class_name OrbitComponent
var radius: float = 1.0
var height: float = 0.0
var angle: float = 0.0
var offset_angle: float = 0.0 # уникальный угол, чтобы равномерно раскидывать
var tilt_x: float = 0.0   # ← НОВОЕ
var tilt_y: float = 0.0
var tilt_z: float = 0.0
