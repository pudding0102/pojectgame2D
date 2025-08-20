extends CharacterBody2D

@export var SPEED = 300
enum State{
	IDEL,
	WALK_LR,
	WALK_UP,
	WALK_DOWN
}

var curr_state: State = State.IDEL
var direction = Vector2.ZERO

func _process(delta: float) -> void:
	if Input.is_action_pressed("LEFT"):
		direction.x -= 1
		curr_state = State.WALK_LR
	elif Input.is_action_pressed("RIGHT"):
		direction.x += 1
		curr_state = State.WALK_LR
	elif Input.is_action_pressed("UP"):
		direction.y -= 1
		curr_state = State.WALK_UP
	elif Input.is_action_pressed("DOWN"):
		direction.y += 1
		curr_state = State.WALK_DOWN
	else:
		curr_state = State.IDEL
		direction = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("LEFT"):
		direction.x -= 1
	elif Input.is_action_pressed("RIGHT"):
		direction.x += 1
	if Input.is_action_pressed("UP"):
		direction.y -= 1
	elif Input.is_action_pressed("DOWN"):
		direction.y += 1
	
	#ความเร็วเท่ากันทุกทิศทาง
	if direction.length() > 0:
		direction = direction.normalized()
		
	#คำนวณ velocity
	var velocity = direction * SPEED	
	
	#ย้ายตำแหน่ง
	position += velocity * delta
