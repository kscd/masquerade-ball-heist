extends Control

@export var customStyle: Script = preload("res://shared/style.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var customTheme = Theme.new()
	var _style = customStyle.new()

	self.theme = customTheme
