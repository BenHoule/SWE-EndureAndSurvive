extends Node


@export var save_path = "user://SWE-Island-Survival.dat"

var completed_levels = {
	"fire": false,
	"shelter": false,
	"orienteer": false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists(save_path):
		var loaded: GameData = ResourceLoader.load(save_path)
		if loaded:
			completed_levels = loaded.completed_levels
		else:
			printerr("Failed to load save file.")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func mark_level_complete(level_id: String):
	completed_levels[level_id] = true
	save_game()
	

func save_game():
	var save_resource = GameData.new()
	save_resource.completed_levels = completed_levels
	ResourceSaver.save(save_resource, save_path)

func clear_save():
	var save_resource = GameData.new()
	ResourceSaver.save(save_resource, save_path)
