extends Control

@onready var fireLvlBtn: Button = %fireLvlBtn
@onready var shelterLvlBtn: Button = %shelterLvlBtn
@onready var orienteerLvlBtn: Button = %orienteerLvlBtn
@onready var settingsBtn: Button = %settingsBtn
@onready var quitBtn: Button = %quitBtn

# TBH enum is probably unnecessary, could just be passing strings.
# We aren't paying by the byte here.
enum LevelType {FIRE_STARTING, SHELTER_BUILDING, ORIENTEERING}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect level buttons
	fireLvlBtn.pressed.connect(_load_level.bind(LevelType.FIRE_STARTING))
	if global_game_data.completed_levels["fire"]:
		shelterLvlBtn.pressed.connect(_load_level.bind(LevelType.SHELTER_BUILDING))
		shelterLvlBtn.disabled = false
	if global_game_data.completed_levels["shelter"]:
		orienteerLvlBtn.pressed.connect(_load_level.bind(LevelType.ORIENTEERING))
		orienteerLvlBtn.disabled = false
	
	# Connect other buttons
	settingsBtn.pressed.connect(_open_settings)
	quitBtn.pressed.connect(_quit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Change scene to chosen level
func _load_level(level: LevelType) -> void:
	match level:
		LevelType.FIRE_STARTING:
			get_tree().change_scene_to_file("res://Scenes/Fire-Starting-Lvl.tscn")
		LevelType.SHELTER_BUILDING:
			get_tree().change_scene_to_file("res://Scenes/Shelter-Building-Lvl.tscn")
		LevelType.ORIENTEERING:
			get_tree().change_scene_to_file("res://Scenes/Orienteering-Lvl.tscn")
		_:
			# Maybe have some error handling here? Should just be unreachable though.
			pass

# Switch to displaying settings/options
func _open_settings() -> void:
	pass

# Exits the game
func _quit() -> void:
	get_tree().quit()
	pass
