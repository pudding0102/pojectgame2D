extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_following_player = false
var player : CharacterBody2D = null


func _ready() -> void:
	$AnimatedSprite2D.play()
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if  is_following_player:
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
		move_and_slide()




func _on_area_2d_area_entered(body) -> void:
	is_following_player = true
	player = body


func _on_area_2d_area_exited(area: Area2D) -> void:
	is_following_player = false
