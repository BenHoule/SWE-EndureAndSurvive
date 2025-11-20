extends Control

@onready var next_btn: Button = %nextBtn
@onready var settingsBtn: Button = %settingsBtn
@onready var mainMenuBtn: Button = %mainMenuBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_btn.pressed.connect(_return_to_main)
	settingsBtn.pressed.connect(_open_settings)
	mainMenuBtn.pressed.connect(_return_to_main)


func _open_settings() -> void:
	pass

func _return_to_main() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main-Menu.tscn")

func _quit():
	get_tree().quit()
