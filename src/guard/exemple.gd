extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
@onready var whistle_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

var focused_object: Drone
var alarm_active: bool = false
var alarm_sound = preload("res://assets/sound_efects/guard_surprised.mp3")
var whistle_sound: AudioStreamMP3 = preload("res://assets/sound_efects/guard_whistle.mp3")

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Drone:
		focused_object = body as Drone
		if not alarm_active:
			audio_player.play()
			alarm_active = true
		print("sensor saw drone: ", body.name)

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == focused_object:
		focused_object = null
		alarm_active = false
		audio_player.stop()

func _ready() -> void:
	animation_player.play("beep")
	audio_player.stream = alarm_sound
	audio_player.autoplay = false
	audio_player.unit_size = 10
	audio_player.max_distance = 20
	add_child(audio_player)

	whistle_sound.loop = true
	whistle_player.stream = whistle_sound
	whistle_player.autoplay = false
	whistle_player.volume_db = -20
	whistle_player.unit_size = 10
	whistle_player.max_distance = 20
	whistle_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	add_child(whistle_player)
	whistle_player.play()
	
