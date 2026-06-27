extends Control

@onready var title_label: Label = %Title
@onready var retry_button: Button = %RetryButton
@onready var next_button: Button = %NextButton
@onready var background: TextureRect = $Background
@onready var last_level_thing: Label = %LastLevelThing

const NUMBER_OF_LEVELS: int = 6

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	MenuMusic.stop_menu_music()
	background.pivot_offset = Vector2(background.size.x * 0.5, background.size.y * 0.5)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(background, "rotation_degrees", 1.2, 20.0)
	tween.tween_property(background, "rotation_degrees", -1.2, 20.0)

	var result: String = SaveManager.get_last_result()
	var sound_path: String = "res://assets/themes/game_over.mp3"
	if result == "victory":
		sound_path = "res://assets/themes/victory_sound.mp3"
		retry_button.visible = true
		
		var next_level: int = SaveManager.get_selected_level() + 1
		
		var is_last_level = next_level > NUMBER_OF_LEVELS
		next_button.visible = not is_last_level
		last_level_thing.visible = is_last_level
		
		title_label.text = "Last level complete!" if is_last_level else "Level complete"
	else:
		title_label.text = "Mission failed"
		retry_button.visible = true
		next_button.visible = false
		last_level_thing.visible = false

	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = load(sound_path)
	audio_player.autoplay = true
	audio_player.volume_db = -5
	audio_player.bus = "Music"
	add_child(audio_player)

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
