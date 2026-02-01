# PushSolver2D.gd
extends RefCounted
class_name PushSolver2D

static func compute_push_on_a(
	pos_a: Vector2,
	speed_a: float,
	dir_a: Vector2,   # expected unit
	pos_b: Vector2,
	speed_b: float,
	dir_b: Vector2,   # expected unit
	radius: float,
	max_push: float,
	falloff_exp: float = 1.5,
	side_bias: float = 0.65,   # 0..1 (higher = more sideways, less "bounce")
	min_speed_factor: float = 0.3
) -> Vector2:
	var offset := pos_a - pos_b
	var dist := offset.length()

	if dist <= 0.001 or dist >= radius:
		return Vector2.ZERO

	# Direction from B -> A
	var n := offset / dist

	# 1) Proximity (0..1), stronger when closer
	var t := 1.0 - (dist / radius)
	var proximity := pow(t, falloff_exp)

	# Normalize directions defensively (in case they're slightly off)
	var db := dir_b
	if db.length_squared() > 0.0001:
		db = db.normalized()
	else:
		return Vector2.ZERO

	var da := dir_a
	if da.length_squared() > 0.0001:
		da = da.normalized()
	else:
		da = Vector2.ZERO

	# 2) Intent: is B moving toward A?
	# Use B's movement direction vs the vector toward A (which is -n from B's perspective)
	var toward := maxf(0.0, (-n).dot(db))  # 0..1

	# If B isn't heading into A, no push (prevents "magnetic" pushing)
	if toward <= 0.0:
		return Vector2.ZERO

	# 3) Direction bias: mostly sideways, slightly away
	var side := Vector2(-db.y, db.x)          # perpendicular to B's facing
	var side_sign := signf(side.dot(offset))  # pick the side A is on
	var sideways := side * side_sign

	var away_weight := 1.0 - side_bias
	var push_dir := (n * away_weight + sideways * side_bias)
	if push_dir.length_squared() < 0.0001:
		push_dir = n
	else:
		push_dir = push_dir.normalized()

	# 4) Speed factor: fast B pushes harder than A; clamp to keep some push even at similar speeds
	var rel_speed := maxf(speed_b - speed_a, 0.0)
	var speed_factor := clampf(rel_speed / max_push, min_speed_factor, 1.0)

	# Final strength
	var strength := max_push * proximity * toward * speed_factor
	return push_dir * strength
