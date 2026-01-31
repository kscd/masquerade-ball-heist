extends Button

func _on_pressed():
	var main_menu_scene = load("uid://b7fhtexecjr7h")
	get_tree().change_scene_to_packed(main_menu_scene)
