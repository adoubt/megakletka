extends BaseSystem
class_name DamagePopupSystem

# Настройки попапа
var RICE_SPEED: float = 0.7
const SCALE_FACTOR: float = 10.1


func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["DamagePopupComponent","RenderComponent", "LifeTimeComponent", "TransformComponent"], ["DeadComponent"])
	
func update(delta: float) -> void:
	for e_id in arch.entities:
		var popup = cs.get_component(e_id, "DamagePopupComponent")
		var tf = cs.get_component(e_id, "TransformComponent")
		var lifetime = cs.get_component(e_id, "LifeTimeComponent")
		
		
		
		# --- Анимация движения вверх ---
		popup.rise_offset += RICE_SPEED * delta
		tf.position = popup.last_position + Vector3(
			popup.drift_x * popup.rise_offset, 1.0 + popup.rise_offset, 0
			)

		# --- Визуальные эффекты ---
		
		var render = cs.get_component(e_id, "RenderComponent")
		if not render.instance:
			continue
		# Масштаб пропорционально урону
		if popup.render_priority == -1:
			popup.render_priority = 0
			render.instance.render_priority = 0
		var damage_norm :float = clamp(popup.value / 50.0, 0.0, 1.0)
	
		var scale = 1+ damage_norm * SCALE_FACTOR * lifetime.time_left/RICE_SPEED
		cs.add_component(e_id, "ScaleRequestComponent", ScaleRequestComponent.new(scale))
		
		
		# Цвет по типу урона
		var color = Color(0.543, 0.0, 0.1, 1.0)
		var base_alpha :float = clamp(lifetime.time_left / RICE_SPEED, 0.0, 1.0)
		var alpha_bonus :float= lerp(0.6, 1.2, damage_norm)
		var alpha :float= clamp(base_alpha * alpha_bonus, 0.0, 1.0)

		match popup.damage_type:
			
			"physics": color = Color(1.0, 1.0, 1.0,alpha)
			"fire": color = Color(1, 0.5, 0,alpha)
			"ice": color = Color(0.5, 0.8, 1,alpha)
		render.instance.set_modulate(color)
		render.instance.set_text(str(int(popup.value)))
