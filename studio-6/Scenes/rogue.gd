extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -1600
const GRAVITY : int = 4200
var is_attacking = false  # Variable to track attack state
const ATTACK_BOOST = -200
@onready var animated_sprite = $AnimatedSprite2D
var is_double_jump = false
var is_aerial_attack = false
const ATTACK_HITBOX_OFFSET = Vector2(-6, 0) # Offset for the attack hitbox
@onready var jumping_sound: AudioStreamPlayer = $JumpingSound
@onready var attack_sound: AudioStreamPlayer = $AttackSound

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor() and not is_attacking:
		velocity.y += GRAVITY * delta

	
	if not get_parent().is_game_over:
		if is_on_floor() and not is_attacking  :
			is_double_jump = false
			is_aerial_attack = false
			if not get_parent().game_running:
				animated_sprite.play("idle")
				$RunCol.disabled = false
				
				
			else:
				if not get_parent().is_game_over:
					if Input.is_action_just_pressed("ui_jump")and not is_attacking:
						
						velocity.y = JUMP_VELOCITY
						$RunCol.disabled = false
						jumping_sound.play()
						
					elif Input.is_action_pressed('ui_roll')and not is_attacking: 
						animated_sprite.play('duck')
						$RunCol.disabled = true
						
						
					elif Input.is_action_just_pressed('ui_attack') and not is_attacking:  # Check for attack input
						animated_sprite.play("attack")  # Play attack animation
						is_attacking = true
						$AttackArea/CollisionShape2D.disabled = false
						$RunCol.position += ATTACK_HITBOX_OFFSET
						$DuckCol.position += ATTACK_HITBOX_OFFSET
						attack_sound.play()
						
					else:
						# Default running animation
						$RunCol.disabled = false
						
					
						if not is_attacking:
							animated_sprite.play("running")
				else:
					animated_sprite.play("idle")
		else:
		
			if Input.is_action_just_pressed('ui_attack') and not is_attacking and not is_aerial_attack:  # Check for attack input
					animated_sprite.play("attack")
					velocity.y = ATTACK_BOOST  # Play attack animation
					is_attacking = true
					is_aerial_attack = true
					$AttackArea/CollisionShape2D.disabled = false
					$RunCol.position += ATTACK_HITBOX_OFFSET
					$DuckCol.position += ATTACK_HITBOX_OFFSET
					attack_sound.play()

			elif Input.is_action_just_pressed('ui_jump') and not is_attacking and not is_double_jump:
				velocity.y = JUMP_VELOCITY
				is_double_jump = true
				animated_sprite.play('duck')
				jumping_sound.play()
			if not is_attacking and not is_double_jump:	
				animated_sprite.play('jump')
		
	else:
		animated_sprite.play('die')
		
	# Move the player.
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == 'attack':
		$AttackArea/CollisionShape2D.disabled = true
		is_attacking = false
		$RunCol.position -= ATTACK_HITBOX_OFFSET
		$DuckCol.position -= ATTACK_HITBOX_OFFSET
	elif animated_sprite.animation == 'die':
		queue_free()
