extends Panel

@onready var countdown_label = $MarginContainer/VBoxContainer/LabelCountdown
@onready var game = %Game

var countdown_value : float = 10.0

func _ready() -> void:
	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_method(update_countdown_text, 10.0, 0.0, 10.0)

	tween.tween_property(game, "modulate:a", 1.0, 2.0).set_delay(7.0)

	tween.chain().tween_callback(queue_free)

func update_countdown_text(value: float) -> void:
	countdown_label.text = str(int(ceil(value)))
