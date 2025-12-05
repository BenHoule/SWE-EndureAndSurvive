extends CharacterBody2D

const TILE_SIZE = 16

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
const SPEED = 300.0

@onready var dialogueBox: Label = $DialogueBox

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	# Attempted to make movement logic independent of frame-rate, idk how well it worked
	velocity = input_vector.normalized() * SPEED * TILE_SIZE * delta

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
		

	move_and_slide()

func speak(text: String) -> void:
	dialogueBox.set_text(text)
	dialogueBox.show()
	await get_tree().create_timer(2.0).timeout
	dialogueBox.hide()
	dialogueBox.set_text("")
