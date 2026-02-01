extends Control

var can_continue: bool = false

@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var message_label = $CenterContainer/VBoxContainer/MessageLabel

func _ready():
	hide()
	GameEvents.round_over.connect(_on_trigger_screen)

func _on_trigger_screen(condition: Player.Round_end_condition):
	match condition:
		Player.Round_end_condition.SEEKER_NO_LIVES:
			message_label.text = "The seeker has no tries left. The thief escaped with:"
			score_label.text = str(GameState.round_score) + "$"
		Player.Round_end_condition.THIEF_FLED:
			message_label.text = "The thief escaped with:"
			score_label.text = str(GameState.round_score) + "$"
		Player.Round_end_condition.THIEF_CAUGHT:
			message_label.text = "The thief was caught. Nothing of value was stolen."
			score_label.text = ""
	show()
	get_tree().paused = true
	
	await get_tree().create_timer(0.5).timeout
	can_continue = true
	print(can_continue)

func _input(event):
	if can_continue and (event is InputEventKey or event is InputEventMouseButton):
		if event.is_pressed():
			continue_game()

func continue_game():
	GameState.nextRound()
	get_tree().paused = false
	get_tree().reload_current_scene()
