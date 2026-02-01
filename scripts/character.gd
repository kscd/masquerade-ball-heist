extends Node2D

@onready var head = $Head
@onready var body = $Body
@onready var legs = $Legs

@export var head_options: Array[Texture2D]
@export var body_options: Array[Texture2D]
@export var legs_options: Array[Texture2D]


@export var min_scale: float = 0.8
@export var max_scale: float = 1.1

func _process(_delta):
	# Get the current height of the game window
	var screen_height = get_viewport_rect().size.y
	
	# Map position (0 to screen_height) to scale (min to max)
	var scale_factor = remap(global_position.y, 0, screen_height, max_scale, min_scale)
	
	# Keep it within your defined limits
	scale_factor = clamp(scale_factor, min_scale, max_scale)
	
	# Apply scaling
	scale = Vector2(1, scale_factor)

func _ready():
	randomize_character()

func randomize_character():
	if head_options.size() > 0:
		head.texture = head_options.pick_random()
	if body_options.size() > 0:
		body.texture = body_options.pick_random()
	if legs_options.size() > 0:
		legs.texture = legs_options.pick_random()
