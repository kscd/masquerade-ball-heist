extends Node

@export var value = 10000
@export var pickup_delay = 1.0

@onready var timer = %Timer

var is_collected = false

func _ready() -> void:
	timer.wait_time = pickup_delay

func collect():
	GameState.round_score += value
		
	is_collected = true
	
	var parent = get_parent()
	parent.visible = false
	parent.set_deferred("monitoring", false)
	parent.set_deferred("monitorable", false)
	
	parent.queue_free()

func _on_collectible_body_entered(body: Node2D) -> void:
	timer.start()

func _on_collectible_body_exited(body: Node2D) -> void:
	timer.stop()

func _on_timer_timeout() -> void:
	collect()
