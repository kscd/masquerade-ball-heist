extends Button

func _on_pressed():
	var main_menu_scene = load("uid://jllv3wm3ws2p")
	get_tree().change_scene_to_packed(main_menu_scene)
