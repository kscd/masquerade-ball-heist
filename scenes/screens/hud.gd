extends CanvasLayer

@export var heart_texture: Texture2D

@onready var container = $LivesContainer/HBoxContainer

func _ready() -> void:
	GameEvents.lives_changed.connect(update_hearts)
	setup_lives(GameState.max_lives)
	
func setup_lives(max_lives: int) -> void:
	for child in container.get_children():
		child.queue_free()
	
	for i in range(max_lives):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.custom_minimum_size = Vector2(40, 40)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(heart)

func show_lives(new_lives_count: int):
	var tween = create_tween()
	
	tween.tween_property($LivesContainer, "modulate:a", 1.0, 0.3)
	
	var hearts = container.get_children()
	if new_lives_count < hearts.size():
		var lost_heart = hearts[new_lives_count]
		tween.tween_property(lost_heart, "modulate:a", 0.2, 0.1)
	
	tween.tween_interval(0.4)
	
	tween.tween_property($LivesContainer, "modulate:a", 0.0, 0.5)

func update_hearts(current_lives: int):
	show_lives(current_lives)
