# PlayerPushController.gd
extends Node
class_name PlayerPushController

@export var crowd_manager: CrowdManager
@export var player_body: CharacterBody2D
@export var movement_controller: Node  # expects push_direction, push_force

@export var push_radius: float = 150.0
@export var max_side_push: float = 180.0
@export var push_forward_ratio: float = 0.20
@export var push_falloff_exp: float = 1.5
@export var max_total_push: float = 260.0

var _last_dir: Vector2 = Vector2.RIGHT

func crowd_step(_dt: float) -> void:
	if crowd_manager == null or player_body == null or movement_controller == null:
		return

	# Derive player's speed (float) and direction (unit)
	var v: Vector2 = player_body.velocity
	var speed_a := v.length()

	var dir_a := _last_dir
	if speed_a > 0.001:
		dir_a = v / speed_a
		_last_dir = dir_a

	# Sum pushes from nearby CrowdAgents onto the player
	var total := Vector2.ZERO
	var neighbors := crowd_manager.get_neighbors(player_body.global_position, push_radius)

	for n in neighbors:
		if n == player_body:
			continue
		var other := n as CrowdAgent
		if other == null:
			continue

		total += PushSolver2D.compute_push_on_a(
			player_body.global_position,
			speed_a,
			dir_a,
			other.global_position,
			other._speed,
			other._heading,
			push_radius,
			max_side_push,
			push_falloff_exp,
			0.65,          # side_bias (match your solver defaults)
			0.3            # min_speed_factor
		)

	total = total.limit_length(max_total_push)

	# Write into player's movement controller
	if total.length_squared() > 0.0001:
		movement_controller.push_direction = total.normalized()
		movement_controller.push_force = total.length()
	else:
		movement_controller.push_direction = Vector2.ZERO
		movement_controller.push_force = 0.0
