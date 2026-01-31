extends Node2D # or Node2D

@onready var p0_bar = $Player1Bar
@onready var p1_bar = $Player2Bar
@onready var p0_label = $Player1Bar/Label
@onready var p1_label = $Player2Bar/Label

@export var score_0: int
@export var score_1: int
@export var time_phase_1: float = 5.0
@export var time_phase_2: float = 1.0
@export_range(0.0, 1.0) var time_phase_0_variance: float = 0.5

@export var confetti: CPUParticles2D

func _ready():
	print("--- DEBUGGING ---")
	print("Children of Player1Bar are:", $Player1Bar.get_children())
	print("-----------------")
	# Force bars to be visible and have a size (Fixes invisible UI issues)
	p0_bar.visible = true
	p1_bar.visible = true
	p0_bar.custom_minimum_size = Vector2(1000, 50) # Force a size
	p1_bar.custom_minimum_size = Vector2(1000, 50)
	
	p0_bar.show_percentage = false
	p1_bar.show_percentage = false
	
	setup_centered_label(p0_label)
	setup_centered_label(p1_label)
	
	# Run animation
	animate_bars()

# This function runs every single frame
func _process(_delta):
	# Constantly update the text to match the animating bar value
	update_labels()

func update_labels():
	p0_label.text = str(int(p0_bar.value))
	p1_label.text = str(int(p1_bar.value))
	
# Helper function to center a label text
func setup_centered_label(lbl: Label):
	if lbl:
		# Fill the parent (the bar)
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		# Center the text inside that space
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func animate_bars():
	# Reset bars
	p0_bar.value = 0
	p1_bar.value = 0
	p0_bar.max_value = max(score_0, score_1)
	p1_bar.max_value = max(score_0, score_1)
	
	# Randomize duration between (Base - Variance) and (Base + Variance)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var time_phase_1_score_0 = time_phase_1 + rng.randf_range(-time_phase_0_variance, time_phase_0_variance)
	var time_phase_1_score_1 = time_phase_1 + rng.randf_range(-time_phase_0_variance, time_phase_0_variance)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# --- PHASE 1: Both bars grow together ---
	tween.set_parallel(true)
	if score_0 > score_1:
		tween.tween_property(p0_bar, "value", min(score_0, score_1), time_phase_1_score_0)
		tween.tween_property(p1_bar, "value", min(score_0, score_1), time_phase_1_score_1)
	else:
		tween.tween_property(p0_bar, "value", min(score_0, score_1), time_phase_1_score_0)
		tween.tween_property(p1_bar, "value", min(score_0, score_1), time_phase_1_score_1)
	
	var winner_bar
	# --- PHASE 2: Wait, then continue Player ---
	if score_0 >= score_1:
		tween.chain().tween_property(p0_bar, "value", score_0, time_phase_2)
		winner_bar = p0_bar
	else:
		tween.chain().tween_property(p1_bar, "value", score_1, time_phase_2)
		winner_bar = p1_bar
		
		# --- PHASE 3: EXPLOSION ---
	# tween.callback() lets us run a function when the animation finishes
	if winner_bar and confetti:
		tween.tween_callback(func():
			# Move confetti to the winner's bar
			confetti.global_position = winner_bar.global_position + (winner_bar.size / 2)
			# BOOM!
			confetti.emitting = true
		)
