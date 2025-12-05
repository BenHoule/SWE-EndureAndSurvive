extends Control

signal finished(success: bool)

# Constants
const TINDER: int = 3
const KINDLING: int = 2
const FUEL: int = 1

# In-Scene Nodes
@onready var itemList: ItemList = $miniGameContainer/ItemList
@onready var buildAnimation: AnimatedSprite2D = $miniGameContainer/fireBuildingContainer/buildAnimation
@onready var instructionDisplay: Label = $miniGameContainer/Instructions
@onready var feedbackDisplay: Label = $miniGameContainer/Feedback
@onready var stickySprite: Area2D = $Stick
@onready var dropSpot: Area2D = $miniGameContainer/fireBuildingContainer/DropSpot

# Textures
var tinderPileTexture: Texture2D = load("res://Animations/fire_building/Frame1.png")
var kindlingTexture: Texture2D = load("res://Assets/Wood_Sprites/wood_3.png")
var fuelTexture: Texture2D = load("res://Assets/Wood_Sprites/wood_4.png")

# Arrays
var countArr: Array[int] = [TINDER, KINDLING, FUEL]
var strArr: Array[String] = ["Tinder", "Kindling", "Fuel"]
var textureArr: Array[Texture] = [tinderPileTexture, kindlingTexture, fuelTexture]

# Primitive vars & enums
var can_drop: bool = false
var prev_index: int = 0
var prev_mouse_button: MouseButton = MOUSE_BUTTON_LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stickySprite.hide()
	for i in range(countArr.size()):
		itemList.set_item_text(i, strArr[i] + ("(%d)" % countArr[i]))


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
			add_wood_to_fire(prev_index)
	
	# Check for mini-game completion
	if Input.is_action_just_pressed("light_fire") and buildAnimation.frame >= 6:
		finished.emit(true)


func add_wood_to_fire(index: int) -> void:
	# Check if smaller resources have been placed
	for i in range(index):
		if countArr[i] > 0:
			feedbackDisplay.set_text("That's too large!")
			return
	
	# Update resource pool
	countArr[index] -= 1
	itemList.set_item_text(index, strArr[prev_index] + ("(%d)" % countArr[index]))
	if countArr[index] <= 0:
		# Disable empty resources
		itemList.set_item_disabled(index, true)
	
	# Update animations
	buildAnimation.frame += 1
	var frames: SpriteFrames = buildAnimation.sprite_frames
	var next_frame: int = buildAnimation.frame + 1
	if next_frame <= 6:
		dropSpot.get_child(0).texture = frames.get_frame_texture("default", next_frame)
	else:
		instructionDisplay.set_text("Press F to light the fire! (WIP)")


func _on_item_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	prev_index = index
	prev_mouse_button = mouse_button_index as MouseButton
	
	# Drag-&-drop handling
	stickySprite.get_child(0).texture = textureArr[index]
	stickySprite.position = get_viewport().get_mouse_position()
	stickySprite.show()

func _on_wood_enter_firepit(_area: Area2D) -> void:
	can_drop = true


func _on_wood_exit_firepit(_area: Area2D) -> void:
	can_drop = false
