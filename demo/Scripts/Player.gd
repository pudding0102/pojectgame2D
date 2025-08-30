extends CharacterBody2D

# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 600
@export var jump_force : float = 1000
@export var gravity : float = 20
@export var max_jump_count : int = 2
var jump_count : int = 2

@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)
@export var double_jump : = false

var is_grounded : bool = false

var ground_time = 0.0
var step_time = 0.0

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles

# --------- BUILT-IN FUNCTIONS ---------- #

func _process(_delta):
	# Calling functions
	movement(_delta)
	player_animations()
	flip_player()
	
# --------- CUSTOM FUNCTIONS ---------- #

# <-- Player Movement Code -->
func movement(_delta):
	# Gravity
	if !is_on_floor():
		velocity.y += gravity
		ground_time = 0
	elif is_on_floor():
		jump_count = max_jump_count
		if ground_time == 0:
			var step = randi_range(1,4)
			if step == 1:
				$Step.play()
			elif step == 2:
				$Step2.play()
			elif step == 3:
				$Step3.play()
			else:
				$Step4.play()
		ground_time += _delta
	
	handle_jumping()
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	velocity = Vector2(inputAxis * move_speed, velocity.y)
	move_and_slide()
	if inputAxis != 0 && is_on_floor():
		step_time += _delta * 3
	if step_time >= 1:
		var step = randi_range(1,4)
		if step == 1:
			$Step.play()
		elif step == 2:
			$Step2.play()
		elif step == 3:
			$Step3.play()
		else:
			$Step4.play()
		step_time = 0

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	jump_tween()
	$Jump.play()
	#AudioManager.jump_sfx.play()
	velocity.y = -jump_force

# Handle Player Animations
func player_animations():
	particle_trails.emitting = false
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			$AnimationPlayer.play("Walk")
			$AnimationPlayer.speed_scale = 2
			player_sprite.play("Walk", 1.5)
		else:
			$AnimationPlayer.play("Idle")
			$AnimationPlayer.speed_scale = 1
			player_sprite.play("Idle")
	else:
		$AnimationPlayer.play("Jump")
		$AnimationPlayer.speed_scale = 1
		player_sprite.play("Jump")

# Flip player sprite based on X velocity
func flip_player():
	if velocity.x < 0: 
		player_sprite.flip_h = true
		$Skeleton2D.scale.x = -0.185
		$Parts.scale.x = -0.185
	elif velocity.x > 0:
		player_sprite.flip_h = false
		$Skeleton2D.scale.x = 0.185
		$Parts.scale.x = 0.185

# Tween Animations
func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	velocity.y = -100
	await get_tree().create_timer(0.3).timeout
	#AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

# --------- SIGNALS ---------- #

# Reset the player's position to the current level spawn point if collided with any trap
func _on_collision_body_entered(_body):
	if _body.is_in_group("Enemy") && ground_time > 0.1:
		#AudioManager.death_sfx.play()
		GameManager.add_death()
		$Death.play()
		death_particles.emitting = true
		death_tween()
	elif _body.is_in_group("Traps"):
		#AudioManager.death_sfx.play()
		GameManager.add_death()
		$Death.play()
		death_particles.emitting = true
		death_tween()
		
