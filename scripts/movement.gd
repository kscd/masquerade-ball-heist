extends Node

@export var max_speed = 150.0
@export var acceleration = 1500.0
@export var friction = 1200.0

@onready var body: CharacterBody2D = get_parent()
@onready var sprite: Node2D = get_parent().get_node("Character")

var input_direction = Vector2.ZERO
var push_direction = Vector2.ZERO
var push_force = 0.0

var is_hopping = false
var hop_tween: Tween

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
	
	if body.velocity.length() > 10:
		start_hop()
	else:
		stop_hop()
	
		

func start_hop():
	if is_hopping: return
	is_hopping = true
	
	if hop_tween: hop_tween.kill()
	hop_tween = create_tween().set_loops()
	
	hop_tween.tween_property(sprite, "position:y", -10, 0.15).set_trans(Tween.TRANS_SINE)
	hop_tween.parallel().tween_property(sprite, "rotation_degrees", 2, 0.15)
	
	hop_tween.tween_property(sprite, "position:y", 0, 0.15).set_trans(Tween.TRANS_SINE)
	hop_tween.parallel().tween_property(sprite, "rotation_degrees", -2, 0.15)
	
	hop_tween.tween_property(sprite, "position:y", -10, 0.15).set_trans(Tween.TRANS_SINE)
	hop_tween.parallel().tween_property(sprite, "rotation_degrees", -2, 0.15)
	
	hop_tween.tween_property(sprite, "position:y", 0, 0.15).set_trans(Tween.TRANS_SINE)
	hop_tween.parallel().tween_property(sprite, "rotation_degrees", 2, 0.15)

func stop_hop():
	if not is_hopping: return
	is_hopping = false
	
	if hop_tween: hop_tween.kill()
	
	var reset = create_tween()
	reset.tween_property(sprite, "position:y", 0, 0.1)
	reset.parallel().tween_property(sprite, "rotation_degrees", 0, 0.1)
