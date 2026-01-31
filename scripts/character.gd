extends Node2D

@onready var head = $Head
@onready var body = $Body
@onready var legs = $Legs

@export var head_options: Array[Texture2D]
@export var body_options: Array[Texture2D]
@export var legs_options: Array[Texture2D]

func _ready():
	randomize_character()

func randomize_character():
	if head_options.size() > 0:
		head.texture = head_options.pick_random()
	if body_options.size() > 0:
		body.texture = body_options.pick_random()
	if legs_options.size() > 0:
		legs.texture = legs_options.pick_random()
