extends Node2D

@onready var timer: Timer = $Timer
@onready var timerDisplay: Label = $Viewport/HUD/TimerContainer/Timer
var timerString: String = "Time: %.1f"

@onready var coordDisplay: Label = $Viewport/HUD/CoordsContainer/Coords

@onready var player: CharacterBody2D = $Player

var nextLevel: String = "res://Scenes/Main-Menu.tscn"
var levelComplete: bool = true # WARNING: Change to false once level is finished  


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coordDisplay.set_text("X: %d, Y: %d" % [player.position.x, player.position.y])

# Update Timer and Coordinate HUD
func _process(delta: float) -> void:
	timerDisplay.set_text(timerString % timer.time_left)
	coordDisplay.set_text("X: %d, Y: %d" % [player.position.x, player.position.y])
	
	if Input.is_action_just_pressed("next_level") and levelComplete:
		get_tree().change_scene_to_file(nextLevel)

# Fail condition
func _on_timer_timeout() -> void:
	$"Viewport/HUD/WIPMsg-TEMP".show()
	global_game_data.mark_level_complete("orienteer")
	
