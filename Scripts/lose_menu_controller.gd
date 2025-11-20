extends Control

@onready var retry_btn: Button = %retryBtn
@onready var settingsBtn: Button = %settingsBtn
@onready var mainMenuBtn: Button = %mainMenuBtn

func _ready() -> void:
	retry_btn.pressed.connect(_retry_level)
	settingsBtn.pressed.connect(_open_settings)
	mainMenuBtn.pressed.connect(_return_to_main)

func _open_settings() -> void:
	pass

func _return_to_main() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main-Menu.tscn")


func _retry_level() -> void:
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)


func _quit():
	get_tree().quit()
