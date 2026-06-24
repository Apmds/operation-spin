class_name MainMenu extends Control

@onready var intro_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var loop_player: AudioStreamPlayer = AudioStreamPlayer.new()

var intro_sound = preload("res://assets/themes/start the game.mp3")
var loop_sound = preload("res://assets/themes/inicial menu.mp3")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	intro_player.stream = intro_sound
	intro_player.autoplay = false
	intro_player.volume_db = -80
	intro_player.finished.connect(_on_intro_finished)
	add_child(intro_player)

	loop_player.stream = loop_sound
	loop_player.autoplay = false
	loop_player.volume_db = -80
	loop_player.stream.loop = true
	add_child(loop_player)

	if get_tree().root.get_meta("music_intro_played", false):
		_start_menu_music()
	else:
		_play_start_intro()
		get_tree().root.set_meta("music_intro_played", true)

func _start_menu_music() -> void:
	loop_player.play()
	_fade_audio(loop_player, -80, -5, 0.8)

func _play_start_intro() -> void:
	loop_player.stop()
	intro_player.play()
	_fade_audio(intro_player, -80, -5, 0.8)

func _on_intro_finished() -> void:
	loop_player.play()
	_fade_audio(loop_player, -80, -5, 0.8)

func _fade_audio(player: AudioStreamPlayer, from_db: float, to_db: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(player, "volume_db", to_db, duration)
	player.volume_db = from_db

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/test_scene.tscn")
