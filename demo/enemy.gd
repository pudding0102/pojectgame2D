extends CharacterBody2D

@export var player: CharacterBody2D
@export var SPEED: int = 50
@export var CHASE_SPEED: int = 150
@export var ACCELERATION: int = 300
@export var patrol_half_range: float = 125
@export var lose_sight_delay: float = 0.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $AnimatedSprite2D/RayCast2D
@onready var timer: Timer = $Timer

var direction: Vector2 = Vector2.ZERO
var left_bounds: Vector2
var right_bounds: Vector2

enum States { WANDER, CHASE }
var current_state: States = States.WANDER

func _ready() -> void:
	$AnimatedSprite2D.play("Yak1Run")
	$shadow.play("shadow")
	left_bounds  = global_position + Vector2(-patrol_half_range, 0)
	right_bounds = global_position + Vector2( patrol_half_range, 0)

	sprite.flip_h = bool(randi() % 2)
	_update_forward_and_raycast()

	timer.wait_time = lose_sight_delay
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	if player == null:
		var ps = get_tree().get_nodes_in_group("player")
		if ps.size() > 0:
			player = ps[0] as CharacterBody2D

func _physics_process(delta: float) -> void:
	_change_direction()
	_handle_movement(delta)
	_look_for_player()

func _look_for_player() -> void:
	if !is_instance_valid(player): return
	if ray_cast.is_colliding():
		var c := ray_cast.get_collider()
		if c == player or (c is Node and (c as Node).is_in_group("player")):
			_chase_player()
	else:
		if current_state == States.CHASE and timer.time_left <= 0.0:
			timer.start()

func _chase_player() -> void:
	timer.stop()
	current_state = States.CHASE

func _on_timer_timeout() -> void:
	current_state = States.WANDER

func _handle_movement(delta: float) -> void:
	var target_speed: float = SPEED if current_state == States.WANDER else CHASE_SPEED
	var desired := direction * target_speed
	# ปรับความเร็วอย่างนุ่มนวลเฉพาะแกนที่ใช้
	velocity.x = move_toward(velocity.x, desired.x, ACCELERATION * delta)
	velocity.y = move_toward(velocity.y, desired.y, ACCELERATION * delta)
	move_and_slide()  # ไม่มี up_direction เพราะเป็น top-down

func _change_direction() -> void:
	if current_state == States.WANDER:
		# เฝ้าไป-กลับในแกน X (จะเอาเดินสุ่มแกน Y ด้วยก็ได้)
		if !sprite.flip_h:
			direction = Vector2(1, 0)
			if global_position.x >= right_bounds.x:
				sprite.flip_h = true
				_update_forward_and_raycast()
		else:
			direction = Vector2(-1, 0)
			if global_position.x <= left_bounds.x:
				sprite.flip_h = false
				_update_forward_and_raycast()
	else:
		if is_instance_valid(player):
			var to_player := (player.global_position - global_position).normalized()
			direction = Vector2(sign(to_player.x), sign(to_player.y))  # ไล่แบบ top-down
			# หันหน้าตามแกน X
			if direction.x > 0 and sprite.flip_h:
				sprite.flip_h = false; _update_forward_and_raycast()
			elif direction.x < 0 and !sprite.flip_h:
				sprite.flip_h = true;  _update_forward_and_raycast()

func _update_forward_and_raycast() -> void:
	ray_cast.enabled = true
	# ให้ RayCast ชี้ไปทางที่หัน เพื่อมองหาผู้เล่น
	ray_cast.target_position = Vector2(-patrol_half_range, 0) if sprite.flip_h \
		else Vector2( patrol_half_range, 0)
