extends Area2D

@export var value = 10000

func _on_body_entered(body):
	print("entered")
	if body.is_in_group("player"):
		collect(body)
		
func collect(player):
	print("player hit")
	player.collect(value)


func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
