extends Button

func _on_pressed():
	var credits_menu_scene = load("uid://d4cj8ut00iuwg")
	get_tree().change_scene_to_packed(credits_menu_scene)
