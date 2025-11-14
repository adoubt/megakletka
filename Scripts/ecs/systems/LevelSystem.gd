extends BaseSystem
class_name LevelSystem

func update(_delta: float) -> void:
	var entities = get_entities_with(["LevelComponent"], ["DeadComponent"])
	if entities.is_empty():
		return

	for e_id in entities:
		var level = cs.get_component(e_id, "LevelComponent")
		# если компонент только создан — инициализируем требуемый XP
		if level.xp_to_next <= 0:
			level.xp_to_next = get_required_xp(level.level)
		# Проверяем ап уровня
		while level.current_xp >= level.xp_to_next:
			level.current_xp -= level.xp_to_next
			level.level += 1
			level.skill_points += 1

			# пересчитываем требуемый XP
			level.xp_to_next = get_required_xp(level.level)
			var xp_mult_comp = cs.get_component(e_id, "XPMultComponent")
			if xp_mult_comp:
				if level.level in [20, 40, 60]:
					xp_mult_comp.final_value += 1.0
				elif level.level in [21, 41, 61]:
					xp_mult_comp.final_value -= 1.0

				
			# можно заспавнить LevelUpEvent (чтобы другие системы отреагировали)
			# cs.add_component(e_id, "LevelUpEvent", LevelUpEvent.new())

		# Если хочешь обновлять HUD напрямую
		if UIManager and UIManager.hud:
			UIManager.hud.current_xp = level.current_xp
			UIManager.hud.max_xp = level.xp_to_next
			UIManager.hud.current_level.text = "LVL %d" % [int(level.level)]

func get_required_xp(level: int) -> float:
	## базовая логика как в Vampire Survivors:
	## до 20 уровня растёт на +10 XP
	## с 21 по 40 — на +13 XP
	## после 41 — на +16 XP
	## а на 20 и 40 уровнях добавляется фикс. бонус

	var required_xp: float

	if level <= 1:
		required_xp = 5.0
	elif level <= 20:
		required_xp = 5.0 + (level - 1) * 10.0
	elif level <= 40:
		required_xp = (5.0 + 19 * 10.0) + (level - 20) * 13.0
	else:
		required_xp = (5.0 + 19 * 10.0) + (20 * 13.0) + (level - 40) * 16.0

	# фиксированные пики
	if level == 20:
		required_xp += 600.0
	elif level == 40:
		required_xp += 2400.0

	return required_xp
