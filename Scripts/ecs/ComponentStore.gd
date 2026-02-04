extends RefCounted
class_name ComponentStore

# =========================================================
# DATA
# =========================================================

# component_name -> { entity_id : component }
var components: Dictionary = {}

# Array[Archetype]
var archetypes: Array[Archetype] = []


# =========================================================
# ENTITY / COMPONENT OPS
# =========================================================

func add_component(e_id: int, name: String, component: Object) -> void:
	if not components.has(name):
		components[name] = {}

	components[name][e_id] = component

	_update_archetypes_for_entity(e_id)


func remove_component(e_id: int, name: String) -> void:
	if not components.has(name):
		return

	components[name].erase(e_id)
	if components[name].is_empty():
		components.erase(name)

	_update_archetypes_for_entity(e_id)


func get_component(e_id: int, name: String) -> Object:
	return components.get(name, {}).get(e_id, null)


func has_component(e_id: int, name: String) -> bool:
	return components.has(name) and components[name].has(e_id)


func remove_all_components_for_entity(e_id: int) -> void:
	for comp_dict in components.values():
		comp_dict.erase(e_id)

	for arch in archetypes:
		if arch.entities.has(e_id):
			arch.entities.erase(e_id)
	_update_archetypes_for_entity(e_id)

func clear() -> void:
	components.clear()
	archetypes.clear()


# =========================================================
# ARCHETYPES
# =========================================================

func register_archetype(include: Array[String], exclude: Array[String] = []) -> Archetype:

	var inc := include.duplicate()
	var exc := exclude.duplicate()
	inc.sort()
	exc.sort()

	for arch in archetypes:
		if _same_archetype(arch, inc, exc):
			return arch
			
	var arch := Archetype.new()
	arch.include = inc
	arch.exclude = exc
	arch.entities = []

	archetypes.append(arch)

	for e_id in _all_entities():
		if _matches_archetype(e_id, arch):
			arch.entities.append(e_id)

	return arch


func _same_archetype(a: Archetype, include: Array[String], exclude: Array[String]) -> bool:
	if a.include.size() != include.size():
		return false
	if a.exclude.size() != exclude.size():
		return false

	for c in include:
		if not a.include.has(c):
			return false

	for c in exclude:
		if not a.exclude.has(c):
			return false

	return true

# =========================================================
# MATCHING
# =========================================================

func _matches_archetype(e_id: int, arch: Archetype) -> bool:
	# include
	for c in arch.include:
		if not has_component(e_id, c):
			return false

	# exclude
	for c in arch.exclude:
		if has_component(e_id, c):
			return false

	return true

func _update_archetypes_for_entity(e_id: int) -> void:
	for arch in archetypes:
		var matches := _matches_archetype(e_id, arch)
		var has := arch.entities.has(e_id)

		if matches and not has:
			arch.entities.append(e_id)
		elif not matches and has:
			arch.entities.erase(e_id)

# =========================================================
# UTILS
# =========================================================

func _all_entities() -> Array[int]:
	var entity_set: Dictionary = {}

	for comp_dict in components.values():
		for e_id in comp_dict:
			entity_set[e_id] = true

	var result: Array[int] = []
	result.resize(entity_set.size())

	var i := 0
	for e_id in entity_set.keys():
		result[i] = e_id
		i += 1

	return result
