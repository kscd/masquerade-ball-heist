extends Button

func _on_pressed():
	var controls_menu_scene = load("uid://bswfnkxv33unh")
	get_tree().change_scene_to_packed(controls_menu_scene)
