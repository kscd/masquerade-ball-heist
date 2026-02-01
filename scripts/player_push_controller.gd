extends CharacterBody2D
class_name PlayerPushController

@export var mgr: CrowdManager

@export var push_radius: float
@export var max_push: float 
@export var falloff_exp: float 
@export var side_bias: float 

func physics_step(_dt: float) -> void:
	if mgr == null:
		return

	var push_vec := PushSolver2D._compute_total_push_vector(
		mgr,
		self,
		push_radius,
		max_push,
		falloff_exp,
		side_bias,
	)

	if push_vec.length_squared() > 0.0001:
		print("player got pushed")
		%Movement.push_direction = push_vec.normalized()
		%Movement.push_force = push_vec.length()
	else:
		print("force to small")
		%Movement.push_direction = Vector2.ZERO
		%Movement.push_force = 0.0
