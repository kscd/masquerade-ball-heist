extends Node

class_name Player

enum State { MENU, PLAYING }
var current_state

var is_first_player_turn
var round_score
var player_score_0
var player_score_1
const max_lives = 10
var current_lives

func resetState():
	is_first_player_turn = true
	round_score = 0
	player_score_0 = 0
	player_score_1 = 0
	current_lives = max_lives
	
func switch_to_level():
	current_state = State.PLAYING
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func switch_to_menu():
	current_state = State.MENU
	get_tree().change_scene_to_file("res://scenes/main_menu/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.object_clicked.connect(_on_cursor_mouse_event)
	resetState()
	print("Gamestate loaded 💫")

func _on_cursor_mouse_event(hit):
	print("HIT 📍 ", hit)
	if hit.is_in_group("player"):
		print("win")
	else:
		current_lives = current_lives - 1
		if current_lives <= 0:
			print("lose")
			# TODO: Add player switch Scene
		else:
			GameEvents.lives_changed.emit(current_lives)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
