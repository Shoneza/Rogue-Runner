extends CharacterBody2D

var movement = Vector2()
var up = Vector2(0, -1)
var speed = 200

# Declare an AnimatedSprite2D node (or any other node with animations) if you want to use animations.
@onready var animated_sprite = $AnimatedSprite2D

# Variable to track if attack is happening
var is_attacking = false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_right") and not is_attacking:
		movement.x = speed
		animated_sprite.flip_h = false
		animated_sprite.play("running")
	elif Input.is_action_pressed("ui_left") and not is_attacking:
		movement.x = -speed
		animated_sprite.flip_h = true
		animated_sprite.play("running")
	elif Input.is_action_pressed("ui_jump") and not is_attacking:
		movement.y = -speed
	elif Input.is_action_pressed('ui_down') and not is_attacking:
		movement.y = speed
	else:
		movement.x = 0
		movement.y = 0
		if not is_attacking:
			animated_sprite.play("idle")
	
	# Trigger attack when the attack button is pressed
	if Input.is_action_just_pressed('ui_attack'):
		animated_sprite.play("attack")
		is_attacking = true
		

	# Apply the movement.
	velocity = movement
	move_and_slide()

# This function is called when the animation finishes
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == 'attack':
		is_attacking = false  
