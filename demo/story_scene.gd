extends Node2D

@onready var background = $background               # Sprite2D หรือ TextureRect สำหรับพื้นหลัง
@onready var name_label = $DialogueBox/NameLabel
@onready var dialogue_label = $DialogueBox/DialogueLabel
@onready var next_button = $DialogueBox/NextButton

# รายการบทสนทนา
var dialogues = [
	{
		"name": "บรรยาย",
		"text": "ในวันที่แสนสุขของหมู่บ้านกีกี้ กำลังจะมีงานเลี้ยงที่สำคัญจัดขึ้นในค่ำวันนี้",
		"background": "res://SceneStory/scene1.png"
	},
	{
		"name": "บรรยาย",
		"text": "เด็กน้อยสามคน ต๋อง ระกา ด็องโก้ะ ตื่นเต้นเป็นอย่างมาก",
		"background": "res://SceneStory/scene2.png"
	},
	{
		"name": "บรรยาย",
		"text": "เพราะเป็นเทศกาลขนมหวานประจำปีของหมู่บ้าน",
		"background": "res://SceneStory/scene3.png"
	},
	{
		"name": "บรรยาย",
		"text": "และยังเป็นในรอบ 10 ปี ที่เทพธิดาประทาน วัตถุดิบในการทำพุดดิ้งสีทอง 
		เพื่อเป็นการขอบคุณหมู่บ้านกีกี้ ที่เป็นบ้านเกิดของผู้กล้าแจ็ค",
		"background": "res://SceneStory/scene4.png"
	},
	{
		"name": "บรรยาย",
		"text": "แต่ครั้งนี้ โชคชะตาไม่เข้าข้างผู้หิวโหย...",
		"background": "res://SceneStory/scene5.png"
	}
	,{
		"name": "บรรยาย",
		"text": "เจ้ายักษ์ใจร้าย...ลงมาทำลายหมู่บ้าน ",
		"background": "res://SceneStory/scene5.png"
	},
]

var dialogue_index = 0

func _ready():
	show_dialogue(dialogue_index)

	if next_button:
		# เชื่อมสัญญาณกดปุ่ม
		next_button.pressed.connect(_on_next_button_pressed)
	else:
		print("❌ ไม่พบปุ่ม NextButton ตรวจสอบ path ให้ถูกต้อง")


func _input(event):
	# ตรวจจับการกด action "next"
	if event.is_action_pressed("next"):
		_on_next_button_pressed()

func show_dialogue(index):
	var entry = dialogues[index]

	# โหลดภาพพื้นหลัง
	var bg_path = entry.get("background", "")
	if bg_path != "":
		background.texture = load(bg_path)

		# ✅ ปรับขนาด Sprite2D ให้เต็ม 1152x648
		var target_size = Vector2(1152, 648)
		if background is Sprite2D:
			var tex_size = Vector2(background.texture.get_width(), background.texture.get_height())
			background.scale = target_size / tex_size
			background.position = target_size / 2  # จัดให้อยู่กลางจอ
		elif background is TextureRect:
			background.stretch_mode = TextureRect.STRETCH_SCALE
			background.size = target_size
	else:
		background.texture = null

	# อัปเดตชื่อและข้อความ
	name_label.text = entry["name"]
	dialogue_label.text = entry["text"]




func _on_next_button_pressed():
	dialogue_index += 1
	if dialogue_index < dialogues.size():
		show_dialogue(dialogue_index)
	else:
		print("✅ จบบทสนทนา → ไปหน้าเกมจริง")
		get_tree().change_scene_to_file("res://main.tscn")
