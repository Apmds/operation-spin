extends Control

@onready var background: TextureRect = $Background

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	background.texture = preload("res://assets/models/city_rooftop_night_skybox_0.png")
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.pivot_offset = Vector2(background.size.x * 0.5, background.size.y * 0.5)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(background, "rotation_degrees", 1.2, 20.0)
	tween.tween_property(background, "rotation_degrees", -1.2, 20.0)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menus/main_menu.tscn")
