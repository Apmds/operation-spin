extends Control

const AUDIO_SETTINGS_SCENE: PackedScene = preload("res://src/menus/audio_settings_menu.tscn")

@onready var title_label: Label = $Panel/Title
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var next_button: Button = $Panel/VBoxContainer/NextButton
@onready var background: TextureRect = $Background

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	MenuMusic.stop_menu_music()
	background.texture = preload("res://assets/models/city_rooftop_night_skybox_0.png")
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.pivot_offset = Vector2(background.size.x * 0.5, background.size.y * 0.5)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(background, "rotation_degrees", 1.2, 20.0)
	tween.tween_property(background, "rotation_degrees", -1.2, 20.0)
	_add_audio_settings_menu()

	var result: String = SaveManager.get_last_result()
	var sound_path: String = "res://assets/themes/game_over.mp3"
	if result == "victory":
		sound_path = "res://assets/themes/victory_sound.mp3"
		title_label.text = "Level complete"
		retry_button.visible = true
		next_button.visible = true
		var next_level: int = SaveManager.get_selected_level() + 1
		next_button.disabled = next_level > 10
		next_button.text = "Next level" if next_level <= 10 else "Last level"
	else:
		title_label.text = "Mission failed"
		retry_button.visible = true
		next_button.visible = false

	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = load(sound_path)
	audio_player.autoplay = true
	audio_player.volume_db = -5
	audio_player.bus = "Music"
	add_child(audio_player)

func _add_audio_settings_menu() -> void:
	var settings_menu: Control = AUDIO_SETTINGS_SCENE.instantiate()
	add_child(settings_menu)
	settings_menu.set_anchors_preset(Control.PRESET_TOP_LEFT)
	settings_menu.position = Vector2(16, 16)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menus/main_menu.tscn")

func _on_retry_button_pressed() -> void:
	var level_number: int = SaveManager.get_selected_level()
	var scene_path: String = "res://src/levels/level_%d.tscn" % level_number
	get_tree().change_scene_to_file(scene_path)

func _on_next_button_pressed() -> void:
	var next_level: int = SaveManager.get_selected_level() + 1
	if next_level > 10:
		return
	SaveManager.set_selected_level(next_level)
	var scene_path: String = "res://src/levels/level_%d.tscn" % next_level
	get_tree().change_scene_to_file(scene_path)
