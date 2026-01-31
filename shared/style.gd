extends Node

const gold_normal = "#d4af37"
const gold_hover = "#ffdf00"
const gold_muted = "aa8c2c"
const maroon = "800000"
const black_cherry = "4d0000"
const dark_cream = "#c4b295"
const font_color_normal = gold_normal
const font_color_hover = gold_hover
const font_color_pressed = dark_cream
const font_size = 75
const border_width = 10

func get_normal_style(scale: float) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()

	style.bg_color = "#800000"
	style.border_color = gold_normal

	# Set border widths
	style.border_width_bottom = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_left = border_width

	# Set corner radius
	style.corner_radius_bottom_left = border_width
	style.corner_radius_bottom_right = border_width
	style.corner_radius_top_left = border_width
	style.corner_radius_top_right = border_width

	return style

func get_hover_style(scale: float) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()

	style.bg_color = maroon
	style.border_color = gold_hover

	# Set border widths
	style.border_width_bottom = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_left = border_width
	
	# Set corner radius
	style.corner_radius_bottom_left = border_width
	style.corner_radius_bottom_right = border_width
	style.corner_radius_top_left = border_width
	style.corner_radius_top_right = border_width
	
	style.shadow_size = 16
	style.shadow_color = Color(1.0, 0.84, 0.0, 0.4)

	return style

func get_pressed_style(scale: float) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	style.bg_color = black_cherry
	style.border_color = gold_muted
	
	# Set border widths
	style.border_width_bottom = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_left = border_width
	
	# Set corner radius
	style.corner_radius_bottom_left = border_width
	style.corner_radius_bottom_right = border_width
	style.corner_radius_top_left = border_width
	style.corner_radius_top_right = border_width
	
	style.content_margin_top = 15
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_offset = Vector2(0, 4)
	
	return style
