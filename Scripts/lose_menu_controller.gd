extends Control

@onready var retry_btn: Button = %retryBtn
@onready var settingsBtn: Button = %settingsBtn
@onready var mainMenuBtn: Button = %mainMenuBtn
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	retry_btn.pressed.connect(_retry_level)
	settingsBtn.pressed.connect(_open_settings)
	mainMenuBtn.pressed.connect(_return_to_main)

func _open_settings() -> void:
	pass

func _return_to_main() -> void:
	audio.play()
	await audio.finished
	get_tree().change_scene_to_file("res://Scenes/Main-Menu.tscn")


func _retry_level() -> void:
	audio.play()
	await audio.finished
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)


func _quit():
	audio.play()
	await audio.finished
	get_tree().quit()
