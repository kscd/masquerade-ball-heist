extends Area2D

@export var delay: float = 0.5

@onready var timer = $Timer

func _ready() -> void:
	timer.wait_time = delay

func complete_round():
	set_deferred("monitoring", false)
	GameState.switch_to_round_over(Player.Round_end_condition.THIEF_FLED)

func _on_exit_body_entered(body: Node2D) -> void:
	print("player in exit")
	timer.start()

func _on_exit_body_exited(body: Node2D) -> void:
	timer.stop()

func _on_timer_timeout() -> void:
	print("round over")
	complete_round()
