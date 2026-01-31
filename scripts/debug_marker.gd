extends Node2D

func setup(pos: Vector2, is_valid: bool):
	global_position = pos
	# We store the color in a variable, but we need to tell _draw() to use it
	modulate = Color.GREEN if is_valid else Color.RED	

func _draw():
	# Draw a larger circle so it's visible (radius 15)
	# Using Color.WHITE here because 'modulate' handles the Green/Red tinting
	draw_circle(Vector2.ZERO, 15, Color.WHITE)
