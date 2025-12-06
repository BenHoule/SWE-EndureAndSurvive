extends Control

@onready var resumeBtn: Button = %resumeBtn
@onready var settingsBtn: Button = %settingsBtn
@onready var mainMenuBtn: Button = %mainMenuBtn
@onready var quitBtn: Button = %quitBtn
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	resumeBtn.pressed.connect(_resume)
	settingsBtn.pressed.connect(_open_settings)
	mainMenuBtn.pressed.connect(_return_to_main)
	quitBtn.pressed.connect(_quit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			_resume()
		else:
			_pause()

func _pause() -> void:
	audio.play()
	show()
	# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	

func _resume() -> void:
	audio.play()
	hide()
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func _return_to_main() -> void:
	get_tree().paused = false
	audio.play()
	await audio.finished
	get_tree().change_scene_to_file("res://Scenes/Main-Menu.tscn")

func _quit() -> void:
	audio.play()
	await audio.finished
	get_tree().quit()

func _open_settings() -> void:
	pass
