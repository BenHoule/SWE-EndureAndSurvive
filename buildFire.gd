extends Control

signal finished(success: bool)

@onready var itemList: ItemList = $miniGameContainer/ItemList
@onready var buildAnimation: AnimatedSprite2D = $miniGameContainer/fireBuildingContainer/buildAnimation
@onready var instructionDisplay: Label = $miniGameContainer/Instructions
@onready var feedbackDisplay: Label = $miniGameContainer/Feedback

var tinderCnt: int = 3
var kindlingCnt: int = 2
var fuelCnt: int = 1
var countArr: Array[int] = [tinderCnt, kindlingCnt, fuelCnt]
var strArr: Array[String] = ["Tinder", "Kindling", "Fuel"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(countArr.size()):
		itemList.set_item_text(i, strArr[i] + ("(%d)" % countArr[i]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("light_fire") and buildAnimation.frame >= 6:
		finished.emit(true)


func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	# Check if smaller resources have been placed
	for i in range(index):
		if countArr[i] > 0:
			feedbackDisplay.set_text("That's too large!")
			return
		
	countArr[index] -= 1
	itemList.set_item_text(index, strArr[index] + ("(%d)" % countArr[index]))
	if countArr[index] <= 0:
		itemList.set_item_disabled(index, true)
	
	if buildAnimation.frame < 5:
		buildAnimation.frame += 1
	elif buildAnimation.frame < 6:
		buildAnimation.frame += 1
		instructionDisplay.set_text("Press F to light the fire!")
