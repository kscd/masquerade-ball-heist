extends MarginContainer

@export var customStyle: Script = preload("res://shared/style.gd")

var font_baskervville = preload("res://shared/fonts/Baskervville/static/Baskervville-SemiBold.ttf")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var customTheme = Theme.new()
	var style = customStyle.new()

	customTheme.set_stylebox("normal", "Button", style.get_normal_style(1))
	customTheme.set_stylebox("hover", "Button", style.get_hover_style(1))
	customTheme.set_stylebox("pressed", "Button", style.get_pressed_style(1))

	customTheme.set_color("font_color", "Button", style.font_color_normal)
	customTheme.set_color("font_hover_color", "Button", style.font_color_hover)
	customTheme.set_color("font_pressed_color", "Button", style.font_color_pressed)
	customTheme.set_font_size("font_size","Button",style.font_size)
	customTheme.set_font("font","Button",font_baskervville)
	
	customTheme.set_color("font_color", "Label", style.font_color_normal)

	self.theme = customTheme
