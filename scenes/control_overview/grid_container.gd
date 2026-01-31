extends GridContainer

@export var customStyle: Script = preload("res://shared/style.gd")

var font_baskervville = preload("res://shared/fonts/Baskervville/static/Baskervville-SemiBold.ttf")

func _input(event: InputEvent):
	var customTheme = Theme.new()
	var style = customStyle.new()

	if event is InputEventKey:
		var key_text = OS.get_keycode_string(event.keycode)
		var key_node = find_child(key_text, true, false)

		if key_node and key_node is PanelContainer:
			var label = key_node.get_child(0)

			if event.pressed:
				key_node.add_theme_stylebox_override("panel", style.get_pressed_style(1))
				label.position.y = 2
				label.add_theme_color_override("font_color", style.font_color_pressed)
			else:
				key_node.add_theme_stylebox_override("panel", style.get_normal_style(1))
				key_node.get_child(0).position.y = 0
				label.remove_theme_color_override("font_color")

func _ready() -> void:
	var customTheme = Theme.new()
	var style = customStyle.new()

	customTheme.set_stylebox("panel", "PanelContainer", style.get_normal_style(1))

	customTheme.set_color("font_color", "Label", style.font_color_normal)
	customTheme.set_font_size("font_size","Label",style.font_size)
	customTheme.set_font("font","Label",font_baskervville)

	self.theme = customTheme
