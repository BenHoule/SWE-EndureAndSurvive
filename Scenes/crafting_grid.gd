class_name CraftingGrid extends GridContainer

# Emitted when drag is completed by child nodes
signal dragged(from: Vector2i, to: Vector2i)

var _cells: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize cell array
	for x in columns:
		_cells.append([])
	var row: int = 0
	var column: int = 0
	for cell in get_children():
		_cells[column].append(cell)
		cell.grid_position = Vector2i(column, row)
		cell.dragged.connect(dragged.emit)
		column += 1
		if column >= columns:
			column = 0
			row += 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
