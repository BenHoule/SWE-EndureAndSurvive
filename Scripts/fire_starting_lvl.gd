extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var timer: Timer = $Timer
@onready var fire: StaticBody2D = $Fire
@onready var timerDisplay: Label = $Viewport/HUD/TimerContainer/Timer
@onready var tinderCntDisplay: Label = $Viewport/HUD/VBoxContainer/TinderCntContainer/TinderCnt
@onready var kindlingCntDisplay: Label = $Viewport/HUD/VBoxContainer/KindlingCntContainer/KindlingCnt
@onready var fuelCntDisplay: Label = $Viewport/HUD/VBoxContainer/FuelCntContainer/FuelCnt
@onready var finishArea: Area2D = $FinishArea
@onready var levelHint: Label = $FinishArea/CollisionShape2D/LevelHint
@onready var miniGame: Control = $Viewport/MiniGameController
@onready var win_menu_controller: Control = $Viewport/winMenuController
@onready var lose_menu_controller: Control = $Viewport/loseMenuController

var canBuild: bool = false
var timerString: String = "Time: %.1f"
var nextLevel: String = "res://Scenes/Shelter-Building-Lvl.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tinderCntDisplay.set_text("%d/3 Tinder" % 0)
	kindlingCntDisplay.set_text("%d/2 Kindling" % 0)
	fuelCntDisplay.set_text("%d/1 Fuel" % 0)
	miniGame.finished.connect(_on_mini_game_finished)


# Update Timer
func _process(_delta: float) -> void:
	timerDisplay.set_text(timerString % timer.time_left)
	
	if canBuild && Input.is_action_just_pressed("build"):
		# Level finishes after mini
		miniGame.show()
		levelHint.hide()
		finishArea.process_mode = Node.PROCESS_MODE_DISABLED
		player.process_mode = Node.PROCESS_MODE_DISABLED


# Remove stick, update stick counter + HUD
func _on_stick_pickup(_body: Node2D, source: Area2D) -> void:
	source.queue_free()
	source.remove_from_group("Tinder")
	var tinderCnt: int = get_tree().get_node_count_in_group("Tinder")
	tinderCntDisplay.set_text("%d/3 Sticks" % (3 - tinderCnt))
	await player.speak("I can break this down into some good tinder.")


func _on_large_stick_pickup(_body: Node2D, source: Area2D) -> void:
	source.queue_free()
	source.remove_from_group("Kindling")
	var kindlingCnt: int = get_tree().get_node_count_in_group("Kindling")
	kindlingCntDisplay.set_text("%d/2 Kindling" % (2 - kindlingCnt))
	await player.speak("These larger sticks would make great kindling!")


func _on_log_pickup(_body: Node2D, source: Area2D) -> void:
	source.queue_free()
	source.remove_from_group("Fuel")
	var fuelCnt: int = get_tree().get_node_count_in_group("Fuel")
	fuelCntDisplay.set_text("%d/1 Fuel" % (1 - fuelCnt))
	await player.speak("This should be enough fuel to get a small fire started.")
	await player.speak("I'll need to find more if I want to keep it going.")


func _on_bad_stick_pickup(_body: Node2D, source: Area2D) -> void:
	source.queue_free()
	await player.speak("This wood is too wet!")


# Display hint text (if objective complete)
func _on_finish_area_body_entered(_body: Node2D) -> void:
	var tinderCnt: int = get_tree().get_node_count_in_group("Tinder")
	var kindlingCnt: int = get_tree().get_node_count_in_group("Kindling")
	var fuelCnt: int = get_tree().get_node_count_in_group("Fuel")
	var total: int = tinderCnt + kindlingCnt + fuelCnt
	if  total == 0:
		levelHint.show()
		canBuild = true


func _on_finish_area_body_exited(_body: Node2D) -> void:
	canBuild = false


func _on_mini_game_finished(success: bool) -> void:
	miniGame.hide()
	player.process_mode = Node.PROCESS_MODE_INHERIT
	if success:
		timer.paused = true
		fire.process_mode = Node.PROCESS_MODE_INHERIT
		fire.show()
		global_game_data.mark_level_complete("fire")
		win_menu_controller.show()
	else:
		pass # WARNING: Fail-state?


func _on_timer_timeout() -> void:
	if miniGame.visible:
		_on_mini_game_finished(false)
	lose_menu_controller.show()
	player.process_mode = Node.PROCESS_MODE_DISABLED
