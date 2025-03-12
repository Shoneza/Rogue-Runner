extends Area2D

var death: bool = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var die: AudioStreamPlayer2D = $Die

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not death: # Replace with function body.
		animated_sprite.play("walking")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= get_parent().speed / 16 * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		death = true
		animated_sprite.play('die')
		collision_shape_2d.set_deferred("disabled",true)
		die.play()




#func _on_animated_sprite_2d_animation_finished() -> void:
	#if animated_sprite.animation == 'die':
		#queue_free()
