extends Node2D

@export var font_resource: Font


const FONT_SIZE = 16
var viewport_size = 0
var matrix = []
var upd: int = 0
var move: float = 0
var columns: int = 0
var rows: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	columns = int(viewport_size.x / FONT_SIZE)
	rows = int(viewport_size.y / FONT_SIZE)-8

	# load font
	font_resource = load("res://font/CARBON-DROID.ttf")
	if not font_resource:
		push_error("Failed to load font resource")
		return
	
	# set up matrix
	matrix.clear()
	for f in range(columns):
		matrix.append([])
		for y in range(rows):
			if y == 0:
				randomize()
				var delay = randi() % 10  # Random delay for starting the fall
				matrix[f].append({"value": Vector2(randi() % 10, int(randi() % 11)), "delay": delay})
			else:
				# Randomize the initial "y" values slightly
				var random_y = int(randi() % 11) if randi() % 2 == 0 else 0
				matrix[f].append({"value": Vector2(0, random_y), "delay": 0})


func mtrx(columns: int, rows: int) -> void:
	for f in range(columns):
		# Skip columns with active delay
		if matrix[f][0]["delay"] > 0:
			matrix[f][0]["delay"] -= 1
			continue
		
		# Randomize whether a column updates this frame
		if randi() % 2 == 0:
			continue

		# Update the column
		if matrix[f][0]["value"].y > 0:
			matrix[f].insert(0, {"value": Vector2(matrix[f][0]["value"].x, matrix[f][0]["value"].y - 1), "delay": 0})
			matrix[f].remove_at(rows)
		elif matrix[f][0]["value"].y <= 0:
			matrix[f].insert(0, {"value": Vector2(randi() % 10, int(randi() % 11)), "delay": 0})
			matrix[f].remove_at(rows)

# called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if viewport_size != get_viewport_rect().size:
		_ready()
	
	move += delta
	if move > 0.15:
		mtrx(columns, rows)
		move = 0
	queue_redraw()

func _draw() -> void:
	if not font_resource:
		return

	for f in range(columns):
		for y in range(rows):
			var value = matrix[f][y]["value"]
			var col: Color
			if value.y == 10:
				col = Color("FUCHSIA", value.y * 0.8)
				#col = Color(1, 0.7, 1, value.y * 0.8)
			else:
				col = Color(1, 0, 0, value.y * 0.1)
			draw_string(
				font_resource,
				Vector2(f * 16, y * 16 + 16),
				str(value.x),
				-3,  # vertical alignment
				0,   # additional spacing
				FONT_SIZE,
				col
			)

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_title_pressed() -> void:
	get_tree().change_scene_to_file("res://screens/title/title.tscn")
