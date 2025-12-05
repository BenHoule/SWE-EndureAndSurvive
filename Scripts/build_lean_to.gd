extends Control

signal finished(success: bool)

# Constants
const TINDER: int = 3
const KINDLING: int = 2
const FUEL: int = 1

# In-Scene Nodes
@onready var itemList: ItemList = $miniGameContainer/ItemList
@onready var buildAnimation: AnimatedSprite2D = $miniGameContainer/leanToBuildingContainer/buildAnimation
@onready var instructionDisplay: Label = $miniGameContainer/Instructions
@onready var feedbackDisplay: Label = $miniGameContainer/Feedback
@onready var stickySprite: Area2D = $Stick
@onready var dropSpot: Area2D = $miniGameContainer/leanToBuildingContainer/DropSpot
@onready var frames: SpriteFrames = buildAnimation.sprite_frames

# Textures
var logTexture: Texture2D = load("res://Assets/Wood_Sprites/wood_1.png")

# Primitive vars & enums
var can_drop: bool = false
var log_count: int = 5
var cur_frame: int = 0
var prev_mouse_button: MouseButton = MOUSE_BUTTON_LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stickySprite.hide()
	itemList.set_item_text(0, "Logs (%d)" % log_count)
	dropSpot.get_child(0).texture = frames.get_frame_texture("default", 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Drag-and-drop handling: An invisible stick follows the cursor.
	# - Becomes visible when a resource is clicked
	if Input.is_mouse_button_pressed(prev_mouse_button):
		stickySprite.position = get_viewport().get_mouse_position()
	elif stickySprite.visible:
		# Hide when mouse button is released
		stickySprite.hide()
		if can_drop:
			_add_log_to_lean_to()
	
	# Check for mini-game completion
	if Input.is_action_just_pressed("light_fire"):
		match cur_frame:
			3, 4:
				itemList.set_item_disabled(0, false)
				instructionDisplay.set_text("Build a lean-to! (WIP)")
				dropSpot.get_child(0).texture = frames.get_frame_texture("default", cur_frame + 1)
			5:
				finished.emit(true)
			_:
				pass

func _add_log_to_lean_to() -> void:
	# Update resource pool
	log_count -= 1
	itemList.set_item_text(0, "Logs (%d)" % log_count)
	if log_count <= 0:
		# Disable empty resources
		itemList.set_item_disabled(0, true)
	
	# Update animations
	_update_build()

func _update_build() -> void:
	buildAnimation.frame += 1
	cur_frame = buildAnimation.frame
	if cur_frame < 3:
		dropSpot.get_child(0).texture = frames.get_frame_texture("default", cur_frame + 1)
	else:
		# Tie lashings for top logs (very educational and in-depth)
		instructionDisplay.set_text("Press F to tie a lashing! (WIP)")
		itemList.set_item_disabled(0, true)

func _on_item_list_item_clicked(_index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	prev_mouse_button = mouse_button_index as MouseButton
	
	# Drag-&-drop handling
	stickySprite.position = get_viewport().get_mouse_position()
	stickySprite.show()

func _on_wood_enter_drop_spot(_area: Area2D) -> void:
	can_drop = true


func _on_wood_exit_drop_spot(_area: Area2D) -> void:
	can_drop = false
