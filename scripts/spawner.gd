extends Node2D

@export var spawn_count: int = 5
@export var max_attempts_per_entity: int = 15
@export var spawn_poly: Polygon2D  # Assign your Polygon2D here

@onready var shape_cast: ShapeCast2D = %ShapeCast2D
@onready var crowd_manager = $"../CrowdManager"

func _ready() -> void:
	if spawn_poly == null:
		push_error("Please assign a Polygon2D to the spawn_poly variable.")
		return
		
	shape_cast.target_position = Vector2.ZERO
	
	# Wait for physics to settle
	await get_tree().physics_frame
	spawn_multiple_entities(spawn_count)

func spawn_multiple_entities(count: int):
	for i in range(count):
		spawn_single_entity()

func spawn_single_entity():
	var valid_spot := false
	var final_pos := Vector2.ZERO

	# Build polygon points in GLOBAL space (includes node transform AND Polygon2D.offset)
	var poly_global := get_polygon_global_points(spawn_poly)

	# Bounding box in GLOBAL space
	var bounds := get_polygon_bounds(poly_global)

	for i in range(max_attempts_per_entity):
		# Pick random point in GLOBAL bounding box
		var test_pos_global := Vector2(
			randf_range(bounds.position.x, bounds.end.x),
			randf_range(bounds.position.y, bounds.end.y)
		)

		# Check if inside GLOBAL polygon
		if Geometry2D.is_point_in_polygon(test_pos_global, poly_global):
			# Physics overlap check
			shape_cast.global_position = test_pos_global
			shape_cast.force_shapecast_update()

			if not shape_cast.is_colliding():
				final_pos = test_pos_global
				valid_spot = true
				break

	if valid_spot:
		var entity = preload("res://scenes/crowd_agent.tscn").instantiate()
		entity.add_to_group("npc")
		crowd_manager.add_child(entity)
		entity.global_position = final_pos

		if crowd_manager:
			crowd_manager.insert_agent(entity, final_pos)
	else:
		print("Failed to find empty spot in polygon.")

# Helper function to find the square area around the polygon
func get_polygon_global_points(poly: Polygon2D) -> PackedVector2Array:
	var out := PackedVector2Array()
	var off := poly.offset  # IMPORTANT
	for p in poly.polygon:
		out.append(poly.to_global(p + off))
	return out

func get_polygon_bounds(poly_points: PackedVector2Array) -> Rect2:
	if poly_points.size() == 0:
		return Rect2()

	var min_v := poly_points[0]
	var max_v := poly_points[0]

	for p in poly_points:
		min_v.x = min(min_v.x, p.x)
		min_v.y = min(min_v.y, p.y)
		max_v.x = max(max_v.x, p.x)
		max_v.y = max(max_v.y, p.y)

	return Rect2(min_v, max_v - min_v)
