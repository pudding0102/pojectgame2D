extends CharacterBody2D

@export var speed: float = 300.0
@export var clamp_to_viewport: bool = false

# --- การโจมตี / เวลาเล่นท่า / คูลดาวน์ ---
@export var attack_duration: float = 0.25
@export var attack_cooldown: float = 0.15

signal check_player(enemy)
signal take_damage

var display_size: Vector2
var speed_multiplier: float = 1.0
var is_invincible: bool = false

# จำทิศล่าสุด (ใช้ตอนยืนเฉย ๆ หรือเริ่มโจมตี)
var last_facing: String = "down"

# สถานะโจมตี
var is_attacking := false
var _attack_time_left := 0.0
var _cooldown_left := 0.0

# จับคลิกขวาแบบ just-pressed เอง
var _rmb_was_down := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	display_size = get_viewport_rect().size
	add_to_group("player")
	show()
	# กันกรณี FPS อนิเมชันตั้งไว้ 0 หรือ speed_scale โดนแก้
	anim.speed_scale = 1.0
	print("[Player] Spawned. In tree?: ", is_inside_tree(), "  Group 'player'?: ", is_in_group("player"))
	print("[Player] Viewport: ", display_size, "  StartPos: ", position)
	print("ANIMS: ", anim.sprite_frames.get_animation_names())  # Debug: รายชื่อแอนิเมชัน

func _physics_process(delta: float) -> void:
	# --- นับเวลาคูลดาวน์ / ปิดสถานะโจมตีเมื่อหมดเวลา ---
	if _cooldown_left > 0.0:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)
	if is_attacking:
		_attack_time_left -= delta
		if _attack_time_left <= 0.0:
			is_attacking = false

	# --- อ่านอินพุตทิศทาง "ก่อน" ตรวจโจมตี เพื่อให้ทิศโจมตีตรงกับที่กด ---
	var input_vec := _get_input_vector()
	if input_vec.length() > 0.0:
		if absf(input_vec.x) > absf(input_vec.y):
			last_facing = "right" if input_vec.x > 0.0 else "left"
		else:
			last_facing = "down" if input_vec.y > 0.0 else "up"

	# --- เริ่มโจมตีถ้าเพิ่งกด (หลังรู้ทิศแล้ว) ---
	if not is_attacking and _cooldown_left == 0.0 and _is_attack_just_pressed():
		_start_attack(last_facing)

	# --- การเคลื่อนที่: โจมตีอยู่จะหยุดนิ่ง ---
	if is_attacking:
		velocity = Vector2.ZERO
	else:
		velocity = (input_vec.normalized() if input_vec.length() > 0.0 else Vector2.ZERO) * speed * speed_multiplier

	move_and_slide()

	# --- บังคับอยู่ในกรอบจอ (ออปชัน) ---
	if clamp_to_viewport:
		position.x = clamp(position.x, 0.0, display_size.x)
		position.y = clamp(position.y, 0.0, display_size.y)

	# --- ตั้งอนิเมชันเดิน/ยืนเฉพาะตอน "ไม่ได้โจมตี" เพื่อไม่ให้ทับโจมตี ---
	if not is_attacking:
		_update_walk_idle_animation(velocity)

	# เก็บสถานะปุ่มคลิกขวาไว้ตรวจ just-pressed รอบถัดไป
	_rmb_was_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

# ================= Input Helper =================
func _get_input_vector() -> Vector2:
	var x := 0.0
	var y := 0.0
	# ขวา/ซ้าย
	if InputMap.has_action("ui_right") and Input.is_action_pressed("ui_right"): x += 1.0
	if InputMap.has_action("ui_left")  and Input.is_action_pressed("ui_left"):  x -= 1.0
	if InputMap.has_action("right")    and Input.is_action_pressed("right"):    x += 1.0
	if InputMap.has_action("left")     and Input.is_action_pressed("left"):     x -= 1.0
	if InputMap.has_action("walk_right") and Input.is_action_pressed("walk_right"): x += 1.0
	if InputMap.has_action("walk_left")  and Input.is_action_pressed("walk_left"):  x -= 1.0
	# ลง/ขึ้น
	if InputMap.has_action("ui_down") and Input.is_action_pressed("ui_down"): y += 1.0
	if InputMap.has_action("ui_up")   and Input.is_action_pressed("ui_up"):   y -= 1.0
	if InputMap.has_action("down")    and Input.is_action_pressed("down"):    y += 1.0
	if InputMap.has_action("up")      and Input.is_action_pressed("up"):      y -= 1.0
	if InputMap.has_action("walk_down") and Input.is_action_pressed("walk_down"): y += 1.0
	if InputMap.has_action("walk_up")   and Input.is_action_pressed("walk_up"):   y -= 1.0
	return Vector2(clamp(x, -1.0, 1.0), clamp(y, -1.0, 1.0))

func _update_walk_idle_animation(v: Vector2) -> void:
	if v.length() == 0.0:
		anim.stop()
		return
	# ต้องมีแอนิเมชันเดินชื่อ: left, right, up, down
	anim.play(last_facing)

# ================= Attack =================
func _is_attack_just_pressed() -> bool:
	# แนะนำ: สร้างแอ็กชัน "attack" ใน Input Map แล้ว bind = Space + Right Mouse
	if InputMap.has_action("attack") and Input.is_action_just_pressed("attack"):
		return true
	# ใช้ Space ผ่าน ui_accept
	if InputMap.has_action("ui_accept") and Input.is_action_just_pressed("ui_accept"):
		return true
	# คลิกขวาแบบตรวจเอง (just pressed)
	var rmb_now := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var just_pressed_rmb := rmb_now and not _rmb_was_down
	return just_pressed_rmb

func _start_attack(facing: String) -> void:
	print("ATTACK FACING:", facing)  # Debug
	is_attacking = true
	_attack_time_left = attack_duration
	_cooldown_left = attack_cooldown

	match facing:
		"down":
			
			_play_attack("attack_down")
		"up":
			_play_attack("attack_up")
		"left":
			_play_attack("attack_left")
		"right":
			_play_attack("attack_right")   # เพิ่ม case ขวาชัด ๆ
		_:
			_play_attack("attack_down")
func _play_attack(name: String) -> void:
	anim.speed_scale = 1.0
	if anim.sprite_frames.has_animation(name):
		anim.frame = 0
		anim.play(name)
	else:
		anim.frame = 0
		anim.play("attack_right") # กันพังถ้าไม่มี

# ================= Options / Utilities =================
func set_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier
	print("[Player] speed_multiplier set to ", speed_multiplier)

func set_invincible(value: bool) -> void:
	is_invincible = value
	print("[Player] invincible: ", is_invincible)

# ================= ตัวอย่างสัญญาณจาก Area2D (ถ้ามี) =================
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area and area.is_in_group("element"):
		print("ชน element (Area2D): ", area.name)
