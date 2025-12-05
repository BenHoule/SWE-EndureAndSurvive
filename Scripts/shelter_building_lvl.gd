extends Node2D

@onready var structure: Array[TileMapLayer] = [
	$Floor,
	$Walls,
	$Furniture
]
@onready var player: CharacterBody2D = $Player
@onready var finishArea: Area2D = $FinishArea
@onready var levelHint: Label = $FinishArea/CollisionShape2D/LevelHint
@onready var timerDisplay: Label = $Viewport/HUD/TimerContainer/Timer
@onready var win_menu_controller: Control = $Viewport/winMenuController
@onready var lose_menu_controller: Control = $Viewport/loseMenuController
@onready var logCntDisplay: Label = $Viewport/HUD/LogCntContainer/LogCnt
@onready var miniGame: Control = $Viewport/MiniGameController
@onready var timer: Timer = $Timer


var logCnt: int = 0
var timerString: String = "Time: %.1f"
var nextLevel: String = "res://Scenes/Orienteering-Lvl.tscn"
var levelComplete: bool = false
var canBuild: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logCntDisplay.set_text("%d/5 Logs" % logCnt)

# Update Timer
func _process(_delta: float) -> void:
	timerDisplay.set_text(timerString % timer.time_left)
	
	if canBuild && Input.is_action_just_pressed("build"):
		# Level finishes after mini
		miniGame.show()
		finishArea.hide()
		finishArea.process_mode = Node.PROCESS_MODE_DISABLED
		player.process_mode = Node.PROCESS_MODE_DISABLED

# Remove log, update log counter + HUD
func _on_log_pickup(_body: Node2D, source: Area2D):
	source.queue_free()
	logCnt += 1
	logCntDisplay.set_text("%d/5 Logs" % logCnt)

func _on_finish_area_body_entered(_body: Node2D) -> void:
	if logCnt == 5:
		levelHint.show()
		canBuild = true

func _on_finish_area_body_exited(_body: Node2D) -> void:
	canBuild = false
	
func _on_mini_game_finished(success: bool) -> void:
	miniGame.hide()
	player.process_mode = Node.PROCESS_MODE_INHERIT
	if success:
		timer.paused = true
		player.position = Vector2i(-53, -110) # Put player inside the lean-to
		for mapLayer in structure:
			mapLayer.enabled = true
		player.speak("That's a big lean-to!")
		global_game_data.mark_level_complete("shelter")
		win_menu_controller.show()
	else:
		pass # WARNING: Fail-state?


func _on_timer_timeout() -> void:
	if miniGame.visible:
		_on_mini_game_finished(false)
	lose_menu_controller.show()
	player.process_mode = Node.PROCESS_MODE_DISABLED
