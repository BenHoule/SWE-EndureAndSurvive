extends CollisionShape2D
@onready var player: CharacterBody2D = $"../../CharacterBody2D"

var player_inside := false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("next_level"):
		get_tree().change_scene_to_file("res://Scenes/Shelter-Building-Lvl.tscn")
