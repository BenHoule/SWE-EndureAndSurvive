extends Node2D

@onready var timer: Timer = $Timer
@onready var timerDisplay: Label = $Viewport/HUD/TimerContainer/Timer
var timerString: String = "Time: %.1f"

@onready var coordDisplay: Label = $Viewport/HUD/CoordsContainer/Coords

@onready var red_check: Sprite2D = $RedCheck
@onready var direction_message: Label = $Viewport/HUD/DirectionMessage
@onready var player: CharacterBody2D = $Player
@onready var red_check_2: Sprite2D = $RedCheck2
@onready var win_menu_controller: Control = $Viewport/winMenuController
@onready var lose_menu_controller: Control = $Viewport/loseMenuController

var nextLevel: String = "res://Scenes/Main-Menu.tscn"
var levelComplete: bool = false 

var target_positions: Array[Vector2] = [
	Vector2(-400, -150),
	Vector2(165, 230)
]

var current_target_index: int = 0

const ARRIVAL_DISTANCE := 16.0
const DEAD_ZONE := 10.0


func _ready() -> void:
	red_check.hide()
	red_check_2.hide()
	win_menu_controller.hide()
	lose_menu_controller.hide()

func _process(delta: float) -> void:
	timerDisplay.set_text(timerString % timer.time_left)

	_update_direction_message()
	
	if(timer.time_left <= 0):
		lose_menu_controller.show()


func _update_direction_message() -> void:
	if player == null or direction_message == null:
		return

	if current_target_index >= target_positions.size():
		direction_message.hide()
		return

	var target_position: Vector2 = target_positions[current_target_index]
	var to_target: Vector2 = target_position - player.global_position

	# Arrived at current target
	if to_target.length() <= ARRIVAL_DISTANCE:
		current_target_index += 1

		# If there is another target
		if current_target_index < target_positions.size():
			red_check.show()
		else:
			red_check_2.show()
			levelComplete = true
			win_menu_controller.show()
			global_game_data.mark_level_complete("orienteer")
			timer.stop()
		return

	direction_message.text = _get_direction_text(to_target)


func _get_direction_text(to_target: Vector2) -> String:
	var dx = to_target.x
	var dy = to_target.y

	# Cardinal Directions
	if abs(dx) <= DEAD_ZONE and dy < -DEAD_ZONE:
		return "Go north"
	if abs(dx) <= DEAD_ZONE and dy > DEAD_ZONE:
		return "Go south"
	if abs(dy) <= DEAD_ZONE and dx > DEAD_ZONE:
		return "Go east"
	if abs(dy) <= DEAD_ZONE and dx < -DEAD_ZONE:
		return "Go west"

	# Diagonals
	if dx > DEAD_ZONE and dy < -DEAD_ZONE:
		return "Go northeast"
	if dx < -DEAD_ZONE and dy < -DEAD_ZONE:
		return "Go northwest"
	if dx > DEAD_ZONE and dy > DEAD_ZONE:
		return "Go southeast"
	if dx < -DEAD_ZONE and dy > DEAD_ZONE:
		return "Go southwest"

	return "Almost there..."
