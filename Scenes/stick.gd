extends Area2D

@onready var sprite = $Sprite2D
const SPRITE_SIZE = 64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_sprite_tile(index: int):
	var _x: int = (index % 3) * SPRITE_SIZE
	var _y: int = (index / 3) * SPRITE_SIZE
	sprite.region_rect = Rect2(_x, _y, SPRITE_SIZE, SPRITE_SIZE)
