extends Panel

@onready var bn_exit = $Design/Panel/exit_bn
var sceneManager = preload("res://Scripts/sceneManager.gd")
#Graphic_bn
@onready var bn_high: Button = $Panel/VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_high
@onready var bn_medium_grap: Button = $Panel/VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_medium
@onready var bn_low: Button = $Panel/VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_low

#Size_bn
@onready var bn_large: Button = $Panel/VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_large
@onready var bn_mudium_size: Button = $Panel/VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_mudium
@onready var bn_small: Button = $Panel/VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_small

#Group
@onready var grap_buttons = [bn_high, bn_medium_grap, bn_low]
@onready var size_buttons = [bn_large, bn_mudium_size, bn_small]

func _ready():
	pass

#Graphic pressed
func _on_bn_high_pressed() -> void:
	pass # Replace with function body.

func _on_bn_medium_grap_pressed() -> void:
	pass # Replace with function body.

func _on_bn_low_pressed() -> void:
	pass # Replace with function body.


#Size pressed
func _on_bn_large_pressed() -> void:
	pass # Replace with function body.

func _on_bn_mudium_size_pressed() -> void:
	pass # Replace with function body.

func _on_bn_small_pressed() -> void:
	pass # Replace with function body.



func _on_exit_bn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
