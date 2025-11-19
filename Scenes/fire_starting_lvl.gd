extends Node2D

@onready var timer: Timer = $Timer
@onready var timerDisplay: Label = $CanvasLayer/HUD/TimerContainer/Timer
@onready var timerString: String = "Time: %.1f"

@onready var stickCntDisplay: Label = $CanvasLayer/HUD/StickCntContainer/StickCnt
@onready var stickPrefab: Resource = preload("res://Scenes/stick.tscn")
var stickCnt = 0

var nextLevel = "res://Scenes/Shelter-Building-Lvl.tscn"
var levelComplete: bool = true # WARNING: Change to false once level is finished


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var stick1: Area2D = stickPrefab.instantiate()
	var stick2: Area2D = stickPrefab.instantiate()
	var stick3: Area2D = stickPrefab.instantiate()
	var sticks: Dictionary[Area2D, Vector2] = {
		stick1: Vector2(71.0, -121.0),
		stick2: Vector2(-206.0, -162.0),
		stick3: Vector2(-172.0, -14.0)
	}
	for _stick in sticks:
		_stick.set_position(sticks[_stick])
		add_child(_stick)
		_stick.body_entered.connect(_on_stick_pickup.bind(_stick))

	stickCntDisplay.set_text("%d/3 Sticks" % stickCnt)

# Update Timer
func _process(delta: float) -> void:
	timerDisplay.set_text(timerString % timer.time_left)
	
	if Input.is_action_just_pressed("next_level") and levelComplete:
		get_tree().change_scene_to_file(nextLevel)

# Remove log, update log counter + HUD
func _on_stick_pickup(body: Node2D, _stick: Area2D):
	_stick.queue_free()
	stickCnt += 1
	stickCntDisplay.set_text("%d/3 Sticks" % stickCnt)


func _on_timer_timeout() -> void:
	$"CanvasLayer/HUD/WIPMsg-TEMP".show()
	global_game_data.mark_level_complete("fire")
