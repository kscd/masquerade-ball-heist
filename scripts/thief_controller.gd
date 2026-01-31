extends Node

@onready var movement = get_parent()

func get_input_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")
	
func _process(_delta: float) -> void:
	movement.input_direction = get_input_direction()
