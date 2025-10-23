extends Resource
class_name PatrolComponent

## Список точек патруля
var waypoints: Array[Vector3] = []

## Индекс текущей цели
var current_index: int = 0

## Скорость передвижения
var speed: float = 100.0

## Задержка в каждой точке
var wait_time: float = 1.0
var wait_timer: float = 0.0
