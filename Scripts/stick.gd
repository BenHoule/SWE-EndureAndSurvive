@tool
extends Area2D

@onready var sprite = $Sprite2D
const SPRITE_SIZE = 64
const COLUMNS = 3
enum Type {
	TINDER = 8,
	KINDLING = 2,
	FUEL = 3,
	ROTTING = 9,
	BUILDING = 0
}

@export var wood_type: Type = Type.TINDER:
	set(value):
		wood_type = value
		_set_wood_sprite(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _set_wood_sprite(value: Type) -> void:
	var x: int = (value % COLUMNS) * 64
	@warning_ignore("integer_division")
	var y: int = (value / COLUMNS) * 64
	get_child(0).region_rect = Rect2(x, y, 64, 64)
	
