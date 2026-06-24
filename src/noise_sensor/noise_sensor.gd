extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
@onready var whistle_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
@onready var alarm_timer: Timer = Timer.new()

var focused_object: Drone
var alarm_active: bool = false
var accumulated_time: float = 0.0
var threshold_time: float = 3.0
var sensor_alarm_sound = preload("res://assets/sound_efects/alarm.mp3")
var whistle_sound: AudioStreamMP3 = preload("res://assets/sound_efects/guard_whistle.mp3")

func _set_alarm_active(active: bool) -> void:
	if active == alarm_active:
		return
	alarm_active = active
	if alarm_active:
		audio_player.play()
	else:
		audio_player.stop()

func _reset_sensor_state() -> void:
	if focused_object != null and focused_object.boost_changed.is_connected(_on_drone_boost_changed):
		focused_object.boost_changed.disconnect(_on_drone_boost_changed)
	focused_object = null
	accumulated_time = 0.0
	_stop_alarm_timer()

func _start_alarm_timer() -> void:
	if focused_object == null:
		return
	if alarm_timer.is_stopped():
		_set_alarm_active(true)
		alarm_timer.start(0.1)

func _stop_alarm_timer() -> void:
	alarm_timer.stop()
	_set_alarm_active(false)

func _on_alarm_timeout() -> void:
	if focused_object != null and focused_object.is_boosted:
		accumulated_time += 0.1
		if accumulated_time >= threshold_time:
			get_tree().change_scene_to_file("res://src/menus/end_menu.tscn")
			return
		alarm_timer.start(0.1)

func _on_drone_boost_changed(is_boosted: bool) -> void:
	if focused_object == null:
		return
	if is_boosted:
		_start_alarm_timer()
	else:
		_stop_alarm_timer()

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Drone:
		focused_object = body as Drone
		if not focused_object.boost_changed.is_connected(_on_drone_boost_changed):
			focused_object.boost_changed.connect(_on_drone_boost_changed)
		if focused_object.is_boosted:
			_start_alarm_timer()
		else:
			_stop_alarm_timer()

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == focused_object:
		_reset_sensor_state()

func _ready() -> void:
	animation_player.play("beep")
	audio_player.stream = sensor_alarm_sound
	audio_player.autoplay = false
	audio_player.unit_size = 10
	audio_player.max_distance = 20
	add_child(audio_player)

	alarm_timer.wait_time = 0.1
	alarm_timer.one_shot = true
	alarm_timer.timeout.connect(_on_alarm_timeout)
	add_child(alarm_timer)

	whistle_sound.loop = true
	whistle_player.stream = whistle_sound
	whistle_player.autoplay = false
	whistle_player.volume_db = -20
	whistle_player.unit_size = 10
	whistle_player.max_distance = 20
	whistle_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	add_child(whistle_player)
	whistle_player.play()
	
