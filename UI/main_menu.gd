extends Control
class_name MainMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass

func _notification(what):	

	if what == NOTIFICATION_VISIBILITY_CHANGED:

		if visible:

			await get_tree().process_frame
			$MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/GameTest.grab_focus()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_settings_pressed() -> void:
	UIManager.open_settings()
	_sound()

func _on_exit_pressed() -> void:
	SceneManager.exit()
	_sound()


func _on_game_test_pressed() -> void:


	SceneManager.go_to_game_test()
	_sound()

func _on_button_2_pressed() -> void:
	SceneManager._go_to_big_room_test()
	_sound()

func _on_join_pressed() -> void:
	SceneManager.go_to_game_test()
	_sound()
func _sound()->void :
	AudioManager.play_ui_sound("menu_select")


func get_all_buttons(node: Node, result := []) -> Array:

	for child in node.get_children():

		if child is Button:
			result.append(child)

		get_all_buttons(child, result)

	return result
