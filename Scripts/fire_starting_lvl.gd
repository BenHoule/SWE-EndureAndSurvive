extends Node2D

@onready var timer: Timer = $Timer
@onready var timerDisplay: Label = $Viewport/HUD/TimerContainer/Timer
var timerString: String = "Time: %.1f"

@onready var stickCntDisplay: Label = $Viewport/HUD/StickCntContainer/StickCnt
@onready var stickPrefab: Resource = preload("res://Scenes/stick.tscn")
var stickCnt: int = 0

@onready var levelHint: Label = $FinishArea/CollisionShape2D/LevelHint

var nextLevel: String = "res://Scenes/Shelter-Building-Lvl.tscn"
var levelComplete: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	stickCntDisplay.set_text("%d/3 Sticks" % stickCnt)

# Update Timer
func _process(delta: float) -> void:
	timerDisplay.set_text(timerString % timer.time_left)
	
	if Input.is_action_just_pressed("next_level") and levelComplete:
		global_game_data.mark_level_complete("fire")
		get_tree().change_scene_to_file(nextLevel)


func _on_stick_pickup(body: Node2D, stick: Area2D) -> void:
	stick.queue_free()
	stickCnt += 1
	stickCntDisplay.set_text("%d/3 Sticks" % stickCnt)

# Remove stick, update stick counter + HUD
func _on_finish_area_body_entered(body: Node2D) -> void:
	if stickCnt >= 3:
		levelHint.show()
		levelComplete = true


func _on_finish_area_body_exited(body: Node2D) -> void:
	levelComplete = false
