# CrowdAgent2D.gd (Godot 4.x)
extends CharacterBody2D
class_name CrowdAgent

@export var max_sight: float = 600.0         # px
@export var sample_count: int = 10           # 8–12
@export var repick_interval: float = 3.0     # seconds, staggered
@export var reach_dist: float = 16.0         # px

@export var neighbor_radius: float = 100    # px (personal space)
@export var neighbor_weight: float = 5
@export var forward_avoid_dist: float = 48.0 # px
@export var avoid_weight: float = 2.0

@export var idle_chance_per_second: float = 0.1 # ~ once every 15–20s on avg
@export var idle_time_min: float = 1.0
@export var idle_time_max: float = 6.0

@export var dir_commit_min: float = 0.35     # seconds: minimum time to keep a direction
@export var dir_commit_max: float = 0.9      # seconds: adds variety
@export var dir_noise_deg: float = 10.0      # randomness in direction decision (degrees)
@export var switch_hysteresis: float = 0.15  # 0..1: higher = less switching

@export var push_radius: float = 400.0
@export var push_forward_ratio: float = 0.20
@export var push_falloff_exp: float = 1.2
@export var max_total_push: float = 26000.0

@export var obstacle_mask: int = 1         # collision mask bits for walls

var _mgr: CrowdManager

var _target: Vector2
var _has_target := false
var _repick_timer: float = 0.0
var _stuck_timer: float = 0.0
var _last_pos: Vector2
var _is_idle: bool = false
var _idle_timer: float = 0.0
var _committed_dir: Vector2 = Vector2.ZERO
var _commit_timer: float = 0.0

func _ready() -> void:
	_mgr = get_parent() as CrowdManager
	_repick_timer = randf_range(0.0, repick_interval) # stagger
	_last_pos = global_position

func register_in_grid() -> void:
	if _mgr:
		_mgr.insert_agent(self, global_position)

func physics_step(dt: float) -> void:
	_maybe_start_idle(dt)

	# Always compute push (even while idling)
	var push_vec := PushSolver2D._compute_total_push_vector(_mgr, self, push_radius, max_total_push, push_falloff_exp, push_forward_ratio)
	if push_vec.length_squared() > 0.0001:
		%MovementController.push_direction = push_vec.normalized()
		%MovementController.push_force = push_vec.length()
	else:
		%MovementController.push_direction = Vector2.ZERO
		%MovementController.push_force = 0.0

	# If idling: don't do AI steering, but still allow push to move us
	if _update_idle(dt):
		%MovementController.input_direction = Vector2.ZERO
		return
	_repick_timer -= dt


	# Stuck detection
	var moved := global_position.distance_to(_last_pos)
	_last_pos = global_position
	if moved < 1.0 and velocity.length() > 10.0:
		_stuck_timer += dt
	else:
		_stuck_timer = maxf(_stuck_timer - dt * 2.0, 0.0)

	# Re-pick target conditions
	if (not _has_target) \
	or (global_position.distance_to(_target) < reach_dist) \
	or (_stuck_timer > 0.6) \
	or (_repick_timer <= 0.0):
		_pick_target()
		_repick_timer = repick_interval + randf_range(-0.2, 0.2)
		_stuck_timer = 0.0

	# Desired direction toward target
	var desired_dir := (_target - global_position)
	if desired_dir.length_squared() > 0.0001:
		desired_dir = desired_dir.normalized()
	else:
		desired_dir = velocity.normalized()

	# Neighbor avoidance (direction-only)
	desired_dir = _apply_neighbor_avoidance(desired_dir)

	# Obstacle avoidance (short rays)
	desired_dir = _apply_obstacle_avoidance(desired_dir)
	
	_commit_timer = maxf(_commit_timer - dt, 0.0)

# If we are allowed to change direction (timer expired), decide a new one
	if _commit_timer <= 0.0:
		var candidate := _choose_snapped_dir_with_noise(desired_dir)	
		# Hysteresis: don't switch for tiny improvements / borderline angles
		if _committed_dir == Vector2.ZERO:
			_committed_dir = candidate
			_commit_timer = _pick_commit_time()
		else:
			# Compare how well each direction matches the *unsnapped* desired direction
			var current_score := desired_dir.dot(_committed_dir)
			var cand_score := desired_dir.dot(candidate)

			# Only switch if it's meaningfully better
			if cand_score > current_score + switch_hysteresis:
				_committed_dir = candidate
				_commit_timer = _pick_commit_time()

# If we have basically reached the target, stop (and allow direction to change next time)
	if global_position.distance_to(_target) < reach_dist:
		_committed_dir = Vector2.ZERO
		_commit_timer = 0.0
		%MovementController.input_direction = Vector2.ZERO
	else:
		%MovementController.input_direction = _committed_dir

func _pick_target() -> void:
	# Picks a random target point anywhere within max_sight,
	# but only if it's in direct line-of-sight (ray hits no obstacle).

	var min_dist := 32.0
	var max_dist := max_sight
	var attempts := 20

	var best_score := -INF
	var best_point := global_position

	for _i in range(attempts):
		# Random direction and distance (uniform angle, and sqrt for more uniform area distribution)
		var ang := randf_range(-PI, PI)
		var r := sqrt(randf_range(0.0, 1.0)) * (max_dist - min_dist) + min_dist
		var candidate := global_position + Vector2.RIGHT.rotated(ang) * r

		# Check line-of-sight to the candidate
		if not _has_line_of_sight(candidate):
			continue

		# Score: prefer farther points a bit (reduces jittery micro-moves)
		# Add a tiny random jitter so crowds don't synchronize
		var score := global_position.distance_to(candidate) + randf_range(-10.0, 10.0)

		if score > best_score:
			best_score = score
			best_point = candidate

	# Fallback: if nothing valid found, at least pick something in the clearest direction
	if best_score == -INF:
		best_point = _fallback_target_point(min_dist, max_dist)

	_target = best_point
	_has_target = true

