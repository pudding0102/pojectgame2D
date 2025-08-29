extends Node2D

@onready var main_menu: Panel = $Design/CanvasLayer/MainMenu
@onready var setting_menu: Panel = $Design/settingMenu

# test

func _ready() -> void:
	main_menu.visible = true
	setting_menu.visible = false
	SizeController.apply_size(SizeController.current_size)

func _on_bn_start_pressed() -> void:
	pass 


func _on_bn_setting_pressed() -> void:
	main_menu.visible = false
	setting_menu.visible = true

func _on_bn_exit_pressed() -> void:
	get_tree().quit()
