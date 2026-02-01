extends PanelContainer

@export var customStyle: Script = preload("res://shared/style.gd")

var font_baskervville = preload("res://shared/fonts/Baskervville/static/Baskervville-SemiBold.ttf")

func _ready() -> void:
	var customTheme = Theme.new()
	var style = customStyle.new()

	customTheme.set_stylebox("panel", "PanelContainer", style.get_normal_style(1))

	customTheme.set_color("font_color", "Label", style.font_color_normal)
	customTheme.set_font_size("font_size","Label",style.font_size)
	customTheme.set_font("font","Label",font_baskervville)

	self.theme = customTheme
