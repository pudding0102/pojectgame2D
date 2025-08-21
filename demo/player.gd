extends CharacterBody2D

@export var speed: float = 200.0
@export var clamp_to_viewport: bool = false

signal check_player(enemy)
signal take_damage

var display_size: Vector2
var speed_multiplier: float = 1.0
var is_invincible: bool = false
# (อย่าประกาศ velocity เอง—CharacterBody2D มีให้แล้ว)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	display_size = get_viewport_rect().size
	add_to_group("player")
	show()
	print("[Player] Spawned. In tree?: ", is_inside_tree(), "  Group 'player'?: ", is_in_group("player"))
	print("[Player] Viewport: ", display_size, "  StartPos: ", position)

func _physics_process(delta: float) -> void:
	# --- อ่านอินพุต (รองรับทั้งชุด ui_* / walk_* / left-right-up-down ที่คุณตั้งไว้) ---
	var input_vec := _get_input_vector()
	if input_vec.length() > 0.0:
		input_vec = input_vec.normalized()
		velocity = input_vec * speed * speed_multiplier
	else:
		velocity = Vector2.ZERO

	# --- เคลื่อนที่แบบฟิสิกส์ (จะหยุดเมื่อชน StaticBody2D/TileMap) ---
	move_and_slide()

	# --- (ออปชัน) บังคับไม่ให้ออกจากกรอบวิวพอร์ต ถ้าต้องการ ---
	if clamp_to_viewport:
		# การ clamp หลัง move_and_slide อาจดันตัวละครซ้อนผนังได้ ใช้เฉพาะฉากทดลอง
		position.x = clamp(position.x, 0.0, display_size.x)
		position.y = clamp(position.y, 0.0, display_size.y)

	# --- ตั้งแอนิเมชันตามทิศ ---
	_update_animation(velocity)

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

func _update_animation(v: Vector2) -> void:
	if v.length() == 0.0:
		anim.stop()
		return

	if absf(v.x) > absf(v.y):
		anim.animation = "right" if v.x > 0.0 else "left"
	else:
		anim.animation = "down" if v.y > 0.0 else "up"
	anim.play()

# ---------------- Options / Utilities ----------------
func set_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier
	print("[Player] speed_multiplier set to ", speed_multiplier)

func set_invincible(value: bool) -> void:
	is_invincible = value
	print("[Player] invincible: ", is_invincible)

# ---------------- Signals from Area2D (ถ้ามีโซนตรวจจับเสริม) ----------------
# หมายเหตุ: การ "ไม่ให้เดินผ่าน" ใช้ฟิสิกส์ของ StaticBody2D/TileMap จัดการแล้ว
# ฟังก์ชันนี้สำหรับตรวจว่าชนของในกลุ่ม element เท่านั้น
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area and area.is_in_group("element"):
		print("ชน element (Area2D): ", area.name)
