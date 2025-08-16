extends Node2D

@onready var main_menu: Panel = $Design/CanvasLayer/MainMenu
@onready var setting_menu: Panel = $Design/settingMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu.visible = true
	setting_menu.visible = false


func _on_bn_start_pressed() -> void:
	pass # Replace with function body.


func _on_bn_setting_pressed() -> void:
	main_menu.visible = false
	setting_menu.visible = true

func _on_bn_exit_pressed() -> void:
	get_tree().quit()
