extends CharacterBody2D

const SPEED = 100.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	velocity = input_vector.normalized() * SPEED

	# Animation handling
	if input_vector.y < 0:
		animated_sprite_2d.play("up")
	elif input_vector.y > 0:
		animated_sprite_2d.play("down")
	elif input_vector.x < 0:
		animated_sprite_2d.play("left")
	elif input_vector.x > 0:
		animated_sprite_2d.play("right")
	else:
		animated_sprite_2d.play("default")
		
	if Input.is_action_just_pressed("next_level"):
		get_tree().change_scene_to_file("res://Scenes/Shelter-Building-Lvl.tscn")

	move_and_slide()