func _has_line_of_sight(point: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.create(global_position, point)
	q.exclude = [self]
	q.collision_mask = obstacle_mask

	var hit := space.intersect_ray(q)
	return hit.is_empty()
	
func _fallback_target_point(min_dist: float, max_dist: float) -> Vector2:
	# Probe 8 directions; pick the one with most free distance and go partway.
	var dirs := [
		Vector2.RIGHT,
		Vector2(1, -1).normalized(),
		Vector2.UP,
		Vector2(-1, -1).normalized(),
		Vector2.LEFT,
		Vector2(-1, 1).normalized(),
		Vector2.DOWN,
		Vector2(1, 1).normalized(),
	]

	var best_free := -INF
	var best_dir := Vector2.DOWN

	for d in dirs:
		var free_dist := _ray_free_distance(d, max_dist)
		if free_dist > best_free:
			best_free = free_dist
			best_dir = d

	var dmove := clampf(best_free * 0.8, min_dist, max_dist)
	return global_position + best_dir * dmove	

func _ray_free_distance(dir: Vector2, dist: float) -> float:
	var space := get_world_2d().direct_space_state
	var from := global_position
	var to := from + dir * dist

	var q := PhysicsRayQueryParameters2D.create(from, to)
	q.exclude = [self]
	q.collision_mask = obstacle_mask

	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return dist
	return maxf(16.0, from.distance_to(hit.position))

func _apply_neighbor_avoidance(desired_dir: Vector2) -> Vector2:
	if _mgr == null:
		return desired_dir

	var neighbors := _mgr.get_neighbors(global_position, neighbor_radius)
	if neighbors.is_empty():
		return desired_dir

	var push := Vector2.ZERO
	var p := global_position

	for n in neighbors:
		if n == self:
			continue
		var np := (n as Node2D).global_position
		var d := p.distance_to(np)
		if d <= 0.001 or d > neighbor_radius:
			continue

		var away := (p - np).normalized()

		# Stronger push if the neighbor is in front of us (more natural)
		var in_front := velocity.normalized().dot((np - p).normalized()) # 1 = ahead
		var front_factor := clampf((in_front + 0.2) / 1.2, 0.0, 1.0)

		var strength := (neighbor_radius - d) / d
		push += away * strength * front_factor

	if push.length_squared() > 0.0001:
		return (desired_dir + push.normalized() * neighbor_weight).normalized()

	return desired_dir

func _apply_obstacle_avoidance(desired_dir: Vector2) -> Vector2:
	var forward_clear := _ray_free_distance(desired_dir, forward_avoid_dist)
	if forward_clear >= forward_avoid_dist - 2.0:
		return desired_dir

	# Try directions aligned with 8-way snapping
	var dirs := [
		desired_dir,
		desired_dir.rotated(deg_to_rad(45.0)),
		desired_dir.rotated(deg_to_rad(-45.0)),
		desired_dir.rotated(deg_to_rad(90.0)),
		desired_dir.rotated(deg_to_rad(-90.0)),
	]

	var best_dir := desired_dir
	var best_clear := forward_clear

	for d in dirs:
		var c := _ray_free_distance(d.normalized(), forward_avoid_dist)
		if c > best_clear:
			best_clear = c
			best_dir = d.normalized()

	# Blend so it doesn't jitter
	return (desired_dir + best_dir * avoid_weight).normalized()
	
func _quantize_to_8(dir: Vector2) -> Vector2:
	# Returns the nearest of 8 unit directions.
	# If dir is too small, returns Vector2.ZERO.
	if dir.length_squared() < 0.0001:
		return Vector2.ZERO

	var angle := dir.angle() # -PI..PI
	var step := TAU / 8.0    # 45 degrees
	var snapped := step * float(round(angle / step))
	return Vector2.RIGHT.rotated(snapped).normalized()
	
func _maybe_start_idle(dt: float) -> void:
	if _is_idle:
		return
	# Probability per frame based on per-second chance
	if randf() < idle_chance_per_second * dt:
		_is_idle = true
		_idle_timer = randf_range(idle_time_min, idle_time_max)
		# Optional: clear target so they choose a new one after idling
		_has_target = false
		
func _update_idle(dt: float) -> bool:
	# Returns true if we are currently idling and should skip movement logic.
	if not _is_idle:
		return false

	_idle_timer -= dt
	%MovementController.input_direction = Vector2.ZERO

	if _idle_timer <= 0.0:
		_is_idle = false
		# when resuming, force a repick soon
		_repick_timer = 0.0

	return true

func _choose_snapped_dir_with_noise(desired_dir: Vector2) -> Vector2:
	# Add a small random angular noise BEFORE snapping (only used when choosing)
	if desired_dir.length_squared() < 0.0001:
		return Vector2.ZERO

	var noisy := desired_dir.rotated(deg_to_rad(randf_range(-dir_noise_deg, dir_noise_deg)))
	return _quantize_to_8(noisy)

func _pick_commit_time() -> float:
	return randf_range(dir_commit_min, dir_commit_max)
