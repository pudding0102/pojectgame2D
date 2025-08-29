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
		"background": "res://StoryScene/scene1.png"
	},
	{
		"name": "บรรยาย",
		"text": "เด็กน้อยสามคน ต๋อง ระกา ด็องโก้ะ ตื่นเต้นเป็นอย่างมาก",
		"background": "res://StoryScene/scene2.png"
	},
	{
		"name": "เทพธิดา",
		"text": "เพราะเป็นเทศกาลขนมหวานประจำปีของหมู่บ้าน",
		"background": "res://bg/bg_temple.png"
	},
	{
		"name": "ลันเตา",
		"text": "...",
		"background": "res://bg/bg_temple.png"
	},
	{
		"name": "ลันเตา",
		"text": "เคครับ",
		"background": "res://bg/bg_temple.png"
	},
]

var dialogue_index = 0

func _ready():
	if next_button:
		next_button.pressed.connect(_on_next_button_pressed)
	else:
		print("❌ ไม่พบปุ่ม NextButton ตรวจสอบ path ให้ถูกต้อง")

	show_dialogue(dialogue_index)

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
