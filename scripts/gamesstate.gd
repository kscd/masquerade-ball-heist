extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Gamestate loaded 💫")

# func _on_cursor_object_clicked():
# 	print("Handle click in state")

func _on_cursor_mouse_event(hit):
	print("HIT 📍 ", hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
