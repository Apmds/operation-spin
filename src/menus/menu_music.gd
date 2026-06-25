extends Node

var intro_player: AudioStreamPlayer = AudioStreamPlayer.new()
var loop_player: AudioStreamPlayer = AudioStreamPlayer.new()

var intro_sound = preload("res://assets/themes/start the game.mp3")
var loop_sound = preload("res://assets/themes/inicial menu.mp3")

var _music_started: bool = false
var _intro_played: bool = false

func _ready() -> void:
	intro_player.stream = intro_sound
	intro_player.volume_db = -80
	intro_player.finished.connect(_on_intro_finished)
	add_child(intro_player)

	loop_player.stream = loop_sound
	loop_player.volume_db = -80
	loop_player.stream.loop = true
	add_child(loop_player)

func play_menu_music() -> void:
	if _music_started:
		return

	_music_started = true
	if _intro_played:
		_start_loop_music()
	else:
		_intro_played = true
		_play_start_intro()

func stop_menu_music() -> void:
	_music_started = false
	intro_player.stop()
	loop_player.stop()

func _play_start_intro() -> void:
	loop_player.stop()
	intro_player.play()
	_fade_audio(intro_player, -80, -5, 0.8)

func _start_loop_music() -> void:
	loop_player.play()
	_fade_audio(loop_player, -80, -5, 0.8)

func _on_intro_finished() -> void:
	_start_loop_music()

func _fade_audio(player: AudioStreamPlayer, from_db: float, to_db: float, duration: float) -> void:
	var tween = create_tween()
	player.volume_db = from_db
	tween.tween_property(player, "volume_db", to_db, duration)
