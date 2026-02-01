extends Node

class_name Player

enum State { MENU, PLAYING }
var current_state
enum Round_end_condition {SEEKER_NO_LIVES, THIEF_CAUGHT, THIEF_FLED}

var is_first_player_turn
var round_score
var player_score_0
var player_score_1
const winning_score = 25000
const max_lives = 10
var current_lives

func resetState():
	is_first_player_turn = true
	round_score = 0
	player_score_0 = 0
	player_score_1 = 0
	current_lives = max_lives
	
func nextRound():
	is_first_player_turn = !is_first_player_turn
	round_score = 0
	current_lives = max_lives
	
func switch_to_level():
	current_state = State.PLAYING
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func switch_to_menu():
	current_state = State.MENU
	get_tree().change_scene_to_file("res://scenes/main_menu/main.tscn")
	
func switch_to_round_over(condition: Round_end_condition):
	GameEvents.round_over.emit(condition)
	if condition == Round_end_condition.THIEF_FLED or condition == Round_end_condition.SEEKER_NO_LIVES:
		if is_first_player_turn:
			player_score_0 += round_score
		else:
			player_score_1 += round_score
	if player_score_0 >= winning_score || player_score_1 >= winning_score:
		switch_to_game_over()

func switch_to_game_over():
	GameEvents.game_over.emit()
	print("game over")

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.object_clicked.connect(_on_cursor_mouse_event)
	resetState()
	print("Gamestate loaded 💫")

func _on_cursor_mouse_event(hit):
	print("HIT 📍 ", hit)
	if hit.is_in_group("player"):
		switch_to_round_over(Round_end_condition.THIEF_CAUGHT)
	if hit.is_in_group("npc"):
		current_lives = current_lives - 1
		if current_lives <= 0:
			switch_to_round_over(Round_end_condition.SEEKER_NO_LIVES)
		if current_lives > -1:
			GameEvents.lives_changed.emit(current_lives)
