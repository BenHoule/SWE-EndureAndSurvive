extends Node2D

@onready var timer: Timer = $Timer
@onready var timerDisplay: Label = $Viewport/HUD/TimerContainer/Timer
@onready var timerString: String = "Time: %.1f"
@onready var win_menu_controller: Control = $Viewport/winMenuController
@onready var logCntDisplay: Label = $Viewport/HUD/LogCntContainer/LogCnt
@onready var logPrefab: Resource = preload("res://Scenes/log.tscn")
var logCnt = 0

var nextLevel = "res://Scenes/Orienteering-Lvl.tscn"
var levelComplete: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	win_menu_controller.hide()
	var log1: Area2D = logPrefab.instantiate()
	var log2: Area2D = logPrefab.instantiate()
	var log3: Area2D = logPrefab.instantiate()
	var log4: Area2D = logPrefab.instantiate()
	var log5: Area2D = logPrefab.instantiate()
	var logs: Dictionary[Area2D, Vector2] = {
		log1: Vector2(71.0, -121.0),
		log2: Vector2(-206.0, -162.0),
		log3: Vector2(-172.0, -14.0),
		log4: Vector2(-165.0, 182.0),
		log5: Vector2(33.0, 153.0)
	}
	for _log in logs:
		_log.set_position(logs[_log])
		add_child(_log)
		_log.body_entered.connect(_on_log_pickup.bind(_log))

	logCntDisplay.set_text("%d/5 Logs" % logCnt)

# Update Timer
func _process(_delta: float) -> void:
	timerDisplay.set_text(timerString % timer.time_left)
	
	if levelComplete:
		win_menu_controller.show()

# Remove log, update log counter + HUD
func _on_log_pickup(body: Node2D, _log: Area2D):
	_log.queue_free()
	logCnt += 1
	logCntDisplay.set_text("%d/5 Logs" % logCnt)
	if (logCnt == 5):
		timer.paused = true
		levelComplete = true
		global_game_data.mark_level_complete("shelter")
