extends Control

@onready var next_btn: Button = %nextBtn
@onready var settingsBtn: Button = %settingsBtn
@onready var mainMenuBtn: Button = %mainMenuBtn

func _ready() -> void:
	next_btn.pressed.connect(_next_level)
	settingsBtn.pressed.connect(_open_settings)
	mainMenuBtn.pressed.connect(_return_to_main)

func _open_settings() -> void:
	pass

func _return_to_main() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main-Menu.tscn")


func _next_level() -> void:
	var current_scene = get_tree().current_scene.scene_file_path

	match current_scene:
		"res://Scenes/Fire-Starting-Lvl.tscn":
			get_tree().change_scene_to_file("res://Scenes/Shelter-Building-Lvl.tscn")

		"res://Scenes/Shelter-Building-Lvl.tscn":
			get_tree().change_scene_to_file("res://Scenes/Orienteering-Lvl.tscn")

		"res://Scenes/Orienteering-Lvl.tscn":
			get_tree().change_scene_to_file("res://Scenes/Main-Menu.tscn")


func _quit():
	get_tree().quit()
