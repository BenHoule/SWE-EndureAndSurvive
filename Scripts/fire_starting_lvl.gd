extends Node2D

@onready var player: CharacterBody2D = $Player

@onready var timer: Timer = $Timer
@onready var timerDisplay: Label = $Viewport/HUD/TimerContainer/Timer
var timerString: String = "Time: %.1f"

@onready var stickCntDisplay: Label = $Viewport/HUD/StickCntContainer/StickCnt
@onready var stickPrefab: Resource = preload("res://Scenes/stick.tscn")
var stickCnt: int = 0

@onready var finishArea: Area2D = $FinishArea
@onready var levelHint: Label = $FinishArea/CollisionShape2D/LevelHint
@onready var miniGame: Control = $Viewport/MiniGameController
var canBuild: bool = false

var nextLevel: String = "res://Scenes/Shelter-Building-Lvl.tscn"

@onready var win_menu_controller: Control = $Viewport/winMenuController
@onready var lose_menu_controller: Control = $Viewport/loseMenuController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Spawn sticks
	var stick1: Area2D = stickPrefab.instantiate()
	var stick2: Area2D = stickPrefab.instantiate()
	var stick3: Area2D = stickPrefab.instantiate()
	var sticks: Dictionary[Area2D, Vector2] = {
		stick1: Vector2(88.0, 185.0),
		stick2: Vector2(-237.0, 178.0),
		stick3: Vector2(-278.0, -93.0)
	}
	for stick in sticks:
		stick.set_position(sticks[stick])
		add_child(stick)
		stick.body_entered.connect(_on_stick_pickup.bind(stick))
	
	var bad_stick1: Area2D = stickPrefab.instantiate()
	var bad_stick2: Area2D = stickPrefab.instantiate()
	var bad_stick3: Area2D = stickPrefab.instantiate()
	var bad_sticks: Dictionary[Area2D, Vector2] = {
		bad_stick1: Vector2(220.0, 150.0),
		bad_stick2: Vector2(-300.0, 200.0),
		bad_stick3: Vector2(128.0, -190.0)
	}
	for stick in bad_sticks:
		stick.set_position(bad_sticks[stick])
		add_child(stick)
		stick.set_sprite_tile(9) # WARNING: Magic number bad but I'm rushing
		stick.body_entered.connect(_on_bad_stick_pickup.bind(stick))
	
	stickCntDisplay.set_text("%d/3 Sticks" % stickCnt)
	
	miniGame.finished.connect(_on_mini_game_finished)

# Update Timer
func _process(delta: float) -> void:
	timerDisplay.set_text(timerString % timer.time_left)
	
	if canBuild && Input.is_action_just_pressed("build"):
		miniGame.show()
		levelHint.hide()
		finishArea.process_mode = Node.PROCESS_MODE_DISABLED
		player.process_mode = Node.PROCESS_MODE_DISABLED

	#if levelComplete && Input.is_action_just_pressed("next_level"):
		#global_game_data.mark_level_complete("fire")
		#win_menu_controller.show()

# Remove stick, update stick counter + HUD
func _on_stick_pickup(body: Node2D, stick: Area2D) -> void:
	stick.queue_free()
	stickCnt += 1
	stickCntDisplay.set_text("%d/3 Sticks" % stickCnt)

func _on_bad_stick_pickup(body: Node2D, stick: Area2D) -> void:
	stick.queue_free()
	player.speak("This wood is too wet!")


# Display hint text (if objective complete)
func _on_finish_area_body_entered(body: Node2D) -> void:
	if stickCnt >= 3:
		levelHint.show()
		canBuild = true


func _on_finish_area_body_exited(body: Node2D) -> void:
	canBuild = false


func _on_mini_game_finished(success: bool) -> void:
	miniGame.hide()
	player.process_mode = Node.PROCESS_MODE_INHERIT
	if success:
		timer.paused = true
		global_game_data.mark_level_complete("fire")
		win_menu_controller.show()
	else:
		pass # WARNING: Need a fail-state


func _on_timer_timeout() -> void:
	if miniGame.visible:
		miniGame.hide()
	lose_menu_controller.show()
	player.process_mode = Node.PROCESS_MODE_DISABLED
