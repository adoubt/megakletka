extends Node

# Жёстко прописанные пути сцен
const SCENES := {
	"Intro": "uid://bsoxxlhnjn45f",
	"MainMenu": "uid://dcirc02tx3del",
	"GameTest":  "uid://bkfn061oy0fu0",
	"BigRoomTest": "uid://6g1u6okbk7nj",
}

# текущая сцена
var current_scene_name: String = "Intro"

# ---------------- PUBLIC API ----------------

func go_to_intro():
	_change_scene("Intro")

func go_to_main_menu():
	_change_scene("MainMenu")


func go_to_game_test():
	_change_scene("GameTest")

func _go_to_big_room_test():
	_change_scene("BigRoomTest")
	
func restart_current():
	_change_scene(current_scene_name)
func exit():
	get_tree().quit()

# ---------------- INTERNAL ----------------

func _change_scene(_name: String):
	if not SCENES.has(_name):
		push_error("SceneManager: сцена не найдена: %s" % _name)
		return
	current_scene_name = _name
	ControllerManager.refresh()
	get_tree().change_scene_to_file(SCENES[_name])
	
	_update_ui_for_scene()
	UIManager.close_all()
	
func _update_ui_for_scene():

	# форс курсор через UIManager
	if current_scene_name in ["MainMenu"]:
		UIManager.force_cursor_visible = true
	else:
		UIManager.force_cursor_visible = false
	#UIManager._update_ui_state()
	if current_scene_name in ["BigRoomTest","GameTest"]:
		UIManager.hud_show()
	else:
		UIManager.hud_hide()
