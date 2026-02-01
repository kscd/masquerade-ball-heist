extends Panel

var showcase_ref: Node2D

@onready var countdown_label = $MarginContainer/VBoxContainer/LabelCountdown
@onready var game = %Game
@onready var player = game.player

func _ready() -> void:
	var tween = create_tween()

	tween.tween_method(update_countdown_text, 10.0, 0.0, 10.0)

func update_countdown_text(value: float) -> void:
	countdown_label.text = str(int(ceil(value)))
