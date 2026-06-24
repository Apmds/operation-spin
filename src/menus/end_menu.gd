extends Control

@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var game_over_sound = preload("res://assets/sound_efects/game_over.mp3")
	audio_player.stream = game_over_sound
	audio_player.autoplay = true
	audio_player.volume_db = -5
	add_child(audio_player)

func _on_end_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menus/main_menu.tscn")
