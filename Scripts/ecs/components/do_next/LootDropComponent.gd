extends Resource
class_name LootDropComponent

## Список предметов, которые может дропнуть
var loot_table: Array[String] = []

## Шанс дропа каждого предмета (0–1)
var drop_chances: Array[float] = []

## Количество попыток выпадения
var rolls: int = 1
