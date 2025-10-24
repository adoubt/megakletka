# OrbitComponent.gd
extends Resource
class_name OrbitComponent
var radius: float = 1.0
var speed: float = 6.0
var height: float = 0.0
var angle: float = 0.0
var offset_angle: float = 0.0 # уникальный угол, чтобы равномерно раскидывать
