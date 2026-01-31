extends VBoxContainer


@export var customStyle: Script = preload("res://shared/style.gd")

var font_baskervville = preload("res://shared/fonts/Baskervville/static/Baskervville-SemiBold.ttf")

func _input(event: InputEvent):
	var customTheme = Theme.new()
	var style = customStyle.new()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var lmb_node = find_child("LMB", false, false)
			if event.pressed:
				lmb_node.add_theme_stylebox_override("panel", style.get_pressed_mouse_style())
			else:
				lmb_node.add_theme_stylebox_override("panel", style.get_mouse_style())

func _ready() -> void:
	var customTheme = Theme.new()
	var style = customStyle.new()

	customTheme.set_stylebox("panel", "PanelContainer", style.get_mouse_style())

	customTheme.set_color("font_color", "Label", style.font_color_normal)
	customTheme.set_font_size("font_size","Label",style.font_size)
	customTheme.set_font("font","Label",font_baskervville)

	self.theme = customTheme
