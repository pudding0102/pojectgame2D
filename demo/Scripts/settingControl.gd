extends Panel

var grap_bn: Array
var size_bn: Array

#Graphic_bn
@onready var bn_high: Button = $VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_high
@onready var bn_medium_grap: Button = $VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_medium
@onready var bn_low: Button = $VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_low

#Size_bn
@onready var bn_large: Button = $VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_large
@onready var bn_mudium_size: Button = $VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_mudium
@onready var bn_small: Button = $VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_small

func _ready():
	grap_bn = [bn_high, bn_medium_grap, bn_low]
	size_bn = [bn_large, bn_mudium_size, bn_small]
	
	#ตั้งค่าปุ่มเริ่มต้นตามขนาดปัจจุบัน(autoload)
	if SizeController:
		match SizeController.current_size:
			SizeController.WindowSize.FULLSCREEN:
				set_active(size_bn, bn_large)
			SizeController.WindowSize.MEDIUM:
				set_active(size_bn, bn_mudium_size)
			SizeController.WindowSize.SMALL:
				set_active(size_bn, bn_small)


#Graphic pressed
func _on_bn_high_pressed() -> void:
	pass

func _on_bn_medium_grap_pressed() -> void:
	pass # Replace with function body.

func _on_bn_low_pressed() -> void:
	pass # Replace with function body.

#Size pressed
func _on_bn_large_pressed() -> void:
	set_active(size_bn, bn_large)
	SizeController.set_window_size(SizeController.WindowSize.FULLSCREEN)
	SizeController.save_settings()

func _on_bn_mudium_size_pressed() -> void:
	set_active(size_bn, bn_mudium_size)
	SizeController.set_window_size(SizeController.WindowSize.MEDIUM)
	SizeController.save_settings()
		
func _on_bn_small_pressed() -> void:
	set_active(size_bn, bn_small)
	SizeController.set_window_size(SizeController.WindowSize.SMALL)
	SizeController.save_settings()
		
func _on_exit_bn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
#จัดการปุ่มในกลุ่ม
func set_active(buttons: Array, active_button: Button):
	for btn in buttons:
		btn.button_pressed = (btn == active_button)
