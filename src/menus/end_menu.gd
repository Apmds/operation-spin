extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_end_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menus/main_menu.tscn")
