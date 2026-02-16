extends BaseSystem
class_name ItemViewBuilderSystem


var stat_mod_arch: Archetype
var ability_arch: Archetype
var item_arch: Archetype
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["ItemViewBuildRequestComponent","ItemComponent", "RenderComponent",],["DeadComponent"])
	ability_arch = cs.register_archetype(["ItemAbilityComponent"])
	stat_mod_arch = cs.register_archetype([ "ModifierComponent"],["DeadComponent"])
	
	item_arch = cs.register_archetype(["ItemComponent"],["DeadComponent"])
	
func update(delta: float) -> void:
	if arch.entities.is_empty():
		return
	
	var items := arch.entities.duplicate()
	
	for item in items:
		var view_data := {
			"abilities": []
		}
		
		var item_title_comp := cs.get_component(item, "TitleComponent")
		view_data["item_title"] = item_title_comp.title
		view_data["item_description"] = item_title_comp.description
		
		var cost_comp := cs.get_component(item, "CostComponent")
		view_data["cost"] = cost_comp.base_value
		
		for ability in ability_arch.entities:
			var ability_comp := cs.get_component(ability, "ItemAbilityComponent")
			if ability_comp.owner_id != item:
				continue
			
			var ability_data := {}
			
			var ability_title_comp := cs.get_component(ability, "TitleComponent")
			ability_data["ability_title"] = ability_title_comp.title
			
			# собираем числовые данные СНАЧАЛА
			var modifier := cs.get_component(ability, "StatModifierComponent")
			if modifier:
				ability_data["stat_modifier"] = {"value":modifier.value,
					"domain":modifier.domain,
					"stat":modifier.stat}
			
			var trigger := cs.get_component(ability, "TriggerComponent")
			if trigger:
				ability_data["trigger"] = {"event":trigger.event,
					"action":trigger.action,
					"value":trigger.value}
			
			var scaling := cs.get_component(ability, "ScalingComponent")
			if scaling:
				ability_data["scaling"] = {"per":scaling.per,
					"source":scaling.source,
					"domain":scaling.domain} 
			
			# теперь форматируем описание
			var template: String = ability_title_comp.description
			var final_description := _format_template(template, ability_data)
			
			ability_data["ability_description"] = final_description
			
			view_data["abilities"].append(ability_data)
		
		var render := cs.get_component(item, "RenderComponent")
		if render and render.instance:
			render.instance.data = view_data
		
		cs.remove_component(item, "ItemViewBuildRequestComponent")

func _format_template(template: String, data: Dictionary) -> String:
	var result := template
	
	var regex := RegEx.new()
	regex.compile("\\{([^}]+)\\}")
	
	var matches = regex.search_all(template)
	
	for match in matches:
		var full_placeholder := match.get_string(0) # {stat_modifier.value:percent}
		var content := match.get_string(1)          # stat_modifier.value:percent
		
		var parts := content.split(":")
		var path := parts[0]
		var format := parts[1] if parts.size() > 1 else ""
		
		var keys := path.split(".")
		var value = data
		
		# Спускаемся по словарю
		for k in keys:
			if value is Dictionary and value.has(k):
				value = value[k]
			else:
				value = ""
				break
		
		# --- Форматирование ---
		value = _apply_format(value, format)
		
		result = result.replace(full_placeholder, str(value))
	
	return result
func _apply_format(value, format: String):
	match format:
		"percent":
			return str(int(float(value) * 100.0)) + "%"
		"int":
			return str(int(round(float(value))))
		"float1":
			return str(snapped(float(value), 0.1))
		_:
			return str(value)
