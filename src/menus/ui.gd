class_name UI extends Control

var level_select_scene: PackedScene = preload("res://src/menus/level_select_menu.tscn")

@onready var mode_status: Label = %"Mode status"
@onready var fans_status: TextureRect = %"Fans status"
@onready var noise_status: TextureProgressBar = %"Noise status"
@onready var danger_indicators: Control = %"Danger Indicators"

@onready var pause_menu: Control = %PauseMenu

func is_paused() -> bool:
	return get_tree().paused

func open_pause_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	pause_menu.visible = true

func close_pause_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	pause_menu.visible = false

func _input(event):
	if event.is_action_pressed("pause"):
		if not is_paused():
			open_pause_menu()
		else:
			close_pause_menu()

func _on_resume_button_pressed():
	close_pause_menu()

func _on_reset_button_pressed():
	close_pause_menu()
	get_tree().reload_current_scene()

func _on_back_button_pressed():
	close_pause_menu()
	get_tree().change_scene_to_packed(level_select_scene)
