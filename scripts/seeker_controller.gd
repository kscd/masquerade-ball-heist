extends Node2D

signal object_clicked(object_node)

func _ready():
	object_clicked.connect(Gamestate._on_cursor_mouse_event)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var hit = get_object_under_mouse()
			if hit:
				object_clicked.emit(hit)
				print("Clicked on: ", hit.name)

func get_object_under_mouse():
	var space_state = get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()
	
	# Setup the query
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true  # Detects Area2Ds
	query.collide_with_bodies = true # Detects Static/Rigid/CharacterBodies
	
	var results = space_state.intersect_point(query)
	
	if results:
		if results.size() > 1:
			# Sort by Z-Index so the "highest" object is first
			results.sort_custom(func(a, b): 
				return a.collider.z_index > b.collider.z_index
			)
		return results[0].collider
		
	return null
