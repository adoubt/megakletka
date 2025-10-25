extends BaseSystem
class_name DamagePopupSystem

# Настройки попапа
var rise_speed: float = 0.6
var scale_factor: float = 0.02


func update(delta: float) -> void:
	var popups = get_entities_with(["DamagePopupComponent", "LifetimeComponent", "TransformComponent"])
	for e_id in popups:
		var popup = cs.get_component(e_id, "DamagePopupComponent")
		var tf = cs.get_component(e_id, "TransformComponent")
		var lifetime = cs.get_component(e_id, "LifetimeComponent")
		
		if popup == null or tf == null or lifetime == null:
			continue
		
		# --- Обновляем позицию ---
		var owner_tf = cs.get_component(popup.owner_id, "TransformComponent")
		if owner_tf != null:
			# Если владелец жив, сохраняем его текущую позицию
			popup.last_position = owner_tf.position
		elif popup.last_position == null:
			# На всякий случай, если нет last_position — используем текущую трансформ-позицию
			popup.last_position = tf.position
		
		# --- Анимация движения вверх ---
		popup.rise_offset += rise_speed * delta
		tf.position = popup.last_position + Vector3(0, 1.0 + popup.rise_offset, 0)
		
		# --- Визуальные эффекты ---
		if cs.has_component(e_id, "RenderComponent"):
			var render = cs.get_component(e_id, "RenderComponent")
			if render and render.instance:
				# Масштаб пропорционально урону
				var scale = 1.0 + popup.value * scale_factor
				render.instance.scale = Vector3.ONE * scale * lifetime.time_left/0.8
				
				# Цвет по типу урона
				var color = Color(0.543, 0.0, 0.1, 1.0)
				
				match popup.damage_type:
					"physical": color = Color(0.543, 0.0, 0.1,lifetime.time_left/0.5)
					"fire": color = Color(1, 0.5, 0,lifetime.time_left/0.5)
					"ice": color = Color(0.5, 0.8, 1,lifetime.time_left/0.5)
				render.instance.set_modulate(color)
				render.instance.set_text(str(popup.value))
		
		# --- Уменьшаем Lifetime ---
		lifetime.time_left -= delta
		if lifetime.time_left <= 0.0:
			if not cs.has_component(e_id, "DeadComponent"):
				cs.add_component(e_id, "DeadComponent", DeadComponent.new())
