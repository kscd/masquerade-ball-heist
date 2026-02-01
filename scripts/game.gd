extends Node2D

@onready var player = $Player

func _ready() -> void:
	hide()
	get_tree().paused = true
