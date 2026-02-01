extends Node2D

@onready var player = $Player
@onready var overlay = $BlackOverlay

func _ready() -> void:
	start_intro_sequence()

func start_intro_sequence():
	# 1. Prepare the stage
	overlay.show()
	overlay.modulate.a = 1.0 # Fully black
	
	# The Player stays visible but hidden behind the black box initially
	player.visible = true

	# 2. Start the Tween
	var tween = create_tween()
	tween.set_parallel(true)

	# At 5 seconds: Move player in front of the black box
	tween.tween_callback(reveal_player).set_delay(5.0)

	# At 9 seconds: Fade the black box out
	tween.tween_property(overlay, "modulate:a", 0.0, 1.0).set_delay(9.0)

	# At 10 seconds: Cleanup
	tween.chain().tween_callback(finish_intro)

func reveal_player():
	# Move player's Z-Index to be higher than the overlay
	player.z_index = 100
	# Optional: Add a little "pop" effect
	var t = create_tween()
	t.tween_property(player, "scale", player.scale * 1.2, 0.1)
	t.tween_property(player, "scale", player.scale, 0.1)

func finish_intro():
	player.z_index = 0 # Reset to normal game depth
	overlay.hide()

func set_world_visibility(is_visible: bool):
	for child in get_children():
		# Don't hide the player, the overlay, or the camera
		if child != player and child != overlay and not child is Camera2D:
			child.visible = is_visible
