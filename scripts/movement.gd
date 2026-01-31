extends Node

@export var max_speed = 300.0
@export var acceleration = 1500.0
@export var friction = 1200.0

@onready var body: CharacterBody2D = get_parent()
var input_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if input_direction != Vector2.ZERO:	
		body.velocity = body.velocity.move_toward(input_direction * max_speed, acceleration * delta)
	else:
		body.velocity = body.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	body.move_and_slide()
