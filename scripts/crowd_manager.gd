# CrowdManager2D.gd (Godot 4.x)
extends Node2D
class_name CrowdManager

@export var cell_size: float = 64.0  # pixels; ~2–4x agent radius
var _grid: Dictionary = {}           # Dictionary: Vector2i -> Array[CrowdAgent2D]

func clear_grid() -> void:
	_grid.clear()

func _cell_of(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / cell_size), floori(pos.y / cell_size))

func insert_agent(agent: Node2D, pos: Vector2) -> void:
	var c := _cell_of(pos)
	if not _grid.has(c):
		_grid[c] = []
	_grid[c].append(agent)

func get_neighbors(pos: Vector2, radius: float) -> Array:
	var result: Array = []
	var c := _cell_of(pos)
	var r_cells := int(ceil(radius / cell_size))

	for dx in range(-r_cells, r_cells + 1):
		for dy in range(-r_cells, r_cells + 1):
			var cc := Vector2i(c.x + dx, c.y + dy)
			if _grid.has(cc):
				result.append_array(_grid[cc])

	return result

func _physics_process(dt: float) -> void:
	clear_grid()

	# 1) Build grid
	for child in get_children():
		if child is CrowdAgent:
			(child as CrowdAgent).register_in_grid()

	# 2) Step agents
	for child in get_children():
		if child is CrowdAgent:
			(child as CrowdAgent).physics_step(dt)
