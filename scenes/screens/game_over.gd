extends Control

var can_continue: bool = false

@onready var score_player1_label = $CenterContainer/VBoxContainer/ScorePlayer1Label
@onready var score_player2_label = $CenterContainer/VBoxContainer/ScorePlayer2Label
@onready var message_label = $CenterContainer/VBoxContainer/MessageLabel

func _ready():
	hide()
	GameEvents.game_over.connect(_on_trigger_screen)

func _on_trigger_screen():
	show()
	score_player1_label.text = "Player 1: " + str(GameState.player_score_0) + " $"
	score_player2_label.text = "Player 2: " + str(GameState.player_score_1) + " $"
	
	show()
	get_tree().paused = true
	
	await get_tree().create_timer(0.5).timeout
	can_continue = true

func _input(event):
	if can_continue and (event is InputEventKey or event is InputEventMouseButton):
		if event.is_pressed():
			continue_game()

func continue_game():
	hide()
	GameState.restartGame()
