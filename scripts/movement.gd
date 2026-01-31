extends Node

@export var max_speed = 300.0
@export var acceleration = 1500.0
@export var friction = 1200.0

@onready var body: CharacterBody2D = get_parent()
var input_direction = Vector2.ZERO
var push_direction = Vector2.ZERO
var push_force = 0.0

func _physics_process(delta: float) -> void:
	if input_direction != Vector2.ZERO:	
		body.velocity = body.velocity.move_toward(input_direction * max_speed, acceleration * delta)
	else:
		body.velocity = body.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if push_direction != Vector2.ZERO:
		body.velocity = body.velocity.move_toward(push_direction * max_speed, push_force * delta)
	else:
		pass
	
	body.move_and_slide()
