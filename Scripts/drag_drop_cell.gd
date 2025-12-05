class_name DragDropCell extends Button


signal dragged(from: Vector2i, to: Vector2i)


var grid_pos: Vector2i
 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# Called when starting to drag
func _get_drag_data(_at_position: Vector2) -> Variant:
	# Can't drag empty cell
	if not icon:
		return null
	# Set drag-&-drop preview icon
	var preview: TextureRect = TextureRect.new()
	preview.texture = icon
	set_drag_preview(preview)
	return self


# Called when dragging over this cell
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Only allow drops from other cells
	if not data is DragDropCell or data == self:
		return false
	# Grab focus to set button theme
	grab_focus()
	return true


# Called when releasing mouse if _can_drop_data returned true
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# Swap icons between this cell and the source cell (data)
	var temp: Texture2D = icon
	icon = data.icon
	data.icon = temp
	dragged.emit(data.grid_position, self.grid_position)
